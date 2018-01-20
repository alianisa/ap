package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import im.actor.core.api.ApiAuthSession;
import im.actor.core.network.parser.Response;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class ResponseGetAuthSessions extends Response {

    public static final int HEADER = 0x51;

    public static ResponseGetAuthSessions fromBytes(byte[] data) throws IOException {
        return Bser.parse(new ResponseGetAuthSessions(), data);
    }

    private List<ApiAuthSession> userAuths;

    public ResponseGetAuthSessions(@NotNull List<ApiAuthSession> userAuths) {
        this.userAuths = userAuths;
    }

    public ResponseGetAuthSessions() {

    }

    @NotNull
    public List<ApiAuthSession> getUserAuths() {
        return this.userAuths;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        List<ApiAuthSession> _userAuths = new ArrayList<ApiAuthSession>();
        for (int i = 0; i < values.getRepeatedCount(1); i++) {
            _userAuths.add(new ApiAuthSession());
        }
        this.userAuths = values.getRepeatedObj(1, _userAuths);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeRepeatedObj(1, this.userAuths);
    }

    @Override
    public String toString() {
        String res = "tuple GetAuthSessions{";
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
