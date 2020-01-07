package im.actor.sdk;

import android.app.Application;

import im.actor.core.AndroidMessenger;
import im.actor.core.ConfigurationBuilder;

/**
 * Created by diego on 26/05/17.
 */

public interface ActorSDKCreateListener {
    void onCreateActor(final Application application);
    AndroidMessenger createMessenger(Application application, ConfigurationBuilder builder);
}
