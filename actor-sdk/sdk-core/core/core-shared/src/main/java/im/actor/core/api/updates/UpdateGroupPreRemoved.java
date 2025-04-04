package im.actor.core.api.updates;
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

public class UpdateGroupPreRemoved extends Update {

    public static final int HEADER = 0x16;
    public static UpdateGroupPreRemoved fromBytes(byte[] data) throws IOException {
        return Bser.parse(new UpdateGroupPreRemoved(), data);
    }

    private ApiGroupPre groupPre;
    private List<Integer> removedChildren;
    private List<Integer> parentChildren;

    public UpdateGroupPreRemoved(@NotNull ApiGroupPre groupPre, @NotNull List<Integer> removedChildren, @NotNull List<Integer> parentChildren) {
        this.groupPre = groupPre;
        this.removedChildren = removedChildren;
        this.parentChildren = parentChildren;
    }

    public UpdateGroupPreRemoved() {

    }

    @NotNull
    public ApiGroupPre getGroupPre() {
        return this.groupPre;
    }

    @NotNull
    public List<Integer> getRemovedChildren() {
        return this.removedChildren;
    }

    @NotNull
    public List<Integer> getParentChildren() {
        return this.parentChildren;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.groupPre = values.getObj(1, new ApiGroupPre());
        this.removedChildren = values.getRepeatedInt(2);
        this.parentChildren = values.getRepeatedInt(3);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.groupPre == null) {
            throw new IOException();
        }
        writer.writeObject(1, this.groupPre);
        writer.writeRepeatedInt(2, this.removedChildren);
        writer.writeRepeatedInt(3, this.parentChildren);
    }

    @Override
    public String toString() {
        String res = "update GroupPreRemoved{";
        res += "}";
        return res;
    }

    @Override
    public int getHeaderKey() {
        return HEADER;
    }
}
