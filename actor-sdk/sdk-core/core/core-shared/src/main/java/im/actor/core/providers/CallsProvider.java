package im.actor.core.providers;

import com.google.j2objc.annotations.ObjectiveCName;

/**
 * WebRTC provider. Used for providing Calls support.
 * All methods except init are called in background call management actor.
 * IMPORTANT: Right after "onCallEnd" called you need to stop sending any signaling messages.
 * Between onIncomingCall/onOutgoingCall and onCallEnd all methods are called with the same call id.
 */
public interface CallsProvider {

    /**
     * Call event. This doesn't mean that call is started.
     *
     * @param callId Unique Call Id
     */
    @ObjectiveCName("onCallStartWithCallId:")
    void onCallStart(long callId);

    /**
     * Call Answered Event
     *
     * @param callId Unique Call Id
     */
    @ObjectiveCName("onCallAnsweredWithCallId:")
    void onCallAnswered(long callId);

    /**
     * Call End event
     *
     * @param callId Unique Call Id
     */
    @ObjectiveCName("onCallEndWithCallId:")
    void onCallEnd(long callId);

    /**
     * Call Busy event
     *
     * @param callId Unique Call Id
     */
    @ObjectiveCName("onCallBusyWithCallId:")
    void onCallBusy(long callId);

    /**
     * Event When outgoing beep need to start
     */
    @ObjectiveCName("startOutgoingBeep")
    void startOutgoingBeep(boolean connected);

    /**
     * Event when outgoing beep need to stop
     */
    @ObjectiveCName("stopOutgoingBeep")
    void stopOutgoingBeep();
}