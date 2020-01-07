package im.actor.core.modules.calls;

import im.actor.core.api.*;
import im.actor.core.api.rpc.*;
import im.actor.core.api.updates.UpdateIncomingCall;
import im.actor.core.api.updates.UpdateSyncedSetAddedOrUpdated;
import im.actor.core.entity.User;
import im.actor.core.network.parser.Update;
import im.actor.core.providers.CallsProvider;
import im.actor.core.viewmodel.*;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.function.Function;
import im.actor.runtime.promise.Promise;
import im.actor.runtime.promise.PromisesArray;
import org.jetbrains.annotations.NotNull;

import im.actor.core.entity.Peer;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.calls.peers.AbsCallActor;
import im.actor.core.modules.calls.peers.CallBusActor;
import im.actor.core.viewmodel.generics.ArrayListMediaTrack;
import im.actor.runtime.actors.messages.PoisonPill;
import im.actor.runtime.power.WakeLock;
import im.actor.runtime.webrtc.WebRTCMediaTrack;
import im.actor.runtime.webrtc.WebRTCTrackType;
import im.actor.runtime.Log;

import im.actor.core.api.ApiActiveCall;


import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import static im.actor.core.entity.EntityConverter.convert;

public class CallActor extends AbsCallActor {

    private final boolean isMaster;
    private final WakeLock wakeLock;
    private long callId;
    private Peer peer;

    private CallVM callVM;
    private CommandCallback<Long> callback;

    private boolean isActive;
    private boolean isAnswered;
    private boolean isRejected;

    public boolean isConnected = false;

    private boolean isVideoInitiallyEnabled;

    private CallState callState;

    private CallMemberState callMemberState;

//    private  ApiCallMember apiCallMember;

    private ArrayList<CallMember> callMember = new ArrayList<>();

    private ApiActiveCall apiActiveCall;

    private ActiveCall activeCall;

    private byte[] data;

    private boolean isBusy;
    private boolean isNoAnswer = false;
    private boolean isNotAvailable = false;

    private volatile boolean stop = false;

    private CallsProvider provider;

    private List<ApiCallMember> apiCallMember = new ArrayList<>();
//    private ArrayList<ApiActiveCall> apiActiveCall = new ArrayList<>();

    public  ApiCallMemberStateHolder apiCallMemberStateHolder;

//    public  ApiCallMemberState apiCallMemberState;

    private List<ApiCallMemberState> apiCallMemberState = new ArrayList<>();


    public CallActor(long callId, WakeLock wakeLock, ModuleContext context) {
        super(context);
        this.wakeLock = wakeLock;
        this.isMaster = false;
        this.callId = callId;
        this.isAnswered = false;
        this.isActive = false;
    }

    public CallActor(Peer peer, CommandCallback<Long> callback, WakeLock wakeLock, boolean isVideoInitiallyEnabled, boolean isBusy, ModuleContext context) {
        super(context);
        this.wakeLock = wakeLock;
        this.isMaster = true;
        this.callback = callback;
        this.peer = peer;
        this.isAnswered = true;
        this.isActive = false;
        this.isVideoInitiallyEnabled = isVideoInitiallyEnabled;
        this.isBusy = isBusy;
    }



    @Override
    public void preStart() {
        super.preStart();

        provider = config().getCallsProvider();

        if (isMaster) {
            api(new RequestDoCall(buidOutPeer(peer), CallBusActor.TIMEOUT, false, false, isVideoInitiallyEnabled, isBusy)).then(responseDoCall -> {
                callId = responseDoCall.getCallId();
                callBus.joinMasterBus(responseDoCall.getEventBusId(), responseDoCall.getDeviceId());
                callBus.changeVideoEnabled(isVideoInitiallyEnabled);
                callBus.startOwn();
//                isBusy = true;
                boolean connected = isConnected;

                if (isBusy) {
                    callState = CallState.BUSY;
                    callVM.getState().change(CallState.BUSY);
                } else {
                    callState = CallState.RINGING;
                }


//                if (callVM.getState().get() == CallState.RINGING_REACHED) {
//                    try {
//                        stop = true;
//                        isNotAvailable = false;
//                        TimeUnit.SECONDS.sleep(30);
//                        isNoAnswer = true;
//                        noAnswer();
//                    } catch (InterruptedException e) {
//                        e.printStackTrace();
//                    }
//                    stop = true;
//                }


                callVM = callViewModels.spawnNewOutgoingVM(responseDoCall.getCallId(), peer, isVideoInitiallyEnabled,
                        isVideoInitiallyEnabled, connected, callState);

            }).failure(e -> self().send(PoisonPill.INSTANCE));
        } else {
            api(new RequestGetCallInfo(callId)).then(responseGetCallInfo -> {
                peer = convert(responseGetCallInfo.getPeer());
                isBusy = responseGetCallInfo.isBusy();
                callBus.joinBus(responseGetCallInfo.getEventBusId());
                if (responseGetCallInfo.isVideoPreferred() != null) {
                    isVideoInitiallyEnabled = responseGetCallInfo.isVideoPreferred();
                    callBus.changeVideoEnabled(isVideoInitiallyEnabled);
                }
                Log.d("CallActor", "isBusy: " + isBusy + "getUsers: " + responseGetCallInfo.getUsers());
                if (isBusy) {
//                    callVM.getState().change(CallState.BUSY);
                }
//                    callState = CallState.BUSY;
//                } else {
                    callState = CallState.RINGING;
//                }

                boolean connected = isConnected;

//                Log.d("CallActor", " Call In - " + callId );

                callVM = callViewModels.spawnNewIncomingVM(callId, peer, isVideoInitiallyEnabled,
                        isVideoInitiallyEnabled, connected, callState, callMember);
            }).failure(e -> self().send(PoisonPill.INSTANCE));
        }
    }


