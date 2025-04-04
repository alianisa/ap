package im.actor.sdk.controllers.conversation.view;

import android.graphics.Color;
import android.graphics.Typeface;
import android.text.TextPaint;
import android.view.View;

import im.actor.runtime.android.AndroidContext;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.ActorSDKLauncher;
import im.actor.sdk.view.BaseUrlSpan;

public class MentionSpan extends BaseUrlSpan {
    int[] colors;
    int userId;

    public static Typeface tf;

    public MentionSpan(String nick, int userId, boolean hideUrlStyle) {
        super(nick, hideUrlStyle);
        this.userId = userId;
        colors = ActorSDK.sharedActor().style.getDefaultAvatarPlaceholders();
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        super.updateDrawState(ds);
        if (hideUrlStyle) {
            ds.setUnderlineText(false);
            ds.setColor(Color.BLACK);
        }

        if (tf == null) {
            tf = Typeface.createFromAsset(AndroidContext.getContext().getAssets(), "Roboto-Medium.ttf");
        }

        ds.setColor(colors[Math.abs(userId) % colors.length]);
        ds.setTypeface(tf);
        ds.setUnderlineText(false);
    }

    private String url;

    public void setUrl(String s) {
        this.url = s;
    }

    @Override
    public void onClick(View widget) {
        if (hideUrlStyle) {
            //Do nothing
        } else {
            ActorSDKLauncher.startProfileActivity(widget.getContext(), userId);
        }
    }
}