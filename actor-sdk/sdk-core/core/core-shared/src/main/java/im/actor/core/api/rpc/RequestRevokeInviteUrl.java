package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;

import im.actor.core.api.ApiGroupOutPeer;
import im.actor.core.network.parser.Request;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class RequestRevokeInviteUrl extends Request<ResponseInviteUrl> {

    public static final int HEADER = 0xb3;

    public static RequestRevokeInviteUrl fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestRevokeInviteUrl(), data);
    }

    private ApiGroupOutPeer groupPeer;

    public RequestRevokeInviteUrl(@NotNull ApiGroupOutPeer groupPeer) {
        this.groupPeer = groupPeer;
    }

    public RequestRevokeInviteUrl() {

    }

    @NotNull
    public ApiGroupOutPeer getGroupPeer() {
        return this.groupPeer;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.groupPeer = values.getObj(1, new ApiGroupOutPeer());
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.groupPeer == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.groupPeer);
    }

    @Override
    public String toString() {
        String res = "rpc RevokeInviteUrl{";
        res += "groupPeer=" + this.groupPeer;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
