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
import im.actor.core.entity.GroupPreState;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.grouppre.router.entity.RouterApplyGruposPre;
import im.actor.core.modules.grouppre.router.entity.RouterGroupPreUpdate;
import im.actor.core.network.parser.Update;
import im.actor.runtime.Log;
import im.actor.runtime.actors.messages.Void;
import im.actor.runtime.annotations.Verified;
import im.actor.runtime.collections.ArrayUtils;
import im.actor.runtime.function.Tuple2;
import im.actor.runtime.promise.Promise;
import im.actor.runtime.promise.Promises;
import im.actor.runtime.promise.PromisesArray;
import im.actor.runtime.storage.KeyValueEngine;
import im.actor.runtime.storage.ListEngine;

public class GrupoPreRouter extends ModuleActor {

    private static final String TAG = GrupoPreRouter.class.getName();
    private boolean isFreezed = false;

    private KeyValueEngine<GroupPreState> groupPreStates;

    public GrupoPreRouter(ModuleContext context) {
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
                            GroupPre groupPre = new GroupPre(apiGroupPre.getGroupId(), apiGroupPre.getParentId(), apiGroupPre.getOrder(), apiGroupPre.hasChildrem());
                            gruposPre(apiGroupPre.getParentId()).addOrUpdateItem(groupPre);
                            groupPreStates.addOrUpdateItem(new GroupPreState(groupPre.getGroupId(), apiGroupPre.getParentId(), true, apiGroupPre.hasChildrem()));
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
        Integer parentId = apiGroupPre.getParentId();
        GroupPre groupRemoved = gruposPre(parentId).getValue(apiGroupPre.getGroupId());
        gruposPre(parentId).removeItem(groupRemoved.getEngineId());

        for(Integer orphanId : removedChildren){
            GroupPre orphan = gruposPre(groupRemoved.getGroupId()).getValue(orphanId);
            gruposPre(parentId).addOrUpdateItem(orphan);
            gruposPre(groupRemoved.getGroupId()).removeItem(orphanId);
        }

        if(parentId > GroupPre.DEFAULT_ID){
            groupPreStates.getValueAsync(parentId).then(r->{
                groupPreStates.addOrUpdateItem(r.changeHasChildren(!parentChildren.isEmpty()));
            });
        }

        groupPreStates.getValueAsync(groupRemoved.getEngineId()).then(v->{
           groupPreStates.addOrUpdateItem(v.changeIsLoaded(false).changeParentId(0).changeHasChildren(false));
        });
        unfreeze();

        return Promise.success(null);
    }

    public Promise<Void> onGroupPreParentChanged(final Integer groupId, final Integer oldParentId, final Integer parentId) {

        freeze();

        return groupPreStates.getValueAsync(groupId).map(groupPreState -> {
            //atualizando o id do pai no statdo do grupo atual
            groupPreStates.addOrUpdateItem(groupPreState.changeParentId(parentId));
            //adicionando o grupo ataual abaixo do novo pai
            gruposPre(parentId).addOrUpdateItem(gruposPre(oldParentId).getValue(groupId));
            //removendo o grupo atual do antigo pai
            gruposPre(oldParentId).removeItem(groupId);

            //setar o estado do novo pai para que possui filhos
            groupPreStates.getValueAsync(parentId).then(parentState -> {
                groupPreStates.addOrUpdateItem(parentState.changeHasChildren(true));
            });

            if(oldParentId > 0) {
                groupPreStates.getValueAsync(oldParentId).then(st -> {
                    st.changeHasChildren(!gruposPre(oldParentId).isEmpty());
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
        PromisesArray.of(gruposPre).map(r -> Promises.tuple(Promise.success(r), groups().getValueAsync(r.getGroupId())))
                .zip()
                .then(rt -> {
                    List<GroupPre> grupos = new ArrayList<>();
                    for (Tuple2<GroupPre, Group> t2 : rt) {
                        grupos.add(t2.getT1());
                        groupPreStates.addOrUpdateItem(new GroupPreState(t2.getT1().getGroupId(), idGrupoPai, true, t2.getT1().getHasChildren()));
                    }
                    gruposPre(idGrupoPai).addOrUpdateItems(grupos);
                });
    }

    @Override
    public Promise onAsk(Object message) throws Exception {
        if (message instanceof RouterApplyGruposPre) {
            RouterApplyGruposPre routerApplyGruposPre = (RouterApplyGruposPre) message;
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
