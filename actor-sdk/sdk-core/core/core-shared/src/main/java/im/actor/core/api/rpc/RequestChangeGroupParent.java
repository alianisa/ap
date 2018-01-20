package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import java.io.IOException;

import im.actor.core.network.parser.Request;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class RequestChangeGroupParent extends Request<ResponseSeq> {

    public static final int HEADER = 0x22;

    public static RequestChangeGroupParent fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestChangeGroupParent(), data);
    }

    private int groupId;
    private int parentId;

    public RequestChangeGroupParent(int groupId, int parentId) {
        this.groupId = groupId;
        this.parentId = parentId;
    }

    public RequestChangeGroupParent() {

    }

    public int getGroupId() {
        return this.groupId;
    }

    public int getParentId() {
        return this.parentId;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.groupId = values.getInt(1);
        this.parentId = values.getInt(2);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeInt(1, this.groupId);
        writer.writeInt(2, this.parentId);
    }

    @Override
    public String toString() {
        String res = "rpc ChangeGroupParent{";
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
