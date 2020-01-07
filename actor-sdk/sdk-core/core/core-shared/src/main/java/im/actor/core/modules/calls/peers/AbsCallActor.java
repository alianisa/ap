package im.actor.core.modules.calls.peers;

import org.jetbrains.annotations.NotNull;

import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.calls.CallViewModels;
import im.actor.runtime.WebRTC;
import im.actor.runtime.actors.ActorRef;
import im.actor.runtime.webrtc.WebRTCMediaTrack;

public abstract class AbsCallActor extends ModuleActor implements CallBusCallback {

    protected final PeerSettings selfSettings;
    protected final CallViewModels callViewModels;
    protected final ActorRef callManager;
    protected CallBusInt callBus;

    public AbsCallActor(ModuleContext context) {
        super(context);

        this.callManager = context.getCallsModule().getCallManager();
        this.callViewModels = context().getCallsModule().getCallViewModels();
        this.selfSettings = new PeerSettings();
        this.selfSettings.setIsPreConnectionEnabled(WebRTC.isSupportsPreConnections());
    }

    @Override
    public void preStart() {
        super.preStart();
        callBus = new CallBusInt(system().actorOf(getPath() + "/bus", () -> {
            return new CallBusActor(new CallBusCallbackWrapper(), selfSettings, context());
        }));
    }

    public void onAudioEnableChanged(boolean enabled) {
        callBus.changeAudioEnabled(enabled);
    }

    public void onVideoEnableChanged(boolean enabled) {
        callBus.changeVideoEnabled(enabled);
    }

    public void onCallBusyChanged(long callId, long deviceId, boolean busy) {
        callBus.changeCallBusy(callId, deviceId, busy);
    }

//    public void onDeviceConnected(boolean connected) {
//        callBus.changeDeviceConnected(connected);
//    }
    //
    // Messages
    //

    @Override
    public void onReceive(Object message) {
        if (message instanceof AudioEnabled) {
            onAudioEnableChanged(((AudioEnabled) message).isEnabled());
        } else if (message instanceof VideoEnabled) {
            onVideoEnableChanged(((VideoEnabled) message).isEnabled());
        } else if (message instanceof OnCallBusy) {
            onCallBusyChanged(((OnCallBusy) message).getCallId(),((OnCallBusy) message).getDeviceId(),((OnCallBusy) message).isBusy());
        } else {
            super.onReceive(message);
        }
    }

    public static class AudioEnabled {

        private boolean enabled;

        public AudioEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public boolean isEnabled() {
            return enabled;
        }
    }

    public static class VideoEnabled {

        private boolean enabled;

        public VideoEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public boolean isEnabled() {
            return enabled;
        }
    }

    public static class OnCallBusy {
        private long callId;
        private long deviceId;
        private boolean busy;

        public OnCallBusy(long callId, long deviceId, boolean busy) {
            this.callId = callId;
            this.busy = busy;
            this.deviceId = deviceId;
        }

        public long getCallId() {
            return callId;
        }

        public long getDeviceId() {
            return deviceId;
        }

        public boolean isBusy() {
            return busy;
        }
    }

//    public static class DeviceConnected {
//
//        private boolean connected;
//
//        public DeviceConnected(boolean connected) {
//            this.connected = connected;
//        }
//
//        public boolean isConnected() {
//            return connected;
//        }
//    }


    //
    // Wrapper
    //

    private class CallBusCallbackWrapper implements CallBusCallback {

        @Override
        public void onBusStarted(@NotNull final String busId) {
            self().post(() -> AbsCallActor.this.onBusStarted(busId));
        }

        @Override
        public void onBusStopped() {
            self().post(() -> AbsCallActor.this.onBusStopped());
        }


        @Override
        public void onCallConnected() {
            self().post(() -> AbsCallActor.this.onCallConnected());
        }

        @Override
        public void onDeviceConnected() {
            self().post(() -> AbsCallActor.this.onDeviceConnected());
        }

        @Override
        public void onCallEnabled() {
            self().post(() -> AbsCallActor.this.onCallEnabled());
        }


        @Override
        public void onTrackAdded(long deviceId, WebRTCMediaTrack track) {
            self().post(() -> AbsCallActor.this.onTrackAdded(deviceId, track));
        }

        @Override
        public void onTrackRemoved(long deviceId, WebRTCMediaTrack track) {
            self().post(() -> AbsCallActor.this.onTrackRemoved(deviceId, track));
        }

        @Override
        public void onOwnTrackAdded(WebRTCMediaTrack track) {
            self().post(() -> AbsCallActor.this.onOwnTrackAdded(track));
        }

        @Override
        public void onOwnTrackRemoved(WebRTCMediaTrack track) {
            self().post(() -> AbsCallActor.this.onOwnTrackRemoved(track));
        }
    }
}
