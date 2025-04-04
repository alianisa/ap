/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.modules.conductor;

import java.util.HashMap;

import im.actor.core.entity.Contact;
import im.actor.core.entity.Dialog;
import im.actor.core.entity.GroupPre;
import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.core.entity.SearchEntity;
import im.actor.core.modules.AbsModule;
import im.actor.core.modules.ModuleContext;
import im.actor.runtime.Storage;
import im.actor.runtime.mvvm.PlatformDisplayList;

public class DisplayLists extends AbsModule {

    private PlatformDisplayList<Dialog> dialogGlobalList;
    private PlatformDisplayList<Contact> contactsGlobalList;

    private HashMap<Peer, PlatformDisplayList<Message>> chatsGlobalLists = new HashMap<>();
    private HashMap<Peer, PlatformDisplayList<Message>> chatsDocsGlobalLists = new HashMap<>();
    private HashMap<Peer, PlatformDisplayList<Message>> chatsPhotosGlobalLists = new HashMap<>();
    private HashMap<Peer, PlatformDisplayList<Message>> chatsVideosGlobalLists = new HashMap<>();

    private HashMap<Integer, PlatformDisplayList<GroupPre>> groupspreGlobalLists = new HashMap<>();

    public DisplayLists(ModuleContext context) {
        super(context);
    }

    public PlatformDisplayList<Contact> getContactsSharedList() {
        im.actor.runtime.Runtime.checkMainThread();

        if (contactsGlobalList == null) {
            contactsGlobalList = buildContactList(true);
        }

        return contactsGlobalList;
    }

    public PlatformDisplayList<Dialog> getDialogsSharedList() {
        im.actor.runtime.Runtime.checkMainThread();

        if (dialogGlobalList == null) {
            dialogGlobalList = buildDialogsList(true);
        }

        return dialogGlobalList;
    }

    public PlatformDisplayList<Message> getMessagesSharedList(Peer peer) {
        im.actor.runtime.Runtime.checkMainThread();

        if (!chatsGlobalLists.containsKey(peer)) {
            chatsGlobalLists.put(peer, buildChatList(peer, true));
        }

        return chatsGlobalLists.get(peer);
    }

    public PlatformDisplayList<Message> getDocsSharedList(Peer peer) {
        im.actor.runtime.Runtime.checkMainThread();

        if (!chatsDocsGlobalLists.containsKey(peer)) {
            chatsDocsGlobalLists.put(peer, buildChatDocsList(peer, true));
        }

        return chatsDocsGlobalLists.get(peer);
    }

    public PlatformDisplayList<Message> getPhotosSharedList(Peer peer) {
        im.actor.runtime.Runtime.checkMainThread();
        if (!chatsPhotosGlobalLists.containsKey(peer)) {
            chatsPhotosGlobalLists.put(peer, buildChatPhotosList(peer, true));
        }
        return chatsPhotosGlobalLists.get(peer);
    }

    public PlatformDisplayList<Message> getVideoSharedList(Peer peer) {
        im.actor.runtime.Runtime.checkMainThread();
        if (!chatsVideosGlobalLists.containsKey(peer)) {
            chatsVideosGlobalLists.put(peer, buildChatVideosList(peer, true));
        }
        return chatsVideosGlobalLists.get(peer);
    }

    public PlatformDisplayList<GroupPre> getGroupspreSharedList(Integer parentId){
        im.actor.runtime.Runtime.checkMainThread();
        if(!groupspreGlobalLists.containsKey(parentId)){
            groupspreGlobalLists.put(parentId, buildGroupspreList(parentId, true));
        }
        return groupspreGlobalLists.get(parentId);
    }

    public PlatformDisplayList<Dialog> buildDialogsList(boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Dialog> res = Storage.createDisplayList(context().getMessagesModule().getDialogsEngine(),
                isShared, Dialog.ENTITY_NAME);

        res.initTop();

        return res;
    }

    public PlatformDisplayList<Contact> buildContactList(boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Contact> res = Storage.createDisplayList(context().getContactsModule().getContacts(),
                isShared, Contact.ENTITY_NAME);
        res.initTop();
        return res;
    }

    public PlatformDisplayList<Message> buildChatList(final Peer peer, boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Message> res = Storage.createDisplayList(context().getMessagesModule().getConversationEngine(peer),
                isShared, Message.ENTITY_NAME);

        long lastRead = context().getMessagesModule().getConversationVM(peer).getLastReadMessageDate();

        if (lastRead != 0) {
            res.initCenter(lastRead);
        } else {
            res.initTop();
        }

        return res;
    }

    public PlatformDisplayList<Message> buildChatDocsList(final Peer peer, boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Message> res = Storage.createDisplayList(context().getMessagesModule().getConversationDocsEngine(peer),
                isShared, Message.ENTITY_NAME);

        res.initTop();

        return res;
    }

    public PlatformDisplayList<Message> buildChatPhotosList(final Peer peer, boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Message> res = Storage.createDisplayList(context().getMessagesModule().getConversationPhotosEngine(peer),
                isShared, Message.ENTITY_NAME);

        res.initTop();

        return res;
    }

    public PlatformDisplayList<Message> buildChatVideosList(final Peer peer, boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<Message> res = Storage.createDisplayList(context().getMessagesModule().getConversationVideosEngine(peer),
                isShared, Message.ENTITY_NAME);

        res.initTop();

        return res;
    }

    public PlatformDisplayList<GroupPre> buildGroupspreList(final Integer parentId, boolean isShared) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<GroupPre> res = Storage.createDisplayList(context().getGrupoPreModule().getGrupospreEngine(parentId),
                isShared, GroupPre.ENTITY_NAME);

        res.initTop();

        return res;
    }

    public PlatformDisplayList<SearchEntity> buildSearchList(boolean isGlobalList) {
        im.actor.runtime.Runtime.checkMainThread();

        PlatformDisplayList<SearchEntity> res = Storage.createDisplayList(context().getSearchModule().getSearchList(),
                isGlobalList, SearchEntity.ENTITY_NAME);

        res.initEmpty();

        return res;
    }
}
