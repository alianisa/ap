package im.actor.core.api;
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

public class ApiSurveyAnswer extends BserObject {

    private int id;
    private String name;
    private List<Integer> votes;

    public ApiSurveyAnswer(int id, @NotNull String name, @NotNull List<Integer> votes) {
        this.id = id;
        this.name = name;
        this.votes = votes;
    }

    public ApiSurveyAnswer() {

    }

    public int getId() {
        return this.id;
    }

    @NotNull
    public String getName() {
        return this.name;
    }

    @NotNull
    public List<Integer> getVotes() {
        return this.votes;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.id = values.getInt(1);
        this.name = values.getString(2);
        this.votes = values.getRepeatedInt(3);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeInt(1, this.id);
        if (this.name == null) {
            throw new IOException();
        }
        writer.writeString(2, this.name);
        writer.writeRepeatedInt(3, this.votes);
    }

    @Override
    public String toString() {
        String res = "struct SurveyAnswer{";
        res += "}";
        return res;
    }

}
