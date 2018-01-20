package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.IOException;

import im.actor.core.api.ApiMessage;
import im.actor.core.api.ApiMessageOutReference;
import im.actor.core.api.ApiOutPeer;
import im.actor.core.network.parser.Request;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class RequestSendMessage extends Request<ResponseSeqDate> {

    public static final int HEADER = 0x5c;

    public static RequestSendMessage fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestSendMessage(), data);
    }

    private ApiOutPeer peer;
    private long rid;
    private ApiMessage message;
    private Integer isOnlyForUser;
    private ApiMessageOutReference quotedMessageReference;

    public RequestSendMessage(@NotNull ApiOutPeer peer, long rid, @NotNull ApiMessage message, @Nullable Integer isOnlyForUser, @Nullable ApiMessageOutReference quotedMessageReference) {
        this.peer = peer;
        this.rid = rid;
        this.message = message;
        this.isOnlyForUser = isOnlyForUser;
        this.quotedMessageReference = quotedMessageReference;
    }

    public RequestSendMessage() {

    }

    @NotNull
    public ApiOutPeer getPeer() {
        return this.peer;
    }

    public long getRid() {
        return this.rid;
    }

    @NotNull
    public ApiMessage getMessage() {
        return this.message;
    }

    @Nullable
    public Integer getIsOnlyForUser() {
        return this.isOnlyForUser;
    }

    @Nullable
    public ApiMessageOutReference getQuotedMessageReference() {
        return this.quotedMessageReference;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.peer = values.getObj(1, new ApiOutPeer());
        this.rid = values.getLong(3);
        this.message = ApiMessage.fromBytes(values.getBytes(4));
        this.isOnlyForUser = values.optInt(5);
        this.quotedMessageReference = values.optObj(6, new ApiMessageOutReference());
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.peer == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.peer);
        writer.writeLong(3, this.rid);
        if (this.message == null) {
            throw new IOException();
        }

        writer.writeBytes(4, this.message.buildContainer());
        if (this.isOnlyForUser != null) {
            writer.writeInt(5, this.isOnlyForUser);
        }
        if (this.quotedMessageReference != null) {
            writer.writeObject(6, this.quotedMessageReference);
        }
    }

    @Override
    public String toString() {
        String res = "rpc SendMessage{";
        res += "peer=" + this.peer;
        res += ", rid=" + this.rid;
        res += ", message=" + this.message;
        res += ", isOnlyForUser=" + this.isOnlyForUser;
        res += ", quotedMessageReference=" + this.quotedMessageReference;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
