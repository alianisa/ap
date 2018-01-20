package im.actor.core.api.rpc;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import im.actor.core.api.ApiDialog;
import im.actor.core.api.ApiGroup;
import im.actor.core.api.ApiGroupOutPeer;
import im.actor.core.api.ApiUser;
import im.actor.core.api.ApiUserOutPeer;
import im.actor.core.network.parser.Response;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class ResponseLoadDialogs extends Response {

    public static final int HEADER = 0x69;

    public static ResponseLoadDialogs fromBytes(byte[] data) throws IOException {
        return Bser.parse(new ResponseLoadDialogs(), data);
    }

    private List<ApiGroup> groups;
    private List<ApiUser> users;
    private List<ApiDialog> dialogs;
    private List<ApiUserOutPeer> userPeers;
    private List<ApiGroupOutPeer> groupPeers;

    public ResponseLoadDialogs(@NotNull List<ApiGroup> groups, @NotNull List<ApiUser> users, @NotNull List<ApiDialog> dialogs, @NotNull List<ApiUserOutPeer> userPeers, @NotNull List<ApiGroupOutPeer> groupPeers) {
        this.groups = groups;
        this.users = users;
        this.dialogs = dialogs;
        this.userPeers = userPeers;
        this.groupPeers = groupPeers;
    }

    public ResponseLoadDialogs() {

    }

    @NotNull
    public List<ApiGroup> getGroups() {
        return this.groups;
    }

    @NotNull
    public List<ApiUser> getUsers() {
        return this.users;
    }

    @NotNull
    public List<ApiDialog> getDialogs() {
        return this.dialogs;
    }

    @NotNull
    public List<ApiUserOutPeer> getUserPeers() {
        return this.userPeers;
    }

    @NotNull
    public List<ApiGroupOutPeer> getGroupPeers() {
        return this.groupPeers;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        List<ApiGroup> _groups = new ArrayList<ApiGroup>();
        for (int i = 0; i < values.getRepeatedCount(1); i++) {
            _groups.add(new ApiGroup());
        }
        this.groups = values.getRepeatedObj(1, _groups);
        List<ApiUser> _users = new ArrayList<ApiUser>();
        for (int i = 0; i < values.getRepeatedCount(2); i++) {
            _users.add(new ApiUser());
        }
        this.users = values.getRepeatedObj(2, _users);
        List<ApiDialog> _dialogs = new ArrayList<ApiDialog>();
        for (int i = 0; i < values.getRepeatedCount(3); i++) {
            _dialogs.add(new ApiDialog());
        }
        this.dialogs = values.getRepeatedObj(3, _dialogs);
        List<ApiUserOutPeer> _userPeers = new ArrayList<ApiUserOutPeer>();
        for (int i = 0; i < values.getRepeatedCount(4); i++) {
            _userPeers.add(new ApiUserOutPeer());
        }
        this.userPeers = values.getRepeatedObj(4, _userPeers);
        List<ApiGroupOutPeer> _groupPeers = new ArrayList<ApiGroupOutPeer>();
        for (int i = 0; i < values.getRepeatedCount(5); i++) {
            _groupPeers.add(new ApiGroupOutPeer());
        }
        this.groupPeers = values.getRepeatedObj(5, _groupPeers);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeRepeatedObj(1, this.groups);
        writer.writeRepeatedObj(2, this.users);
        writer.writeRepeatedObj(3, this.dialogs);
        writer.writeRepeatedObj(4, this.userPeers);
        writer.writeRepeatedObj(5, this.groupPeers);
    }

    @Override
    public String toString() {
        String res = "tuple LoadDialogs{";
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
