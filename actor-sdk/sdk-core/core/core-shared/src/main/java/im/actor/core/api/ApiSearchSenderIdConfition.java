package im.actor.core.api;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import java.io.IOException;

import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class ApiSearchSenderIdConfition extends ApiSearchCondition {

    private int senderId;

    public ApiSearchSenderIdConfition(int senderId) {
        this.senderId = senderId;
    }

    public ApiSearchSenderIdConfition() {

    }

    public int getHeader() {
        return 7;
    }

    public int getSenderId() {
        return this.senderId;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.senderId = values.getInt(1);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeInt(1, this.senderId);
    }

    @Override
    public String toString() {
        String res = "struct SearchSenderIdConfition{";
        res += "senderId=" + this.senderId;
        res += "}";
        return res;
    }

}
