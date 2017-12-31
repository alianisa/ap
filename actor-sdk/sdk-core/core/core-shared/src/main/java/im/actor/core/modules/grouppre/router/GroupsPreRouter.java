package im.actor.core.modules.grouppre.router;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import im.actor.core.api.ApiGroupOutPeer;
import im.actor.core.api.ApiGroupPre;
import im.actor.core.api.updates.UpdateGroupPreCreated;
import im.actor.core.api.updates.UpdateGroupPreParentChanged;
import im.actor.core.api.updates.UpdateGroupPreRemoved;
import im.actor.core.entity.Group;
import im.actor.core.entity.GroupPre;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.grouppre.router.entity.RouterApplyGroupsPre;
import im.actor.core.modules.grouppre.router.entity.RouterGroupPreUpdate;
import im.actor.core.network.parser.Update;
import im.actor.runtime.Log;
import im.actor.runtime.actors.messages.Void;
import im.actor.runtime.annotations.Verified;
import im.actor.runtime.function.Tuple2;
import im.actor.runtime.promise.Promise;
import im.actor.runtime.promise.Promises;
import im.actor.runtime.promise.PromisesArray;
import im.actor.runtime.storage.KeyValueEngine;
import im.actor.runtime.storage.ListEngine;

public class GroupsPreRouter extends ModuleActor {

    private static final String TAG = GroupsPreRouter.class.getName();
    private boolean isFreezed = false;

    private KeyValueEngine<GroupPre> groupPreStates;

    public GroupsPreRouter(ModuleContext context) {
        super(context);
    }

    @Override
    public void preStart() {
        super.preStart();
        groupPreStates = context().getGrupoPreModule().getGroupsPreStates().getEngine();
    }

    private Promise<Void> onUpdate(Update update) {
        if (update instanceof UpdateGroupPreCreated) {
            UpdateGroupPreCreated upd = (UpdateGroupPreCreated) update;
            return onGroupPreCreated(upd.getGroupPre());
        } else if (update instanceof UpdateGroupPreRemoved) {
            UpdateGroupPreRemoved upd = (UpdateGroupPreRemoved) update;
            return onGroupPreRemoved(upd.getGroupPre(), upd.getRemovedChildren(), upd.getParentChildren());
        } else if (update instanceof UpdateGroupPreParentChanged) {
            UpdateGroupPreParentChanged upd = (UpdateGroupPreParentChanged) update;
            return onGroupPreParentChanged(upd.getGroupId(), upd.getOldParentId(), upd.getParentId());
        }
        return Promise.success(null);
    }

    @Verified
    public Promise<Void> onGroupPreCreated(final ApiGroupPre apiGroupPre) {
        freeze();
        return updates().loadRequiredPeers(new ArrayList<>(),
                Arrays.asList(new ApiGroupOutPeer(apiGroupPre.getGroupId(), apiGroupPre.getAcessHash())))
                .map(r -> groups().getValueAsync(apiGroupPre.getGroupId())
                        .map(group -> {
                            GroupPre groupPre = new GroupPre(apiGroupPre.getGroupId(),
                                    apiGroupPre.getParentId(),
                                    apiGroupPre.getOrder(),
                                    apiGroupPre.hasChildrem(), true);

                            gruposPre(apiGroupPre.getParentId()).addOrUpdateItem(groupPre);
                            groupPreStates.addOrUpdateItem(groupPre);

                            context().getGroupsModule().getRouter().onFullGroupNeeded(group.getGroupId());
                            return null;
                        }))

                .map(r -> {
                    unfreeze();
                    return null;
                });
    }

    @Verified
    public Promise<Void> onGroupPreRemoved(final ApiGroupPre apiGroupPre,
                                           List<Integer> removedChildren,
                                           List<Integer> parentChildren) {
        freeze();
        return new Promise<Void>(resolver -> {

            Integer parentId = apiGroupPre.getParentId();//pai do item removido

            GroupPre groupRemoved = gruposPre(parentId).getValue(apiGroupPre.getGroupId()); //obtendo o item removido
            gruposPre(parentId).removeItem(groupRemoved.getEngineId()); //removendo o item da listagem do pai

            for (Integer orphanId : removedChildren) { //realocando os filhos orfaos para o pai do item removido
                GroupPre orphan = gruposPre(groupRemoved.getGroupId()).getValue(orphanId); //obtendo o filho removido
                gruposPre(parentId).addOrUpdateItem(orphan.changeParentId(parentId)); //adicionando ele abaixo do pai
                groupPreStates.getValueAsync(orphan.getEngineId()) //atualizando o pai dele para o novo pai
                        .then(v-> groupPreStates.addOrUpdateItem(v.changeParentId(parentId)));
                gruposPre(groupRemoved.getGroupId()).removeItem(orphanId); //removendo ele da lista de filhos do item removido
            }

            new Promise<GroupPre>(res -> {
                if (parentId > GroupPre.DEFAULT_ID) { //verificando se o pai do item removido ainda possui filhos
                    groupPreStates.getValueAsync(parentId).then(r -> {//obtendo o estado do pai
                        groupPreStates.addOrUpdateItem(r.changeHasChildren(!parentChildren.isEmpty()));
                        GroupPre paiListagemAtualizado = gruposPre(r.getParentId()).getValue(r.getEngineId()).changeHasChildren(!parentChildren.isEmpty());
                        gruposPre(r.getParentId()).addOrUpdateItem(paiListagemAtualizado);
                        res.result(groupRemoved);
                    });
                }else{
                    res.result(groupRemoved);
                }
            }).then(r -> groupPreStates.getValueAsync(r.getEngineId())
                    .then(v -> groupPreStates.addOrUpdateItem(v.changeIsLoaded(false).changeParentId(0).changeHasChildren(false))));
        }).map(r -> {
            unfreeze();
            return null;
        });
    }

