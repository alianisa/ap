package im.actor.core.modules.grouppre;

import java.util.ArrayList;
import java.util.List;

import im.actor.core.api.ApiGroupOutPeer;
import im.actor.core.api.ApiGroupPre;
import im.actor.core.api.rpc.RequestLoadGroupsPre;
import im.actor.core.api.rpc.ResponseLoadGroupsPre;
import im.actor.core.entity.GroupPre;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.runtime.Log;
import im.actor.runtime.actors.messages.Void;
import im.actor.runtime.function.Tuple2;
import im.actor.runtime.promise.Promise;
import im.actor.runtime.promise.Promises;
import im.actor.runtime.promise.PromisesArray;


/**
 * Created by diego on 31/05/17.
 */

public class GroupsPreActor extends ModuleActor {

    private static final String TAG = GroupsPreActor.class.getSimpleName();

    private static final String KEY_VERSION = "_1";

    private final String KEY_LOADED;
    private final String KEY_LOADED_INIT;

    private final Integer idGrupoPai;

    private boolean isLoading = false;
    private boolean isLoaded = false;

    public GroupsPreActor(ModuleContext context, Integer idGrupoPai) {
        super(context);
        this.idGrupoPai = idGrupoPai;
        KEY_LOADED = "grupo_pre_loaded_loaded" + "_" + idGrupoPai + KEY_VERSION;
        KEY_LOADED_INIT = "grupo_pre_inited" + "_" + idGrupoPai + KEY_VERSION;
    }

    @Override
    public void preStart() {
        isLoaded = preferences().getBool(KEY_LOADED, false);
        if (!preferences().getBool(KEY_LOADED_INIT, false)) {
            self().send(new GroupsPreActor.LoadGruposPre());
        } else {
            context().getConductor().getConductor().onGruposPreLoaded(idGrupoPai);
        }
    }

    private void onLoadGruposPre() {
        if (isLoading || isLoaded) {
            return;
        }

        isLoading = true;

        Log.d(TAG, "Loading groupspre, parentId: "+this.idGrupoPai);
        api(new RequestLoadGroupsPre(this.idGrupoPai))
                .map(r -> {
                    List<ApiGroupOutPeer> groupsOutPeer = new ArrayList<>();
                    for (ApiGroupPre groupPre : r.getGroups()) {
                        groupsOutPeer.add(new ApiGroupOutPeer(groupPre.getGroupId(), groupPre.getAcessHash()));
                    }
                    return new Tuple2<>(r.getGroups(), groupsOutPeer);
                })
                .chain(r -> updates().loadRequiredPeers(new ArrayList<>(), r.getT2()))
                .map(r -> PromisesArray.of(r.getT1())
                        .map(r2 -> Promises.tuple(Promise.success(r2), groups().getValueAsync(r2.getGroupId())))
                        .map(r2 -> Promise.success(new GroupPre(r2.getT1().getGroupId(), r2.getT1().getParentId(),
                                r2.getT1().getOrder(), r2.getT1().hasChildrem(), true)))
                        .zip())
                .map(r -> r.map(r2 -> onGruposPreLoaded(r2)))
                .after((r, e) -> {
                    isLoading = false;
                });
    }

    private Promise<Void> onGruposPreLoaded(List<GroupPre> groupsPre) {
        return context().getGrupoPreModule().getRouter()
                .onGruposPreLoaded(idGrupoPai, groupsPre)
                .map(r -> {
                    isLoaded = true;
                    preferences().putBool(KEY_LOADED, isLoaded);
                    preferences().putBool(KEY_LOADED_INIT, true);
                    return r;
                });
    }

    private void clear() {
        isLoaded = false;
        preferences().putBool(KEY_LOADED, isLoaded);
        preferences().putBool(KEY_LOADED_INIT, false);
    }

    @Override
    public void onReceive(Object message) {
        if (message instanceof LoadGruposPre) {
            onLoadGruposPre();
        } else if (message instanceof Clear) {
            clear();
        }
    }

    public static class LoadGruposPre {
        public LoadGruposPre() {
        }
    }

    public static class Clear {

    }


}