    public void onActiveCall(byte[] data) {

        try {
            apiActiveCall = Bser.parse(new ApiActiveCall(), data);
        } catch (IOException e) {
            e.printStackTrace();
        }

        apiCallMember = apiActiveCall.getCallMembers();

        for (ApiCallMemberState a : apiCallMemberState) {
            apiCallMemberState.add(a);
        }

//        Log.d("CallActor", "Members In - apiActiveCall" + apiCallMemberState + "callViewModels" + callViewModels.getCall(callId).getState().get());
    }

    public void busy() {

        callVM.getState().change(CallState.BUSY);
        isBusy = true;
        Log.d("CallActor", "onCallActive RequestBusyCall");
    }

    public void noAnswer() {
        if (isMaster) {
//        if (isNoAnswer) {
            if (callVM.getState().get() == CallState.IN_PROGRESS) {
                callVM.getState().change(CallState.ENDED);
            } else if (callVM.getState().get() == CallState.RINGING_REACHED) {
                callVM.getState().change(CallState.NO_ANSWER);
                Log.d("CallActor", "noAnswer");
            }
        }
//        }
    }

    public void notAvailable(Boolean connected) {
        if (isMaster) {
            if (connected) {
                if (!isBusy) {
                    callVM.getState().change(CallState.RINGING_REACHED);
                } else {
                    callVM.getState().change(CallState.BUSY);
                }
            }
            if (!isBusy) {
                if (callVM.getState().get() == CallState.BUSY || callVM.getState().get() == CallState.IN_PROGRESS || callVM.getState().get() == CallState.RINGING_REACHED) {
//            callVM.getState().change(CallState.ENDED);
                } else {
                    callVM.getState().change(CallState.NOT_AVAILABLE);
                    try {
                        TimeUnit.SECONDS.sleep(4);
                        if (!connected) {
                            callManager.send(new CallManagerActor.DoEndCall(callId));
                        }
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    //
    // Call lifecycle
    //

    @Override
    public void onBusStarted(@NotNull String busId) {
        if (isMaster) {
            callManager.send(new CallManagerActor.DoCallComplete(callId), self());

            callback.onResult(callId);
            callback = null;


        } else {
            callManager.send(new CallManagerActor.IncomingCallReady(callId), self());
        }
    }




    @Override
    public void onCallConnected() {
        // callVM.getState().change()

        Log.d("CallActor", "onCallConnected");

    }

    @Override
    public void onDeviceConnected() {
        isConnected = true;
        callVM.getState().change(CallState.RINGING_REACHED);
        if (isMaster) {
            notAvailable(true);
        }
        CallState state = callVM.getState().get();
//        provider.stopOutgoingBeep();
//        provider.startOutgoingBeep(true);
        Log.d("CallActor", " Callstate " + state.toString());
    }

    @Override
    public void onCallEnabled() {
        isActive = true;
        if (isAnswered) {
            stop = true;
            callVM.getState().change(CallState.IN_PROGRESS);

            callVM.setCallStart(im.actor.runtime.Runtime.getCurrentTime());
        }
        if (isMaster) {
            callManager.send(new CallManagerActor.OnCallAnswered(callId), self());
        }
    }

    public void onAnswerCall() {
        if (!isAnswered && !isRejected) {
            isAnswered = true;
            callBus.startOwn();
            request(new RequestJoinCall(callId));

            if (isActive) {
                callVM.getState().change(CallState.IN_PROGRESS);
                callVM.setCallStart(im.actor.runtime.Runtime.getCurrentTime());
            } else {
                callVM.getState().change(CallState.CONNECTING);

            }
        }
    }

    public void onRejectCall() {
        if (!isAnswered && !isRejected) {
            isRejected = true;
            stop = true;
            isBusy = false;
//            callVM.getState().change(CallState.BUSY);
            request(new RequestRejectCall(callId));
            self().send(PoisonPill.INSTANCE);
        }
    }

    @Override
    public void onBusStopped() {
        self().send(PoisonPill.INSTANCE);
    }


    //
    // Track Events
    //
    @Override
    public void onTrackAdded(long deviceId, WebRTCMediaTrack track) {
        if (track.getTrackType() == WebRTCTrackType.AUDIO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getTheirAudioTracks().get());
            tracks.add(track);
            callVM.getTheirAudioTracks().change(tracks);
        } else if (track.getTrackType() == WebRTCTrackType.VIDEO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getTheirVideoTracks().get());
            tracks.add(track);
            callVM.getTheirVideoTracks().change(tracks);
        } else {
            // Unknown track type
        }
    }

    @Override
    public void onTrackRemoved(long deviceId, WebRTCMediaTrack track) {
        if (track.getTrackType() == WebRTCTrackType.AUDIO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getTheirAudioTracks().get());
            tracks.remove(track);
            callVM.getTheirAudioTracks().change(tracks);
        } else if (track.getTrackType() == WebRTCTrackType.VIDEO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getTheirVideoTracks().get());
            tracks.remove(track);
            callVM.getTheirVideoTracks().change(tracks);
        } else {
            // Unknown track type
        }
    }

    @Override
    public void onOwnTrackAdded(WebRTCMediaTrack track) {
        if (track.getTrackType() == WebRTCTrackType.AUDIO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getOwnAudioTracks().get());
            tracks.add(track);
            callVM.getOwnAudioTracks().change(tracks);
        } else if (track.getTrackType() == WebRTCTrackType.VIDEO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getOwnVideoTracks().get());
            tracks.add(track);
            callVM.getOwnVideoTracks().change(tracks);
        } else {
            // Unknown track type
        }
    }

    @Override
    public void onOwnTrackRemoved(WebRTCMediaTrack track) {
        if (track.getTrackType() == WebRTCTrackType.AUDIO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getOwnAudioTracks().get());
            tracks.remove(track);
            callVM.getOwnAudioTracks().change(tracks);
        } else if (track.getTrackType() == WebRTCTrackType.VIDEO) {
            ArrayListMediaTrack tracks = new ArrayListMediaTrack(callVM.getOwnVideoTracks().get());
            tracks.remove(track);
            callVM.getOwnVideoTracks().change(tracks);
        } else {
            // Unknown track type
        }
    }

    @Override
    public void onAudioEnableChanged(boolean enabled) {
        super.onAudioEnableChanged(enabled);
        callVM.getIsAudioEnabled().change(enabled);
    }

    @Override
    public void onVideoEnableChanged(boolean enabled) {
        super.onVideoEnableChanged(enabled);
        callVM.getIsVideoEnabled().change(enabled);
    }



    //
    // Cleanup
    //

    @Override
    public void postStop() {
        super.postStop();
        if (callVM != null) {
            callVM.getState().change(CallState.ENDED);

            callVM.setCallEnd(im.actor.runtime.Runtime.getCurrentTime());
        }
        callBus.kill();
        if (callId != 0) {
            callManager.send(new CallManagerActor.OnCallEnded(callId), self());
        }
        wakeLock.releaseLock();
    }

    //
    // Messages
    //

    @Override
    public void onReceive(Object message) {
        if (message instanceof AnswerCall) {
            onAnswerCall();
        } else if (message instanceof RejectCall) {
            onRejectCall();
        } else if (message instanceof ActiveCall) {
//            onCallBusy(((BusyCall) message).getCallId());
//        } else if (message instanceof BusyCall) {
            onActiveCall(((ActiveCall) message).getData());
        } else if (message instanceof Busy) {
            busy();

        } else if (message instanceof NoAnswer) {
            noAnswer();
        } else if (message instanceof NotAvailable) {
            notAvailable(false);
        } else {
            super.onReceive(message);
        }
    }

    public static class AnswerCall {

    }

    public static class RejectCall {

    }

    public static class Busy {

    }

    public static class NoAnswer {

    }

    public static class NotAvailable {

    }

    public static class ActiveCall {

//        private long callId;
//
//        public BusyCall(long callId) {
//            this.callId = callId;
//        }
//
//        public long getCallId() {
//            return callId;
//        }

        private byte[] data;

        public ActiveCall(byte[] data) {
            this.data = data;
        }

        public byte[] getData() {
            return data;
        }


    }

}
