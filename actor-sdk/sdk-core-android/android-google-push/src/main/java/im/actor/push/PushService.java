package im.actor.push;

//import android.os.Bundle;
//
//import com.google.android.gms.gcm.GcmListenerService;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

import im.actor.runtime.Log;
import im.actor.sdk.ActorSDK;

/**
 * Created by diego on 25/06/17.
 */

public class PushService extends FirebaseMessagingService {

    private static final String TAG = "ActorPushReceiver";

    @Override
    public void onMessageReceived(RemoteMessage message) {
        Map extras = message.getData();
        Log.d(TAG, "onMessageReceived");
        if (!extras.isEmpty()) {
            Log.d(TAG, "Extras not empty");
            ActorSDK.sharedActor().waitForReady();
            if (extras.containsKey("seq")) {
                int seq = Integer.parseInt(extras.get("seq").toString());
                long authId = Long.parseLong(extras.get("_authId").toString());
                Log.d(TAG, "Push received #" + seq);
                ActorSDK.sharedActor().getMessenger().onPushReceived(seq, authId);
            } else if (extras.containsKey("callId")) {
                long callId = Long.parseLong(extras.get("callId").toString());
                int attempt = 0;
                if (extras.containsKey("attemptIndex")) {
                    attempt = Integer.parseInt(extras.get("attemptIndex").toString());
                }
                Log.d(TAG, "Received Call #" + callId + " (" + attempt + ")");
                ActorSDK.sharedActor().getMessenger().checkCall(callId, attempt);
            }
        }
    }
}
