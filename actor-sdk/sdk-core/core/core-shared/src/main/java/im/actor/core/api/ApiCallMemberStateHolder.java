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

public class ApiCallMemberStateHolder extends BserObject {

    private ApiCallMemberState state;
    private Boolean fallbackIsRinging;
    private Boolean fallbackIsConnected;
    private Boolean fallbackIsConnecting;
    private Boolean fallbackIsRingingReached;
    private Boolean fallbackIsEnded;
    private Boolean fallbackIsBusy;
    private Boolean fallbackIsNoAnswer;

    public ApiCallMemberStateHolder(@NotNull ApiCallMemberState state, @Nullable Boolean fallbackIsRinging, @Nullable Boolean fallbackIsConnected, @Nullable Boolean fallbackIsConnecting, @Nullable Boolean fallbackIsRingingReached, @Nullable Boolean fallbackIsEnded, @Nullable Boolean fallbackIsBusy, @Nullable Boolean fallbackIsNoAnswer) {
        this.state = state;
        this.fallbackIsRinging = fallbackIsRinging;
        this.fallbackIsConnected = fallbackIsConnected;
        this.fallbackIsConnecting = fallbackIsConnecting;
        this.fallbackIsRingingReached = fallbackIsRingingReached;
        this.fallbackIsEnded = fallbackIsEnded;
        this.fallbackIsBusy = fallbackIsBusy;
        this.fallbackIsNoAnswer = fallbackIsNoAnswer;
    }

    public ApiCallMemberStateHolder() {

    }

    @NotNull
    public ApiCallMemberState getState() {
        return this.state;
    }

    @Nullable
    public Boolean fallbackIsRinging() {
        return this.fallbackIsRinging;
    }

    @Nullable
    public Boolean fallbackIsConnected() {
        return this.fallbackIsConnected;
    }

    @Nullable
    public Boolean fallbackIsConnecting() {
        return this.fallbackIsConnecting;
    }

    @Nullable
    public Boolean fallbackIsRingingReached() {
        return this.fallbackIsRingingReached;
    }

    @Nullable
    public Boolean fallbackIsEnded() {
        return this.fallbackIsEnded;
    }

    @Nullable
    public Boolean fallbackIsBusy() {
        return this.fallbackIsBusy;
    }

    @Nullable
    public Boolean fallbackIsNoAnswer() {
        return this.fallbackIsNoAnswer;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.state = ApiCallMemberState.parse(values.getInt(1));
        this.fallbackIsRinging = values.optBool(2);
        this.fallbackIsConnected = values.optBool(3);
        this.fallbackIsConnecting = values.optBool(4);
        this.fallbackIsRingingReached = values.optBool(5);
        this.fallbackIsEnded = values.optBool(6);
        this.fallbackIsBusy = values.optBool(7);
        this.fallbackIsNoAnswer = values.optBool(8);
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        if (this.state == null) {
            throw new IOException();
        }
        writer.writeInt(1, this.state.getValue());
        if (this.fallbackIsRinging != null) {
            writer.writeBool(2, this.fallbackIsRinging);
        }
        if (this.fallbackIsConnected != null) {
            writer.writeBool(3, this.fallbackIsConnected);
        }
        if (this.fallbackIsConnecting != null) {
            writer.writeBool(4, this.fallbackIsConnecting);
        }
        if (this.fallbackIsRingingReached != null) {
            writer.writeBool(5, this.fallbackIsRingingReached);
        }
        if (this.fallbackIsEnded != null) {
            writer.writeBool(6, this.fallbackIsEnded);
        }
        if (this.fallbackIsBusy != null) {
            writer.writeBool(7, this.fallbackIsBusy);
        }
        if (this.fallbackIsNoAnswer != null) {
            writer.writeBool(8, this.fallbackIsNoAnswer);
        }
    }

    @Override
    public String toString() {
        String res = "struct CallMemberStateHolder{";
        res += "state=" + this.state;
        res += ", fallbackIsRinging=" + this.fallbackIsRinging;
        res += ", fallbackIsConnected=" + this.fallbackIsConnected;
        res += ", fallbackIsConnecting=" + this.fallbackIsConnecting;
        res += ", fallbackIsRingingReached=" + this.fallbackIsRingingReached;
        res += ", fallbackIsEnded=" + this.fallbackIsEnded;
        res += ", fallbackIsBusy=" + this.fallbackIsBusy;
        res += ", fallbackIsNoAnswer=" + this.fallbackIsNoAnswer;
        res += "}";
        return res;
    }

}
