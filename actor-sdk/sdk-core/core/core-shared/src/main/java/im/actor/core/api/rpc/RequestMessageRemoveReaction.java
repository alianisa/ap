package im.actor.core.api.rpc;
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
import im.actor.core.api.*;

public class RequestMessageRemoveReaction extends Request<ResponseReactionsResponse> {

    public static final int HEADER = 0xdc;
    public static RequestMessageRemoveReaction fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestMessageRemoveReaction(), data);
    }

    private ApiOutPeer peer;
    private long rid;
    private String code;

    public RequestMessageRemoveReaction(@NotNull ApiOutPeer peer, long rid, @NotNull String code) {
        this.peer = peer;
        this.rid = rid;
        this.code = code;
    }

    public RequestMessageRemoveReaction() {

    }

    @NotNull
    public ApiOutPeer getPeer() {
        return this.peer;
    }

    public long getRid() {
        return this.rid;
    }

    @NotNull
    public String getCode() {
        return this.code;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.peer = values.getObj(1, new ApiOutPeer());
        this.rid = values.getLong(2);
        this.code = values.getString(3);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.peer == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.peer);
        writer.writeLong(2, this.rid);
        if (this.code == null) {
            throw new IOException();
        }
        writer.writeString(3, this.code);
    }

    @Override
    public String toString() {
        String res = "rpc MessageRemoveReaction{";
        res += "peer=" + this.peer;
        res += ", rid=" + this.rid;
        res += ", code=" + this.code;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
