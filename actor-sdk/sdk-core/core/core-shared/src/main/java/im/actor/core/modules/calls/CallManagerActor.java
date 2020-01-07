package im.actor.core.modules.calls;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.TimeUnit;

import im.actor.core.api.*;
import im.actor.core.api.rpc.RequestBusyCall;
import im.actor.core.api.rpc.RequestDoCall;
import im.actor.core.entity.Peer;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.calls.peers.AbsCallActor;
import im.actor.core.modules.calls.peers.CallBusActor;
import im.actor.core.modules.messaging.actions.SenderActor;
import im.actor.core.providers.CallsProvider;
import im.actor.core.util.RandomUtils;
import im.actor.core.viewmodel.*;
import im.actor.runtime.Log;
import im.actor.runtime.Runtime;
import im.actor.runtime.actors.ActorCreator;
import im.actor.runtime.actors.ActorRef;
import im.actor.runtime.actors.Props;
import im.actor.runtime.actors.messages.PoisonPill;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.power.WakeLock;

import static im.actor.runtime.actors.ActorSystem.system;

public class CallManagerActor extends ModuleActor {

    public static ActorCreator CONSTRUCTOR(final ModuleContext context) {
        return () -> new CallManagerActor(context);
    }

    private static final String TAG = "CallManagerActor";

    private CallsProvider provider;
    private HashSet<Long> handledCalls = new HashSet<>();
    private HashMap<Long, Integer> handledCallAttempts = new HashMap<>();
    private HashSet<Long> answeredCalls = new HashSet<>();

    private Long currentCall;
    private HashMap<Long, ActorRef> runningCalls = new HashMap<>();
    private ActorRef sendMessageActor;

    private boolean isBeeping = false;
    private volatile boolean stop = false;
    private boolean isMaster;

    private CallViewModels callViewModels;

    private ApiActiveCall apiActiveCall;

//    private List<ApiCallMemberStateHolder> apiCallMemberStateHolder = new ArrayList<>();

    private ArrayList<CallMember> callMember = new ArrayList<>();

    private ApiCallMemberStateHolder apiCallMemberStateHolder;
    private ApiCallMemberState apiCallMemberState;

    private CallVM callVM;

    private CallState callState;

    private  Peer caleeUser;

    private long inCallId;

    private byte[] activeCallData;

    public CallManagerActor(ModuleContext context) {
        super(context);
    }

    @Override
    public void preStart() {
        super.preStart();
        provider = config().getCallsProvider();

        sendMessageActor = system().actorOf(Props.create(() -> new SenderActor(context())), "alo/master/" + RandomUtils.nextRid());

    }


    //
    // Outgoing call
    //

    private void doCall(final Peer peer, final CommandCallback<Long> callback, boolean isVideoEnabled, boolean isBusy) {
        //
        // Stopping current call as we started new done
        //
        if (currentCall != null) {
            terminalCall(currentCall);
            currentCall = null;
        }

        caleeUser = peer;

        //
        // Spawning new Actor for call
        //
        final WakeLock wakeLock = Runtime.makeWakeLock();
        system().actorOf("alo/master/" + RandomUtils.nextRid(), () -> {
            return new CallActor(peer, callback, wakeLock, isVideoEnabled, isBusy, context());
        });
    }

    private void onCallCreated(long callId, ActorRef ref) {

//        ref.send(new CallActor.BusyCall(activeCallData));


        //
        // Stopping current call some are started during call establishing
        //
        if (currentCall != null) {
            terminalCall(currentCall);
            currentCall = null;

            if (isBeeping) {
                isBeeping = false;
                provider.stopOutgoingBeep();
            }
        }

        //
        // Saving Reference to call
        //
        runningCalls.put(callId, ref);

        //
        // Marking outgoing call as answered
        //
        answeredCalls.add(callId);

        //
        // Setting Current Call
        //
        currentCall = callId;

        //
        // Notify Provider about new current call
        //
        provider.onCallStart(callId);
        isBeeping = true;
        provider.startOutgoingBeep(false);
        isMaster = true;
    }


    //
    // Incoming call
    //