    public Promise<Void> onGroupPreParentChanged(final Integer groupId, final Integer oldParentId, final Integer parentId) {
        freeze();
        return groupPreStates.getValueAsync(groupId).map(groupPreState -> {
            //atualizando o id do pai no estado do grupo atual
            groupPreStates.addOrUpdateItem(groupPreState.changeParentId(parentId));

            //pega o grupo da listagem do antigo pai, ja atualizando o id do novo pai
            GroupPre groupPre = gruposPre(oldParentId).getValue(groupId).changeParentId(parentId);

            //adicionando o grupo ataual abaixo do novo pai
            gruposPre(parentId).addOrUpdateItem(groupPre);
            //removendo o grupo atual do antigo pai
            gruposPre(oldParentId).removeItem(groupPre.getEngineId());

            //setar o estado do novo pai para que possui filhos
            groupPreStates.getValueAsync(parentId).then(newParentState -> {
                groupPreStates.addOrUpdateItem(newParentState.changeHasChildren(true));
                GroupPre paiListagemAtualizado = gruposPre(newParentState.getParentId()).getValue(newParentState.getEngineId()).changeHasChildren(true);
                gruposPre(newParentState.getParentId()).addOrUpdateItem(paiListagemAtualizado);
            });

            if (oldParentId > GroupPre.DEFAULT_ID) {
                groupPreStates.getValueAsync(oldParentId).then(oldParentState -> {
                    oldParentState.changeHasChildren(!gruposPre(oldParentId).isEmpty());
                    GroupPre paiListagemAtualizado = gruposPre(oldParentState.getParentId()).getValue(oldParentState.getEngineId())
                            .changeHasChildren(!gruposPre(oldParentId).isEmpty());
                    gruposPre(oldParentState.getParentId()).addOrUpdateItem(paiListagemAtualizado);
                });
            }
            return null;
        }).map(r -> {
            unfreeze();
            return null;
        });
    }

    private void freeze() {
        isFreezed = true;
    }

    private void unfreeze() {
        isFreezed = false;
        unstashAll();
    }

    private Promise<Void> onGruposPreLoaded(Integer idGrupoPai, List<GroupPre> grupos) {
        Log.d(TAG, "Groups pre Loaded");
        updateGruposCanais(idGrupoPai, grupos);
        return Promise.success(null);
    }

    private ListEngine<GroupPre> gruposPre(Integer idGrupoPai) {
        return context().getGrupoPreModule().getGrupospreEngine(idGrupoPai);
    }

    private void updateGruposCanais(Integer idGrupoPai, List<GroupPre> gruposPre) {
        PromisesArray.of(gruposPre)
                .map(r -> Promises.tuple(Promise.success(r), groups().getValueAsync(r.getGroupId())))
                .zip()
                .then(rt -> {
                    List<GroupPre> grupos = new ArrayList<>();
                    for (Tuple2<GroupPre, Group> t2 : rt) {
                        GroupPre loadedGroup = t2.getT1().changeIsLoaded(true);
                        grupos.add(loadedGroup);
                        groupPreStates.addOrUpdateItem(loadedGroup);
                        context().getGroupsModule().getRouter().onFullGroupNeeded(t2.getT2().getGroupId());
                    }
                    gruposPre(idGrupoPai).addOrUpdateItems(grupos);
                });
    }

    @Override
    public Promise onAsk(Object message) throws Exception {
        if (message instanceof RouterApplyGroupsPre) {
            RouterApplyGroupsPre routerApplyGruposPre = (RouterApplyGroupsPre) message;
            return onGruposPreLoaded(routerApplyGruposPre.getIdGrupoPai(), routerApplyGruposPre.getGruposPre());
        } else if (message instanceof RouterGroupPreUpdate) {
            if (isFreezed) {
                stash();
                return null;
            }
            return onUpdate(((RouterGroupPreUpdate) message).getUpdate());
        } else {
            return super.onAsk(message);
        }
    }

    @Override
    public void onReceive(Object message) {
        super.onReceive(message);
    }
}
