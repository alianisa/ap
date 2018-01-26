package im.actor.core;

import com.google.j2objc.annotations.ObjectiveCName;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;

import im.actor.core.entity.Contact;
import im.actor.core.entity.Dialog;
import im.actor.core.entity.GroupPre;
import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.core.entity.SearchEntity;
import im.actor.runtime.Runtime;
import im.actor.runtime.generic.mvvm.BindedDisplayList;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.runtime.storage.ListEngineDisplayExt;
import im.actor.runtime.threading.ThreadDispatcher;

public class CocoaMessenger extends Messenger {


    private BindedDisplayList<Dialog> dialogList;
    private HashMap<Peer, BindedDisplayList<Message>> messagesLists = new HashMap<Peer, BindedDisplayList<Message>>();
    private HashMap<Peer, BindedDisplayList<Message>> docsLists = new HashMap<>();
    private HashMap<Peer, BindedDisplayList<Message>> photosList = new HashMap<>();
    private HashMap<Peer, BindedDisplayList<Message>> videosLists = new HashMap<>();

    /**
     * Construct messenger
     *
     * @param configuration configuration of messenger
     */
    @ObjectiveCName("initWithConfiguration:")
    public CocoaMessenger(@NotNull Configuration configuration) {
        super(configuration);

        ThreadDispatcher.pushDispatcher(Runtime::postToMainThread);
    }

    @ObjectiveCName("getDialogsDisplayList")
    public BindedDisplayList<Dialog> getDialogsDisplayList() {
        if (dialogList == null) {
            dialogList = (BindedDisplayList<Dialog>) modules.getDisplayListsModule().getDialogsSharedList();
            dialogList.setBindHook(new BindedDisplayList.BindHook<Dialog>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreDialogs();
                }

                @Override
                public void onItemTouched(Dialog item) {

                }
            });
        }
        return dialogList;
    }

    @ObjectiveCName("getMessageDisplayList:")
    public BindedDisplayList<Message> getMessageDisplayList(final Peer peer) {
        if (!messagesLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getMessagesSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            messagesLists.put(peer, list);
        }

        return messagesLists.get(peer);
    }

    @ObjectiveCName("buildSearchDisplayList")
    public BindedDisplayList<SearchEntity> buildSearchDisplayList() {
        return (BindedDisplayList<SearchEntity>) modules.getDisplayListsModule().buildSearchList(false);
    }

    @ObjectiveCName("buildContactsDisplayList")
    public BindedDisplayList<Contact> buildContactsDisplayList() {
        return (BindedDisplayList<Contact>) modules.getDisplayListsModule().buildContactList(false);
    }

    @ObjectiveCName("getDocsDisplayList:")
    public BindedDisplayList<Message> getDocsDisplayList(final Peer peer) {
        if (!docsLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getDocsSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreDocsHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            docsLists.put(peer, list);
        }
        return docsLists.get(peer);
    }

    @ObjectiveCName("getPhotosDisplayList:")
    public BindedDisplayList<Message> getPhotosDisplayList(final Peer peer) {
        if (!photosList.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getPhotosSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMorePhotosHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            photosList.put(peer, list);
        }
        return photosList.get(peer);
    }

    @ObjectiveCName("getVideosDisplayList:")
    public BindedDisplayList<Message> getVideosDisplayList(final Peer peer) {
        if (!videosLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getVideoSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreVideosHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            videosLists.put(peer, list);
        }
        return videosLists.get(peer);
    }

//    @ObjectiveCName("getGroupsPreSimpleDisplayListWithParentId:withFilter:")
//    public SimpleBindedDisplayList<GroupPre> getGroupsPreSimpleDisplayList(Integer parentId, SimpleBindedDisplayList.Filter<GroupPre> filter) {
//        return new SimpleBindedDisplayList<>((ListEngineDisplayExt<GroupPre>) modules.getGrupoPreModule().getGrupospreEngine(parentId), filter);
//    }


}
