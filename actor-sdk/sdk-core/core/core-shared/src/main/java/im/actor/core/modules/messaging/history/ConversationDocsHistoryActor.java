/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.modules.messaging.history;

import java.util.ArrayList;
import java.util.List;

import im.actor.core.api.ApiDocsHistoryType;
import im.actor.core.api.ApiMessageContainer;
import im.actor.core.api.ApiMessageReaction;
import im.actor.core.api.ApiMessageState;
import im.actor.core.api.rpc.RequestLoadDocsHistory;
import im.actor.core.entity.EntityConverter;
import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.core.entity.Reaction;
import im.actor.core.entity.content.AbsContent;
import im.actor.core.modules.ModuleActor;
import im.actor.core.modules.ModuleContext;
import im.actor.runtime.Log;
import im.actor.runtime.actors.ask.AskMessage;
import im.actor.runtime.actors.messages.Void;
import im.actor.runtime.promise.Promise;

public class ConversationDocsHistoryActor extends ModuleActor {

    // j2objc workaround
    private static final Void DUMB = null;

    private static final String TAG = ConversationDocsHistoryActor.class.getName();

    private static final int LIMIT = 20;

    private final String KEY_LOADED_DATE;
    private final String KEY_LOADED;
    private final String KEY_LOADED_INIT;
    private final Peer peer;

    private long historyMaxDate;
    private boolean historyLoaded;

    private boolean isFreezed = false;

    private ApiDocsHistoryType docType;

    public ConversationDocsHistoryActor(Peer peer, ModuleContext context, ApiDocsHistoryType docType) {
        super(context);
        this.peer = peer;
        this.docType = docType;
        this.KEY_LOADED_DATE = docType + "_conv_docs_" + peer + "_history_date";
        this.KEY_LOADED = docType + "_conv_docs_" + peer + "_history_loaded";
        this.KEY_LOADED_INIT = docType + "_conv_docs_" + peer + "_history_inited";
    }

    @Override
    public void preStart() {
        super.preStart();

        historyMaxDate = preferences().getLong(KEY_LOADED_DATE, Long.MAX_VALUE);
        historyLoaded = preferences().getBool(KEY_LOADED, false);

        if (!preferences().getBool(KEY_LOADED_INIT, false)) {
            self().send(new LoadMore());
        }
    }

    private void onLoadMore() {
        if (isFreezed || historyLoaded) {
            return;
        }
        isFreezed = true;
        api(new RequestLoadDocsHistory(buidOutPeer(peer), historyMaxDate, null, LIMIT, docType))
                .flatMap(r -> {
                    Log.d(TAG, "Apply " + historyMaxDate);
                    return applyHistory(peer, r.getHistory());
                })
                .map(r -> {
                    Log.d(TAG, "Applied");
                    isFreezed = false;
                    unstashAll();
                    return null;
                });
    }

    private Promise<Void> onReset() {

        Log.d(TAG, "Reset");

        historyMaxDate = Long.MAX_VALUE;
        preferences().putLong(KEY_LOADED_DATE, Long.MAX_VALUE);
        historyLoaded = false;
        preferences().putBool(KEY_LOADED, false);
        preferences().putBool(KEY_LOADED_INIT, false);

        isFreezed = true;

        return context().getMessagesModule().getRouter().onChatReset(peer)
                .then(r -> {
                    isFreezed = false;
                    unstashAll();
                    onLoadMore();
                });
    }

    private Promise<Void> applyHistory(Peer peer, List<ApiMessageContainer> history) {

        ArrayList<Message> messages = new ArrayList<>();
        long maxLoadedDate = Long.MAX_VALUE;
        long maxReadDate = 0;
        long maxReceiveDate = 0;

        for (ApiMessageContainer historyMessage : history) {

            AbsContent content = AbsContent.fromMessage(historyMessage.getMessage());

            int state = EntityConverter.convert(historyMessage.getState());
            ArrayList<Reaction> reactions = new ArrayList<>();

            for (ApiMessageReaction r : historyMessage.getReactions()) {
                reactions.add(new Reaction(r.getCode(), r.getUsers()));
            }

            messages.add(new Message(historyMessage.getRid(), historyMessage.getDate(),
                    historyMessage.getDate(), historyMessage.getSenderUid(),
                    state, content, reactions, 0));

            maxLoadedDate = Math.min(historyMessage.getDate(), maxLoadedDate);

            if (historyMessage.getState() == ApiMessageState.RECEIVED) {
                maxReceiveDate = Math.max(historyMessage.getDate(), maxReceiveDate);
            } else if (historyMessage.getState() == ApiMessageState.READ) {
                maxReceiveDate = Math.max(historyMessage.getDate(), maxReceiveDate);
                maxReadDate = Math.max(historyMessage.getDate(), maxReadDate);
            }
        }

        boolean isEnded = history.size() < LIMIT;

        // Sending updates to conversation actor
        final long finalMaxLoadedDate = maxLoadedDate;

        return context().getMessagesModule().getRouter()
                .onDocsHistoryLoaded(peer, messages, maxReceiveDate, maxReadDate, isEnded)
                .map(r -> {
                    // Saving Internal State
                    if (isEnded) {
                        historyLoaded = true;
                    } else {
                        historyLoaded = false;
                        historyMaxDate = finalMaxLoadedDate;
                    }
                    preferences().putLong(KEY_LOADED_DATE, finalMaxLoadedDate);
                    preferences().putBool(KEY_LOADED, historyLoaded);
                    preferences().putBool(KEY_LOADED_INIT, true);
                    return r;
                });
    }


    @Override
    public Promise onAsk(Object message) throws Exception {
        if (message instanceof Reset) {
            if (isFreezed) {
                stash();
                return null;
            }
            onReset();
            return Promise.success(null);
        } else {
            return super.onAsk(message);
        }
    }

    @Override
    public void onReceive(Object message) {
        if (message instanceof LoadMore) {

            onLoadMore();
        } else {
            super.onReceive(message);
        }
    }

    public static class LoadMore {
    }

    public static class Reset implements AskMessage<Void> {

    }
}
