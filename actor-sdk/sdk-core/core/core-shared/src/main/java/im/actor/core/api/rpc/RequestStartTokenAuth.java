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

public class RequestStartTokenAuth extends Request<ResponseAuth> {

    public static final int HEADER = 0xcb;
    public static RequestStartTokenAuth fromBytes(byte[] data) throws IOException {
        return Bser.parse(new RequestStartTokenAuth(), data);
    }

    private String token;
    private int appId;
    private String apiKey;
    private byte[] deviceHash;
    private String deviceTitle;
    private String deviceIpAddress;
    private String deviceLocation;
    private String deviceOS;
    private String timeZone;
    private List<String> preferredLanguages;

    public RequestStartTokenAuth(@NotNull String token, int appId, @NotNull String apiKey, @NotNull byte[] deviceHash, @NotNull String deviceTitle, @NotNull String deviceIpAddress, @NotNull String deviceLocation, @NotNull String deviceOS, @Nullable String timeZone, @NotNull List<String> preferredLanguages) {
        this.token = token;
        this.appId = appId;
        this.apiKey = apiKey;
        this.deviceHash = deviceHash;
        this.deviceTitle = deviceTitle;
        this.deviceIpAddress = deviceIpAddress;
        this.deviceLocation = deviceLocation;
        this.deviceOS = deviceOS;
        this.timeZone = timeZone;
        this.preferredLanguages = preferredLanguages;
    }

    public RequestStartTokenAuth() {

    }

    @NotNull
    public String getToken() {
        return this.token;
    }

    public int getAppId() {
        return this.appId;
    }

    @NotNull
    public String getApiKey() {
        return this.apiKey;
    }

    @NotNull
    public byte[] getDeviceHash() {
        return this.deviceHash;
    }

    @NotNull
    public String getDeviceTitle() {
        return this.deviceTitle;
    }

    @NotNull
    public String getDeviceIpAddress() {
        return this.deviceIpAddress;
    }

    @NotNull
    public String getDeviceLocation() {
        return this.deviceLocation;
    }

    @NotNull
    public String getDeviceOS() {
        return this.deviceOS;
    }

    @Nullable
    public String getTimeZone() {
        return this.timeZone;
    }

    @NotNull
    public List<String> getPreferredLanguages() {
        return this.preferredLanguages;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.token = values.getString(1);
        this.appId = values.getInt(2);
        this.apiKey = values.getString(3);
        this.deviceHash = values.getBytes(4);
        this.deviceTitle = values.getString(5);
        this.deviceIpAddress = values.getString(6);
        this.deviceLocation = values.getString(7);
        this.deviceOS = values.getString(8);
        this.timeZone = values.optString(9);
        this.preferredLanguages = values.getRepeatedString(10);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.token == null) {
            throw new IOException();
        }
        writer.writeString(1, this.token);
        writer.writeInt(2, this.appId);
        if (this.apiKey == null) {
            throw new IOException();
        }
        writer.writeString(3, this.apiKey);
        if (this.deviceHash == null) {
            throw new IOException();
        }
        writer.writeBytes(4, this.deviceHash);
        if (this.deviceTitle == null) {
            throw new IOException();
        }
        writer.writeString(5, this.deviceTitle);
        if (this.deviceIpAddress == null) {
            throw new IOException();
        }
        writer.writeString(6, this.deviceIpAddress);
        if (this.deviceLocation == null) {
            throw new IOException();
        }
        writer.writeString(7, this.deviceLocation);
        if (this.deviceOS == null) {
            throw new IOException();
        }
        writer.writeString(8, this.deviceOS);
        if (this.timeZone != null) {
            writer.writeString(9, this.timeZone);
        }
        writer.writeRepeatedString(10, this.preferredLanguages);
    }

    @Override
    public String toString() {
        String res = "rpc StartTokenAuth{";
        res += "token=" + this.token;
        res += ", deviceHash=" + byteArrayToString(this.deviceHash);
        res += ", deviceTitle=" + this.deviceTitle;
        res += ", deviceIpAddress=" + this.deviceIpAddress;
        res += ", deviceLocation=" + this.deviceLocation;
        res += ", deviceOS=" + this.deviceOS;
        res += ", timeZone=" + this.timeZone;
        res += ", preferredLanguages=" + this.preferredLanguages;
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
