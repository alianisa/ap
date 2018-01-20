package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;

import im.actor.core.api.ApiOutPeer;
import im.actor.core.api.ApiTypingType;
import im.actor.core.network.parser.Request;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class RequestTyping extends Request<ResponseVoid> {

    public static final int HEADER = 0x1b;

    public static RequestTyping fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestTyping(), data);
    }

    private ApiOutPeer peer;
    private ApiTypingType typingType;

    public RequestTyping(@NotNull ApiOutPeer peer, @NotNull ApiTypingType typingType) {
        this.peer = peer;
        this.typingType = typingType;
    }

    public RequestTyping() {

    }

    @NotNull
    public ApiOutPeer getPeer() {
        return this.peer;
    }

    @NotNull
    public ApiTypingType getTypingType() {
        return this.typingType;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.peer = values.getObj(1, new ApiOutPeer());
        this.typingType = ApiTypingType.parse(values.getInt(3));
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.peer == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.peer);
        if (this.typingType == null) {
            throw new IOException();
        }
        writer.writeInt(3, this.typingType.getValue());
    }

    @Override
    public String toString() {
        String res = "rpc Typing{";
        res += "peer=" + this.peer;
        res += ", typingType=" + this.typingType;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