    private void onIncomingCall(final long callId, final int attempt, WakeLock wakeLock) {
        Log.d(TAG, "onIncomingCall (" + callId + ")");

        //
        // Filter double updates about incoming call
        //
        if (handledCalls.contains(callId)) {
            if (handledCallAttempts.get(callId) >= attempt) {
//                provider.onCallEnd(callId);
//                request(new RequestBusyCall(callId));

                if (wakeLock != null) {
                    wakeLock.releaseLock();
                }
                return;
            }
        }

        //
        // Ignore any incoming call if we already have running call with such call id
        //
        if (runningCalls.containsKey(callId)) {

            if (wakeLock != null) {
                wakeLock.releaseLock();
            }
            return;
        }

        //
        // Marking handled calls as handled
        //
        handledCalls.add(callId);
        handledCallAttempts.put(callId, attempt);

        //
        // Creating wake lock if needed
        //
        if (wakeLock == null) {
            wakeLock = Runtime.makeWakeLock();
        }

        //
        // Spawning new Actor for call
        //
        final WakeLock finalWakeLock = wakeLock;
        system().actorOf("alo/call" + RandomUtils.nextRid(), () -> {
            return new CallActor(callId, finalWakeLock, context());
        });

    }

    private void onIncomingCallReady(long callId, ActorRef ref) {


//        ref.send(new CallActor.BusyCall(activeCallData));

        //
        // Saving reference to incoming call
        //
        runningCalls.put(callId, ref);
        //
        // Change Current Call if there are no ongoing calls now
        //
        if (currentCall == null) {
            currentCall = callId;
            provider.onCallStart(callId);

        } else {

            request(new RequestBusyCall(callId));
            Log.d(TAG, "onIncomingCallReady (" + callId + ")");

//            provider.onCallBusy(callId);
        }

//        CallViewModels.

    }

    private void onIncomingCallHandled(long callId) {

        // If We are not answered this call on this device
        if (!answeredCalls.contains(callId)) {

            //
            // Notify provider
            //
            if (currentCall != null && currentCall == callId) {
                currentCall = null;
                provider.onCallEnd(callId);
            }

            //
            // Shutdown call actor
            //
            terminalCall(callId);
        }
    }

    private void doAnswerCall(final long callId) {
        Log.d(TAG, "doAnswerCall (" + callId + ")");

        // If not already answered
        if (!answeredCalls.contains(callId)) {

            //
            // Mark as answered
            //
            answeredCalls.add(callId);

            //
            // Sending answer message to actor.
            //
            ActorRef ref = runningCalls.get(callId);
            if (ref != null) {
                ref.send(new CallActor.AnswerCall());
            }

            //
            // Notify Provider to stop playing ringtone
            //
            if (currentCall != null && currentCall == callId) {
                provider.onCallAnswered(callId);
            }
        }
    }

    private void onCallAnswered(long callId) {
        Log.d(TAG, "onCallAnswered (" + callId + ")");
        if (currentCall == callId) {
            if (isBeeping) {
                isBeeping = false;
                provider.stopOutgoingBeep();
            }

            provider.onCallAnswered(callId);
        }
    }

    //
    // Call AudioEnabled/Unmute
    //
    private void onCallAudioEnable(long callId) {
        ActorRef ref = runningCalls.get(callId);
        if (ref != null) {
            ref.send(new AbsCallActor.AudioEnabled(true));
        }
    }

    private void onCallAudioDisable(long callId) {
        ActorRef ref = runningCalls.get(callId);
        if (ref != null) {
            ref.send(new AbsCallActor.AudioEnabled(false));
        }
    }

    //
    // Call video disable/enable
    //
    private void onCallVideoEnable(long callId) {
        ActorRef ref = runningCalls.get(callId);
        if (ref != null) {
            ref.send(new AbsCallActor.VideoEnabled(true));
        }
    }

    private void onCallVideoDisable(long callId) {
        ActorRef ref = runningCalls.get(callId);
        if (ref != null) {
            ref.send(new AbsCallActor.VideoEnabled(false));
        }
    }

    private void onCallBusy(long callId) {
        ActorRef ref = runningCalls.get(callId);
        if (ref != null) {
//            ref.send(new AbsCallActor.OnCallBusy(true));
//            ref.send(new CallActor.BusyCall(callId));
            ref.send(new CallActor.Busy());
            stop = false;
        }
    }

