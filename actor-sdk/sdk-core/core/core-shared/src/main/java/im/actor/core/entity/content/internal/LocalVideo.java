/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.entity.content.internal;

import java.io.IOException;

import im.actor.runtime.bser.BserValues;
import im.actor.runtime.bser.BserWriter;

public class LocalVideo extends LocalDocument {

    private int w;
    private int h;
    private int duration;
    private boolean compressed;

    public LocalVideo(String fileName, String fileDescriptor, int fileSize, String mimeType,
                      LocalFastThumb fastThumb, int w, int h, int duration, boolean compressed) {

        super(fileName, fileDescriptor, fileSize, mimeType, fastThumb);
        this.w = w;
        this.h = h;
        this.duration = duration;
        this.compressed = compressed;
    }

    public LocalVideo(byte[] data) throws IOException {
        super(data);
    }

    public LocalVideo(BserValues values) throws IOException {
        super(values);
    }

    public int getW() {
        return w;
    }

    public int getH() {
        return h;
    }

    public int getDuration() {
        return duration;
    }

    public boolean isCompressed() {
        return compressed;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        super.parse(values);
        w = values.getInt(10);
        h = values.getInt(11);
        duration = values.getInt(12);
        compressed = values.getBool(13);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        super.serialize(writer);
        writer.writeInt(10, w);
        writer.writeInt(11, h);
        writer.writeInt(12, duration);
        writer.writeBool(13, compressed);
    }
}
