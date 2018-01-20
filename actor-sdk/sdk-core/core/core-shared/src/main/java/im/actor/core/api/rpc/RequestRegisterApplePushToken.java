package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;

import im.actor.core.network.parser.Request;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class RequestRegisterApplePushToken extends Request<ResponseVoid> {

    public static final int HEADER = 0xa21;

    public static RequestRegisterApplePushToken fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestRegisterApplePushToken(), data);
    }

    private String bundleId;
    private String token;

    public RequestRegisterApplePushToken(@NotNull String bundleId, @NotNull String token) {
        this.bundleId = bundleId;
        this.token = token;
    }

    public RequestRegisterApplePushToken() {

    }

    @NotNull
    public String getBundleId() {
        return this.bundleId;
    }

    @NotNull
    public String getToken() {
        return this.token;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.bundleId = values.getString(1);
        this.token = values.getString(2);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.bundleId == null) {
            throw new IOException();
        }
        writer.writeString(1, this.bundleId);
        if (this.token == null) {
            throw new IOException();
        }
        writer.writeString(2, this.token);
    }

    @Override
    public String toString() {
        String res = "rpc RegisterApplePushToken{";
        res += "bundleId=" + this.bundleId;
        res += ", token=" + this.token;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
