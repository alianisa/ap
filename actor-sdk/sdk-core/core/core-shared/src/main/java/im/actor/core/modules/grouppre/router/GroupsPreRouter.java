package im.actor.core.modules.grouppre.router;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import im.actor.core.api.ApiGroupOutPeer;
import im.actor.core.api.ApiGroupPre;
import im.actor.core.api.updates.UpdateGroupPreCreated;
import im.actor.core.api.updates.UpdateGroupPreOrderChanged;
import im.actor.core.api.updates.UpdateGroupPreParentChanged;
import im.actor.core.api.updates.UpdateGroupPreRemoved;
import im.actor.core.api.updates.UpdateResetGroupPre;
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
import im.actor.runtime.function.Function;
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
        } else if (update instanceof UpdateGroupPreOrderChanged){
            UpdateGroupPreOrderChanged upd = (UpdateGroupPreOrderChanged) update;
            return onGroupPreOrderChanged(upd.getFromGroupId(), upd.getFromOrder(), upd.getToGroupId(), upd.getToOrder());
        }else if (update instanceof UpdateResetGroupPre){
            UpdateResetGroupPre upd = (UpdateResetGroupPre) update;
            return reset();
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

                            groupsPre(apiGroupPre.getParentId()).addOrUpdateItem(groupPre);
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

            Integer parentId = apiGroupPre.getParentId();

            GroupPre groupRemoved = groupsPre(parentId).getValue(apiGroupPre.getGroupId());
            groupsPre(parentId).removeItem(groupRemoved.getEngineId());

            for (Integer orphanGroupId : removedChildren) {
                GroupPre orphan = groupsPre(groupRemoved.getGroupId()).getValue(orphanGroupId);
                groupsPre(parentId).addOrUpdateItem(orphan.changeParentId(parentId));
                onParentIdChanged(orphan.getGroupId(), parentId)
                        .then(v-> groupsPre(groupRemoved.getGroupId()).removeItem(orphanGroupId));
            }
            new Promise<GroupPre>(res -> {
                if (parentId > GroupPre.DEFAULT_ID) {
                    onHasChildrenChanged(parentId, !parentChildren.isEmpty()).then(v -> res.result(groupRemoved));
                }else{
                    res.result(groupRemoved);
                }
            }).then(removedGroup -> {
                editGroupPre(removedGroup.getGroupId(), groupPre -> groupPre.changeIsLoaded(false)
                        .changeParentId(GroupPre.DEFAULT_ID)
                        .changeHasChildren(false));
                });
        }).map(r -> {
            unfreeze();
            return null;
        });
    }

    @Verified
    public Promise<GroupPre> onParentIdChanged(int groupId, Integer parentId) {
        return editGroupPre(groupId, groupPre -> groupPre.changeParentId(parentId));
    }

    @Verified
    public Promise<GroupPre> onHasChildrenChanged(int groupId, boolean hasChildren) {
        return editGroupPre(groupId, groupPre -> groupPre.changeHasChildren(hasChildren));
    }

    private Promise<GroupPre> editGroupPre(int groupId, Function<GroupPre, GroupPre> func) {
        return forGroupPre(groupId, groupPre -> {
            GroupPre g = func.apply(groupPre);
            groupsPre(g.getParentId()).addOrUpdateItem(g);
            groupPreStates.addOrUpdateItem(g);
            return Promise.success(g);
        });
    }

    //
    // Wrapper
    //
    private Promise<GroupPre> forGroupPre(int groupId, Function<GroupPre, Promise<GroupPre>> func) {
        freeze();
        return groupPreStates.getValueAsync(groupId)
                .flatMap(groupPre -> {
                    if(groupPre.getLoaded()){
                        return Promise.success(groupPre);
                    }else {
                        return context().getGrupoPreModule()
                                .loadGroupPre(groupPre.getGroupId());
                    }
                })
                .flatMap(g -> {
                    if (g != null) {
                        return func.apply(g);
                    }
                    return Promise.success(g);
                })
                .after((v, e) -> {
                    unfreeze();
                });
    }

    public Promise<Void> onGroupPreParentChanged(final Integer groupId, final Integer oldParentId, final Integer parentId) {

       freeze();

       return onParentIdChanged(groupId, parentId).map(groupPre -> {
            groupsPre(oldParentId).removeItem(groupPre.getEngineId());
            return groupPre;
        }).then(groupPre -> {
            onHasChildrenChanged(parentId, true);
            if (oldParentId > GroupPre.DEFAULT_ID) {
                onHasChildrenChanged(oldParentId, !groupsPre(oldParentId).isEmpty());
            }
        }).map(r -> {
            unfreeze();
            return null;
        });
    }

    public Promise<Void> onGroupPreOrderChanged(final Integer fromGroupId, final Integer fromNewOrder,
                                                final Integer toGroupId, final Integer toNewOrder) {
        freeze();
        return editGroupPre(fromGroupId, groupPre -> groupPre.changeSortOrder(fromNewOrder))
                .map(gp -> editGroupPre(toGroupId, groupPre -> groupPre.changeSortOrder(toNewOrder)))
                .map(r -> {
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
        updateGruposCanais(idGrupoPai, grupos);
        return Promise.success(null);
    }

    private ListEngine<GroupPre> groupsPre(Integer idGrupoPai) {
        return context().getGrupoPreModule().getGrupospreEngine(idGrupoPai);
    }

    private Promise<Void> reset(){
        context().getGrupoPreModule().reset();
        return Promise.success(null);
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
                    groupsPre(idGrupoPai).addOrUpdateItems(grupos);
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
