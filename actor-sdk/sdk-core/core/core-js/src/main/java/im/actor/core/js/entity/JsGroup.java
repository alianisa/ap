/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.js.entity;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;

import im.actor.core.entity.Avatar;
import im.actor.core.entity.GroupMember;
import im.actor.core.entity.Peer;
import im.actor.core.js.JsMessenger;
import im.actor.core.viewmodel.GroupVM;

public class JsGroup extends JavaScriptObject {

    public static JsGroup fromGroupVM(GroupVM groupVM, JsMessenger messenger) {
        int online = groupVM.getPresence().get();
        String presence = messenger.getFormatter().formatGroupMembers(groupVM.getMembersCount().get());
        if (online > 0) {
            presence += ", " + messenger.getFormatter().formatGroupOnline(online);
        }
        String fileUrl = null;
        String bigFileUrl = null;
        Avatar avatar = groupVM.getAvatar().get();
        if (avatar != null) {
            if (avatar.getSmallImage() != null) {
                fileUrl = messenger.getFileUrl(avatar.getSmallImage().getFileReference());
            }
            if (avatar.getLargeImage() != null) {
                bigFileUrl = messenger.getFileUrl(avatar.getLargeImage().getFileReference());
            }
        }

        ArrayList<JsGroupMember> convertedMembers = new ArrayList<JsGroupMember>();
        HashSet<GroupMember> groupMembers = groupVM.getMembers().get();
        GroupMember[] members = groupMembers.toArray(new GroupMember[groupMembers.size()]);

        int myUid = messenger.myUid();
        for (GroupMember g : members) {
            JsPeerInfo peerInfo = messenger.buildPeerInfo(Peer.user(g.getUid()));
            convertedMembers.add(JsGroupMember.create(peerInfo, g.isAdministrator(),
                    g.getInviterUid() == myUid));
        }

        Collections.sort(convertedMembers,
                (o1, o2) -> o1.getPeerInfo().getTitle().compareToIgnoreCase(o2.getPeerInfo().getTitle()));

        JsArray<JsGroupMember> jsMembers = JsArray.createArray().cast();
        for (JsGroupMember member : convertedMembers) {
            jsMembers.push(member);
        }

        return create(groupVM.getId(), groupVM.getName().get(), groupVM.getAbout().get(), fileUrl, bigFileUrl,
                Placeholders.getPlaceholder(groupVM.getId()), presence, groupVM.getOwnerId().get(),
                jsMembers, groupVM.isMember().get(), groupVM.getShortName().get(),
                groupVM.getIsCanEditAdministration().get(), groupVM.getRestrictedDomains().get());
    }

    public static native JsGroup create(int id, String name, String about, String avatar, String bigAvatar,
                                        String placeholder, String presence, int ownerId,
                                        JsArray<JsGroupMember> members, boolean isMember,
                                        String shortName, boolean isCanEditAdministration,
                                        String restrictedDomains)/*-{
        return {
            id: id, name: name, about: about, avatar: avatar, bigAvatar: bigAvatar, placeholder: placeholder,
            presence: presence, ownerId:ownerId, members: members, isMember: isMember, shortName: shortName,
            isCanEditAdministration: isCanEditAdministration, restrictedDomains: restrictedDomains
        };
    }-*/;

    protected JsGroup() {

    }

    public native final int getGid()/*-{
        return this.id;
    }-*/;
}
