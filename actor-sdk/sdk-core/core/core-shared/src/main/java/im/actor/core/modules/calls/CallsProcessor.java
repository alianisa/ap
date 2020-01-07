package im.actor.core.modules.calls;

import im.actor.core.api.ApiActiveCall;
import im.actor.core.api.ApiSyncedValue;
import im.actor.core.api.ApiWebRTCSignaling;
import im.actor.core.api.updates.UpdateCallHandled;
import im.actor.core.api.updates.UpdateIncomingCall;
import im.actor.core.api.updates.UpdateSyncedSetAddedOrUpdated;
import im.actor.core.modules.ModuleContext;
import im.actor.core.modules.sequence.processor.WeakProcessor;
import im.actor.core.network.parser.Update;
import im.actor.runtime.Log;
import im.actor.runtime.bser.Bser;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class CallsProcessor implements WeakProcessor {

    private ModuleContext context;

    public CallsProcessor(ModuleContext context) {
        this.context = context;
    }

    private byte[] data;
    private ApiActiveCall apiActiveCall;

    @Override
    public boolean process(Update update, long date) {
        if (update instanceof UpdateSyncedSetAddedOrUpdated) {
            UpdateSyncedSetAddedOrUpdated updateSyncedSetAddedOrUpdated = (UpdateSyncedSetAddedOrUpdated) update;
            List<ApiSyncedValue> apiSyncedValues = updateSyncedSetAddedOrUpdated.getAddedOrUpdatedValues();

            for (ApiSyncedValue a : apiSyncedValues) {
                apiSyncedValues.add(a);
                data = a.getValue();
            }

            try {
                apiActiveCall = Bser.parse(new ApiActiveCall(), data);
            } catch (IOException e) {
                e.printStackTrace();
            }



            context.getCallsModule().getCallManager().send(new CallManagerActor.ActiveCall(data));



            Log.d("CallsProcessor", "onReceive Synced UpdateSyncedSetAddedOrUpdated:" + apiActiveCall.getCallMembers());


        } else if (update instanceof UpdateIncomingCall) {
            UpdateIncomingCall updateIncomingCall = (UpdateIncomingCall) update;
            if (context.getConfiguration().isVoiceCallsEnabled()) {
                int index = updateIncomingCall.getAttemptIndex() != null ? updateIncomingCall.getAttemptIndex() : 0;
                context.getCallsModule().getCallManager().send(
                        new CallManagerActor.OnIncomingCall(
                                updateIncomingCall.getCallId(),
                                index));
            }
            return true;
        } else if (update instanceof UpdateCallHandled) {
            UpdateCallHandled updateCallHandled = (UpdateCallHandled) update;
            if (context.getConfiguration().isVoiceCallsEnabled()) {
                int index = updateCallHandled.getAttemptIndex() != null ? updateCallHandled.getAttemptIndex() : 0;
                context.getCallsModule().getCallManager().send(
                        new CallManagerActor.OnIncomingCallHandled(
                                updateCallHandled.getCallId(),
                                index));
            }
            return true;
        }
        return false;
    }
}