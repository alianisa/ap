/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.entity;

import com.google.j2objc.annotations.Property;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.IOException;

import im.actor.core.util.StringUtil;
import im.actor.runtime.bser.Bser;
import im.actor.runtime.bser.BserCreator;
import im.actor.runtime.bser.BserObject;
import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;
import im.actor.runtime.storage.ListEngineItem;

// Disabling Bounds checks for speeding up calculations

/*-[
#define J2OBJC_DISABLE_ARRAY_BOUND_CHECKS 1
]-*/

public class Dialog extends BserObject implements ListEngineItem {

    public static Dialog fromBytes(byte[] data) throws IOException {
        return Bser.parse(new Dialog(), data);
    }

    public static BserCreator<Dialog> CREATOR = Dialog::new;

    public static final String ENTITY_NAME = "Dialog";

    private static final int MAX_LENGTH = 32;

    @NotNull
    @SuppressWarnings("NullableProblems")
    @Property("readonly, nonatomic")
    private Peer peer;
    @NotNull
    @SuppressWarnings("NullableProblems")
    @Property("readonly, nonatomic")
    private String dialogTitle;
    @Nullable
    @Property("readonly, nonatomic")
    private Avatar dialogAvatar;
    @Property("readonly, nonatomic")
    private boolean isBot;
    @Property("readonly, nonatomic")
    private boolean isChannel;
    @Property("readonly, nonatomic")
    private int unreadCount;

    @Property("readonly, nonatomic")
    private long rid;
    @Property("readonly, nonatomic")
    private long sortDate;
    @Property("readonly, nonatomic")
    private int senderId;
    @Property("readonly, nonatomic")
    private long date;

    @Nullable
    @Property("readonly, nonatomic")
    private Long knownReadDate;
    @Nullable
    @Property("readonly, nonatomic")
    private Long knownReceiveDate;

    //ContentType.java
    @SuppressWarnings("NullableProblems")
    @Property("readonly, nonatomic")
    private int messageType;
    @NotNull
    @SuppressWarnings("NullableProblems")
    @Property("readonly, nonatomic")
    private String text;
    @Property("readonly, nonatomic")
    private int relatedUid;


    public Dialog(@NotNull Peer peer,
                  long sortKey,
                  @NotNull String dialogTitle,
                  @Nullable Avatar dialogAvatar,
                  boolean isBot,
                  boolean isChannel,
                  int unreadCount,
                  long rid,
                  int messageType,
                  @NotNull String text,
                  int senderId,
                  long date,
                  int relatedUid,
                  @Nullable
                          Long knownReadDate,
                  @Nullable
                          Long knownReceiveDate) {
        this.peer = peer;
        this.dialogTitle = StringUtil.ellipsize(dialogTitle, MAX_LENGTH);
        this.dialogAvatar = dialogAvatar;
        this.isBot = isBot;
        this.isChannel = isChannel;
        this.unreadCount = unreadCount;
        this.rid = rid;
        this.sortDate = sortKey;
        this.senderId = senderId;
        this.date = date;
        this.messageType = messageType;
        this.text = StringUtil.ellipsize(text, MAX_LENGTH);
        this.relatedUid = relatedUid;
        this.knownReadDate = knownReadDate;
        this.knownReceiveDate = knownReceiveDate;
    }

    private Dialog() {

    }

    @NotNull
    public Peer getPeer() {
        return peer;
    }

    @NotNull
    public String getDialogTitle() {
        return dialogTitle;
    }

    @Nullable
    public Avatar getDialogAvatar() {
        return dialogAvatar;
    }

    public boolean isBot() {
        return isBot;
    }

    public boolean isChannel() {
        return isChannel;
    }

    public int getUnreadCount() {
        return unreadCount;
    }

    public long getRid() {
        return rid;
    }

    public long getSortDate() {
        return sortDate;
    }

    public int getSenderId() {
        return senderId;
    }

    public long getDate() {
        return date;
    }

    public int getMessageType() {
        return messageType;
    }

    @NotNull
    public String getText() {
        return text;
    }

    public int getRelatedUid() {
        return relatedUid;
    }


    @Nullable
    public Long getKnownReadDate() {
        return knownReadDate;
    }

    @Nullable
    public Long getKnownReceiveDate() {
        return knownReceiveDate;
    }

    public boolean isRead() {
        return knownReadDate != null && sortDate <= knownReadDate;
    }

    public boolean isReceived() {
        return knownReceiveDate != null && sortDate <= knownReceiveDate;
    }

    public Dialog editPeerInfo(String title, Avatar dialogAvatar) {
        return new Dialog(peer, sortDate, StringUtil.ellipsize(title, MAX_LENGTH), dialogAvatar,
                isBot, isChannel, unreadCount, rid, messageType, text, senderId, date, relatedUid,
                knownReadDate, knownReceiveDate);
    }

    @Override
    public void parse(BserValues values) throws IOException {
        peer = Peer.fromBytes(values.getBytes(1));

        dialogTitle = StringUtil.ellipsize(values.getString(2), MAX_LENGTH);
        byte[] av = values.optBytes(3);
        if (av != null) {
            dialogAvatar = new Avatar(av);
        }
        isBot = values.getBool(15, false);
        isChannel = values.getBool(16, false);

        unreadCount = values.getInt(4);
        sortDate = values.getLong(5);

        rid = values.getLong(6);
        senderId = values.getInt(7);
        date = values.getLong(8);
        messageType = values.getInt(9);
        text = StringUtil.ellipsize(values.getString(10), MAX_LENGTH);

        relatedUid = values.getInt(12);

        knownReceiveDate = values.optLong(13);
        knownReadDate = values.optLong(14);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeObject(1, peer);
        writer.writeString(2, dialogTitle);
        if (dialogAvatar != null) {
            writer.writeObject(3, dialogAvatar);
        }
        writer.writeBool(15, isBot);
        writer.writeBool(16, isChannel);
        writer.writeInt(4, unreadCount);
        writer.writeLong(5, sortDate);
        writer.writeLong(6, rid);
        writer.writeInt(7, senderId);
        writer.writeLong(8, date);
        writer.writeInt(9, messageType);
        writer.writeString(10, text);
        writer.writeInt(12, relatedUid);

        if (knownReceiveDate != null) {
            writer.writeLong(13, knownReceiveDate);
        }
        if (knownReadDate != null) {
            writer.writeLong(14, knownReadDate);
        }
    }

    @Override
    public long getEngineId() {
        return peer.getUnuqueId();
    }

    @Override
    public long getEngineSort() {
        return sortDate;
    }

    @Override
    public String getEngineSearch() {
        return dialogTitle;
    }
}