    public void onCallActive(byte[] data) {

        try {
            apiActiveCall = Bser.parse(new ApiActiveCall(), data);
        } catch (IOException e) {
            e.printStackTrace();
        }

        activeCallData = data;

        List<ApiCallMember> apiCallMember = apiActiveCall.getCallMembers();

        inCallId = apiActiveCall.getCallId();
        Log.d(TAG, "callId (" + apiActiveCall.getCallId() +")");

        for (ApiCallMember b : apiCallMember) {
//            if (b.getUserId() == caleeUser.getPeerId()) {
//                apiCallMemberState = b.getState().getState();
//            }
//            apiCallMember.add(b);

//            List<ApiCallMemberStateHolder> callMemberState = new ArrayList<ApiCallMemberStateHolder>();



//                        apiCallMemberState = Collections.enumeration(callMemberState);
//            List<ApiCallMemberStateHolder> memberState = new ArrayList<>();
//            for (ApiCallMemberStateHolder c : apiCallMemberStateHolder) {
//                apiCallMemberStateHolder.add(c);

//
//            }
//            Log.d(TAG, "onCallActive (" + b.getState().getState().toString() +")");
            Log.d(TAG, "onCallActive (" + b.getState().getState().toString() + " uid " + b.getUserId() +")");

            if (b.getState().getState() == ApiCallMemberState.BUSY) {
                provider.onCallBusy(apiActiveCall.getCallId());
                stop = true;
            }
            if (isMaster) {
                if (b.getState().getState() == ApiCallMemberState.ENDED) {
                    ActorRef ref = runningCalls.get(inCallId);
                    if (ref != null) {
                        stop = false;
                        ref.send(new CallActor.NoAnswer());
                    }
                }
            }
            if (isMaster) {
                Log.d("CallActor", "notAvailable stop: " + stop);

                if (!stop) {
                    if (b.getState().getState() == ApiCallMemberState.RINGING) {
                        ActorRef ref = runningCalls.get(inCallId);
                        if (ref != null) {
//                            try {
//                                while (!stop) {
//                                    stop = true;
//                                    TimeUnit.SECONDS.sleep(14);
//                                    ref.send(new CallActor.NotAvailable());
//                                }
                                //                        }
//                            } catch (InterruptedException e) {
//                                e.printStackTrace();
//                            }
                        }


                    }
                } else {
//                provider.onCallBusy(apiActiveCall.getCallId());
                }
            }

        }

    }

    //
    // Ending call
    //

    private void onCallEnded(long callId) {
        Log.d(TAG, "onCallEnded (" + callId + ")");

        //
        // Event ALWAYS comes from Call Actor and we doesn't need
        // to stop it explicitly.
        //
        // Removing from running calls
        //
        runningCalls.remove(callId);
        stop = false;
        //
        // Notify Provider if this call was current
        //
        if (currentCall != null && currentCall == callId) {
            currentCall = null;
            provider.onCallEnd(callId);
            if (isBeeping) {
                isBeeping = false;
                provider.stopOutgoingBeep();
            }
        }
    }

    private void doEndCall(long callId) {
        Log.d(TAG, "doEndCall (" + callId + ")");

        //
        // Action ALWAYS comes from UI side and we need only stop call actor
        // explicitly and it will do the rest.
        //
        ActorRef currentCallActor = runningCalls.remove(callId);
        if (currentCallActor != null) {
            if (answeredCalls.contains(callId)) {
                currentCallActor.send(PoisonPill.INSTANCE);
            } else {
                currentCallActor.send(new CallActor.RejectCall());
            }
        }

        //
        // Notify Provider if this call was current
        //
        if (currentCall != null && currentCall == callId) {
            currentCall = null;
            provider.onCallEnd(callId);
            if (isBeeping) {
                isBeeping = false;
                provider.stopOutgoingBeep();
            }
        }
    }

    private void probablyEndCall() {
        if (currentCall != null) {
            doEndCall(currentCall);
        }
    }

    private void terminalCall(long callId) {
        ActorRef dest = runningCalls.remove(callId);
        if (dest != null) {
            dest.send(PoisonPill.INSTANCE);
        }
    }

    private void sendToCall(long callId, Object message) {
        ActorRef dest = runningCalls.get(callId);
        if (dest != null) {
            dest.send(message);
        }
    }


    //
    // Messages
    //

