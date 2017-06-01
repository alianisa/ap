package im.actor.core.api;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import im.actor.runtime.bser.*;
import im.actor.runtime.collections.*;
import static im.actor.runtime.bser.Utils.*;
import im.actor.core.network.parser.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;
import com.google.j2objc.annotations.ObjectiveCName;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

public class ApiNeedOffer extends ApiWebRTCSignaling {

    private long device;
    private long sessionId;
    private ApiPeerSettings peerSettings;

    public ApiNeedOffer(long device, long sessionId, @Nullable ApiPeerSettings peerSettings) {
        this.device = device;
        this.sessionId = sessionId;
        this.peerSettings = peerSettings;
    }

    public ApiNeedOffer() {

    }

    public int getHeader() {
        return 8;
    }

    public long getDevice() {
        return this.device;
    }

    public long getSessionId() {
        return this.sessionId;
    }

    @Nullable
    public ApiPeerSettings getPeerSettings() {
        return this.peerSettings;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.device = values.getLong(1);
        this.sessionId = values.getLong(2);
        this.peerSettings = values.optObj(3, new ApiPeerSettings());
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeLong(1, this.device);
        writer.writeLong(2, this.sessionId);
        if (this.peerSettings != null) {
            writer.writeObject(3, this.peerSettings);
        }
    }

    @Override
    public String toString() {
        String res = "struct NeedOffer{";
        res += "device=" + this.device;
        res += ", sessionId=" + this.sessionId;
        res += ", peerSettings=" + this.peerSettings;
        res += "}";
        return res;
    }

}
