package im.actor.core.api.updates;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.List;

import im.actor.core.api.ApiPeer;
import im.actor.core.network.parser.Update;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class UpdateMessageDelete extends Update {

    public static final int HEADER = 0x2e;

    public static UpdateMessageDelete fromBytes(byte[] data) throws IOException {
        return Bser.parse(new UpdateMessageDelete(), data);
    }

    private ApiPeer peer;
    private List<Long> rids;

    public UpdateMessageDelete(@NotNull ApiPeer peer, @NotNull List<Long> rids) {
        this.peer = peer;
        this.rids = rids;
    }

    public UpdateMessageDelete() {

    }

    @NotNull
    public ApiPeer getPeer() {
        return this.peer;
    }

    @NotNull
    public List<Long> getRids() {
        return this.rids;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.peer = values.getObj(1, new ApiPeer());
        this.rids = values.getRepeatedLong(2);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.peer == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.peer);
        writer.writeRepeatedLong(2, this.rids);
    }

    @Override
    public String toString() {
        String res = "update MessageDelete{";
        res += "peer=" + this.peer;
        res += ", rids=" + this.rids;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