    @Override
    public void onReceive(Object message) {
        if (message instanceof OnIncomingCall) {
            OnIncomingCall call = (OnIncomingCall) message;
            onIncomingCall(call.getCallId(), call.getAttempt(), null);
        } else if (message instanceof OnIncomingCallLocked) {
            OnIncomingCallLocked locked = (OnIncomingCallLocked) message;
            onIncomingCall(locked.getCallId(), locked.getAttempt(), locked.getWakeLock());
        } else if (message instanceof OnIncomingCallHandled) {
            OnIncomingCallHandled incomingCallHandled = (OnIncomingCallHandled) message;
            onIncomingCallHandled(incomingCallHandled.getCallId());
        } else if (message instanceof DoAnswerCall) {
            doAnswerCall(((DoAnswerCall) message).getCallId());
        } else if (message instanceof DoEndCall) {
            doEndCall(((DoEndCall) message).getCallId());
        } else if (message instanceof OnCallEnded) {
            onCallEnded(((OnCallEnded) message).getCallId());
        } else if (message instanceof DoCall) {
            DoCall doCall = (DoCall) message;
            doCall(doCall.getPeer(), doCall.getCallback(), doCall.isEnableVideoCall(), doCall.isBusy());
        } else if (message instanceof DoCallComplete) {
            DoCallComplete callCreated = (DoCallComplete) message;
            onCallCreated(callCreated.getCallId(), sender());
        } else if (message instanceof IncomingCallReady) {
            IncomingCallReady callComplete = (IncomingCallReady) message;
            onIncomingCallReady(callComplete.getCallId(), sender());
        } else if (message instanceof OnCallAnswered) {
            OnCallAnswered answered = (OnCallAnswered) message;
            onCallAnswered(answered.getCallId());
        } else if (message instanceof AudioDisable) {
            onCallAudioDisable(((AudioDisable) message).getCallId());
        } else if (message instanceof AudioEnable) {
            onCallAudioEnable(((AudioEnable) message).getCallId());
        } else if (message instanceof DisableVideo) {
            onCallVideoDisable(((DisableVideo) message).getCallId());
        } else if (message instanceof EnableVideo) {
            onCallVideoEnable(((EnableVideo) message).getCallId());
        } else if (message instanceof CallBusy) {
            onCallBusy(((CallBusy) message).getCallId());
        } else if (message instanceof ActiveCall) {
            onCallActive(((ActiveCall) message).getData());
        } else if (message instanceof ProbablyEndCall) {
            probablyEndCall();
        } else {
            super.onReceive(message);
        }
    }

    public static class OnIncomingCall {

        private long callId;
        private int attempt;

        public OnIncomingCall(long callId, int attempt) {
            this.callId = callId;
            this.attempt = attempt;
        }

        public long getCallId() {
            return callId;
        }

        public int getAttempt() {
            return attempt;
        }
    }

    public static class OnIncomingCallLocked {

        private long callId;
        private int attempt;
        private WakeLock wakeLock;

        public OnIncomingCallLocked(long callId, int attempt, WakeLock wakeLock) {
            this.callId = callId;
            this.wakeLock = wakeLock;
            this.attempt = attempt;
        }

        public long getCallId() {
            return callId;
        }

        public WakeLock getWakeLock() {
            return wakeLock;
        }

        public int getAttempt() {
            return attempt;
        }
    }

    public static class OnIncomingCallHandled {

        private long callId;
        private int attempt;

        public OnIncomingCallHandled(long callId, int attempt) {
            this.callId = callId;
            this.attempt = attempt;
        }

        public int getAttempt() {
            return attempt;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class OnCallEnded {
        private long callId;

        public OnCallEnded(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class DoAnswerCall {

        private long callId;

        public DoAnswerCall(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class DoEndCall {
        private long callId;

        public DoEndCall(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }


    //
    // Call State
    //

    public static class AudioEnable {
        private long callId;

        public AudioEnable(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class AudioDisable {
        private long callId;

        public AudioDisable(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class DisableVideo {
        private long callId;

        public DisableVideo(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class EnableVideo {
        private long callId;

        public EnableVideo(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class ActiveCall {

        private byte[] data;

        public ActiveCall(byte[] data) {
            this.data = data;
        }

        public byte[] getData() {
            return data;
        }

    }

    public static class CallBusy {
        private long callId;

        public CallBusy(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    //
    // Call Start
    //

    public static class DoCall {

        private Peer peer;
        private CommandCallback<Long> callback;
        private boolean enableVideoCall;
        private boolean isBusy;

        public DoCall(Peer peer, CommandCallback<Long> callback, boolean enableVideoCall, boolean isBusy) {
            this.peer = peer;
            this.callback = callback;
            this.enableVideoCall = enableVideoCall;
            this.isBusy = isBusy;
        }

        public CommandCallback<Long> getCallback() {
            return callback;
        }

        public Peer getPeer() {
            return peer;
        }

        public boolean isEnableVideoCall() {
            return enableVideoCall;
        }

        public boolean isBusy() {
            return isBusy;
        }
    }

    public static class DoCallComplete {

        private long callId;

        public DoCallComplete(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class OnCallAnswered {
        private long callId;

        public OnCallAnswered(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class IncomingCallReady {
        private long callId;

        public IncomingCallReady(long callId) {
            this.callId = callId;
        }

        public long getCallId() {
            return callId;
        }
    }

    public static class ProbablyEndCall {

    }
}
