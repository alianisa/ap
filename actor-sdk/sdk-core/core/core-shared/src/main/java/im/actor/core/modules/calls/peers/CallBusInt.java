package im.actor.core.modules.calls.peers;

import org.jetbrains.annotations.NotNull;

import im.actor.runtime.actors.ActorInterface;
import im.actor.runtime.actors.ActorRef;

public class CallBusInt extends ActorInterface {

//    private boolean isConnected;

    private long peerDeviceId;

    public CallBusInt(@NotNull ActorRef dest) {
        super(dest);
    }

    public void joinBus(@NotNull String busId) {
        send(new CallBusActor.JoinBus(busId));
    }

    public void joinMasterBus(@NotNull String busId, long deviceId) {
        peerDeviceId = deviceId;
        send(new CallBusActor.JoinMasterBus(busId, deviceId));
    }

    public void changeAudioEnabled(boolean enabled) {
        send(new CallBusActor.AudioEnabled(enabled));
    }

    public void changeVideoEnabled(boolean enabled) {
        send(new CallBusActor.VideoEnabled(enabled));
    }

    public void changeCallBusy(long callId, long deviceId, boolean busy) {
        send(new CallBusActor.OnCallBusy(callId, peerDeviceId, busy));
    }

//    public void changeDeviceConnected(boolean connected) {
//        send(new CallBusActor.DeviceConnected(connected));
//        if (connected) {
//            isConnected = true;
//        }
//    }

//    public boolean deviceIsConnected() {
//        return isConnected;
//    }

    public void startOwn() {
        send(new CallBusActor.OnAnswered());
    }
}