package im.actor.core.modules.grouppre;

import java.util.HashMap;
import java.util.Map;

import im.actor.core.api.rpc.RequestChangeGroupParent;
import im.actor.core.api.rpc.RequestChangeGroupPre;
import im.actor.core.api.rpc.RequestChangeOrder;
import im.actor.core.api.rpc.RequestLoadGroupPre;
import im.actor.core.api.rpc.ResponseVoid;
import im.actor.core.api.updates.UpdateGroupPreOrderChanged;
import im.actor.core.api.updates.UpdateGroupPreParentChanged;
import im.actor.core.entity.GroupPre;
import im.actor.core.events.AppVisibleChanged;
import im.actor.core.modules.AbsModule;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.grouppre.router.GroupsPreRouterInt;
import im.actor.core.viewmodel.GroupPreVM;
import im.actor.runtime.Storage;
import im.actor.runtime.actors.messages.Void;
import im.actor.runtime.eventbus.BusSubscriber;
import im.actor.runtime.eventbus.Event;
import im.actor.runtime.mvvm.MVVMCollection;
import im.actor.runtime.promise.Promise;
import im.actor.runtime.storage.ListEngine;

/**
 * Created by diego on 27/05/17.
 */

public class GroupsPreModule extends AbsModule implements BusSubscriber {

    // Workaround for j2objc bug
    private static final Void DUMB = null;
    private static final ResponseVoid DUMB2 = null;

    private static final String STORAGE_GRUPOSPRE = "grupospre";
    private static final String STORAGE_GRUPOSPRE_STATES = "grupospre_states";

    private HashMap<Integer, ListEngine<GroupPre>> gruposPreEngine = new HashMap<>();
    private MVVMCollection<GroupPre, GroupPreVM> groupsPreStates;
    private HashMap<Integer, GrupoPreActorInt> gruposPreLoadActor = new HashMap<>();
    private final GroupsPreRouterInt router;

    public GroupsPreModule(ModuleContext context) {
        super(context);
        router = new GroupsPreRouterInt(context);
        this.groupsPreStates = Storage.createKeyValue(STORAGE_GRUPOSPRE_STATES,
                GroupPreVM.CREATOR,
                GroupPre.CREATOR,
                GroupPre.DEFAULT_CREATOR);
    }

    @Override
    public void onBusEvent(Event event) {
    }

    public void run() {
    }

    public Promise<Void> changeGroupPre(int groupId, boolean isGroupPre) {
       return api(new RequestChangeGroupPre(groupId, isGroupPre))
               .flatMap(r -> updates().waitForUpdate(r.getSeq()));
    }

    public Promise<Void> changeParent(int groupId, int parentId, int oldParentId) {
        return api(new RequestChangeGroupParent(groupId, parentId))
                .map(r ->{
                    updates().applyUpdate(r.getSeq(), r.getState(), new UpdateGroupPreParentChanged(groupId, parentId, oldParentId));
                    return null;
                });
    }

    public Promise<Void> changeOrder(GroupPre fromGroup, GroupPre toGroup){
        return api(new RequestChangeOrder(fromGroup.getGroupId(), toGroup.getGroupId()))
                .map(r -> {
                    updates().applyUpdate(r.getSeq(), r.getState(),
                            new UpdateGroupPreOrderChanged(fromGroup.getGroupId(), toGroup.getSortOrder(),
                            toGroup.getGroupId(), fromGroup.getSortOrder()));
                    return null;
                });
    }

    public Promise<GroupPre> loadGroupPre(int groupPreId){
        return api(new RequestLoadGroupPre(groupPreId))
                .flatMap(r -> {
                    final GroupPre grupoPre = new GroupPre(r.getGroupPre().getGroupId(),
                            r.getGroupPre().getParentId(),
                            r.getGroupPre().getOrder(),
                            r.getGroupPre().hasChildrem(),
                            true);

                    return getRouter()
                            .onGroupPreLoaded(grupoPre)
                            .flatMap(r2 -> Promise.success(grupoPre));
                });
    }

    public ListEngine<GroupPre> getGrupospreEngine(Integer idGrupoPai) {
        synchronized (gruposPreEngine) {
            if (!gruposPreEngine.containsKey(idGrupoPai)) {
                getGruposPreLoadActor(idGrupoPai);//force to load the grous from the server for the first time
                gruposPreEngine.put(idGrupoPai,
                        Storage.createList(STORAGE_GRUPOSPRE + idGrupoPai, GroupPre.CREATOR));
            }
            return gruposPreEngine.get(idGrupoPai);
        }
    }

    public GroupsPreRouterInt getRouter() {
        return router;
    }

    public GrupoPreActorInt getGruposPreLoadActor(final Integer idGrupoPai) {
        synchronized (gruposPreLoadActor) {
            if (!gruposPreLoadActor.containsKey(idGrupoPai)) {
                gruposPreLoadActor.put(idGrupoPai, new GrupoPreActorInt(idGrupoPai, context()));
            }
            return gruposPreLoadActor.get(idGrupoPai);
        }
    }

    public void reset(){
        this.groupsPreStates.getEngine().clear();

        for(Map.Entry<Integer, ListEngine<GroupPre>> entry: gruposPreEngine.entrySet()){
            entry.getValue().clear();
        }

        this.gruposPreEngine = new HashMap<>();

        for(Map.Entry<Integer, GrupoPreActorInt> entry: gruposPreLoadActor.entrySet()){
            entry.getValue().clear();
        }
        this.gruposPreLoadActor = new HashMap<>();


    }

    public MVVMCollection<GroupPre, GroupPreVM> getGroupsPreStates() {
        return groupsPreStates;
    }

    public GroupPreVM getGrupoPreVM(Long idGrupoPre) {
        return groupsPreStates.get(idGrupoPre);
    }

}
