/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.modules.settings;

import java.io.IOException;

import im.actor.core.api.ApiParameter;
import im.actor.core.api.base.SeqUpdate;
import im.actor.core.api.rpc.RequestEditParameter;
import im.actor.core.api.rpc.RequestGetParameters;
import im.actor.core.api.rpc.ResponseSeq;
import im.actor.core.api.updates.UpdateParameterChanged;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.settings.entity.SettingsSyncAction;
import im.actor.core.modules.settings.entity.SettingsSyncState;
import im.actor.core.network.RpcCallback;
import im.actor.core.network.RpcException;
import im.actor.runtime.Log;

public class SettingsSyncActor extends ModuleActor {

    private static final String SYNC_STATE = "settings_sync_state_v2";
    private static final String SYNC_STATE_LOADED = "settings_sync_state_loaded_v2";

    private SettingsSyncState syncState;

    private boolean isLoading = false;

    public SettingsSyncActor(ModuleContext modules) {
        super(modules);
    }

    @Override
    public void preStart() {
        super.preStart();
        syncState = new SettingsSyncState();
        byte[] data = preferences().getBytes(SYNC_STATE);
        if (data != null) {
            try {
                syncState = SettingsSyncState.fromBytes(data);
            } catch (IOException e) {
                Log.e(SettingsSyncActor.class.getName(), e);
            }
        }

        for (SettingsSyncAction action : syncState.getPendingActions()) {
            performSync(action);
        }

        if (!preferences().getBool(SYNC_STATE_LOADED, false)) {
            self().send(new SettingsSyncActor.OnRequestGetParameters());
        } else {
            context().getConductor().getConductor().onSettingsLoaded();
        }
    }

    private void onRequestGetParameters() {
        isLoading = true;

        api(new RequestGetParameters()).map(response -> {

            for (ApiParameter p : response.getParameters()) {
                context().getSettingsModule().onUpdatedSetting(p.getKey(), p.getValue());
            }
            context().getSettingsModule().notifySettingsChanged();
            preferences().putBool(SYNC_STATE_LOADED, true);
            context().getConductor().getConductor().onSettingsLoaded();

            return null;
        }).then(val -> isLoading = false);
    }

    private void performSync(final SettingsSyncAction action) {
        request(new RequestEditParameter(action.getKey(), action.getValue()), new RpcCallback<ResponseSeq>() {
            @Override
            public void onResult(ResponseSeq response) {
                syncState.getPendingActions().remove(action);
                saveState();
                updates().onUpdateReceived(new SeqUpdate(response.getSeq(), response.getState(),
                        UpdateParameterChanged.HEADER, new UpdateParameterChanged(action.getKey(), action.getValue()).toByteArray()));
            }

            @Override
            public void onError(RpcException e) {
                // Ignore
            }
        });
    }

    private void saveState() {
        preferences().putBytes(SYNC_STATE, syncState.toByteArray());
    }

    @Override
    public void onReceive(Object message) {
        if (message instanceof ChangeSettings) {
            ChangeSettings changeSettings = (ChangeSettings) message;
            SettingsSyncAction action = new SettingsSyncAction(changeSettings.getKey(),
                    changeSettings.getValue());
            syncState.getPendingActions().add(action);
            saveState();
            performSync(action);
        } else if (message instanceof OnRequestGetParameters) {
            onRequestGetParameters();
        } else {
            super.onReceive(message);
        }
    }

    public static class ChangeSettings {
        private String key;
        private String value;

        public ChangeSettings(String key, String value) {
            this.key = key;
            this.value = value;
        }

        public String getKey() {
            return key;
        }

        public String getValue() {
            return value;
        }
    }

    public static class OnRequestGetParameters {

    }
}