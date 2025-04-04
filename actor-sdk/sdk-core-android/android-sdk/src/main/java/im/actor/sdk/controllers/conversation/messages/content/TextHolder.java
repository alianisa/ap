package im.actor.sdk.controllers.conversation.messages.content;

import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.conversation.messages.MessagesAdapter;
import im.actor.sdk.controllers.conversation.messages.content.preprocessor.PreprocessedData;
import im.actor.sdk.controllers.conversation.messages.content.preprocessor.PreprocessedTextData;
import im.actor.sdk.util.Fonts;
import im.actor.sdk.util.Screen;
import im.actor.sdk.view.TintImageView;
import im.actor.sdk.view.emoji.keyboard.emoji.Emoji;

import static im.actor.core.entity.MessageState.ERROR;
import static im.actor.core.entity.MessageState.PENDING;
import static im.actor.core.entity.MessageState.SENT;
import static im.actor.sdk.util.ActorSDKMessenger.myUid;

public class TextHolder extends MessageHolder {

    protected ViewGroup mainContainer;
    protected FrameLayout messageBubble;
    protected TextView text;

    protected TextPaint emojiTextPaint;

    protected TextView time;
    protected TintImageView status;

    private int waitColor;
    private int sentColor;
    private int deliveredColor;
    private int readColor;
    private int errorColor;

    public TextHolder(MessagesAdapter adapter, final View itemView, Peer peer) {
        super(adapter, itemView, false);

        mainContainer = (ViewGroup) itemView.findViewById(R.id.mainContainer);
        messageBubble = (FrameLayout) itemView.findViewById(R.id.fl_bubble);
        text = (TextView) itemView.findViewById(R.id.tv_text);
        text.setTextColor(ActorSDK.sharedActor().style.getConvTextColor());
        text.setTypeface(Fonts.regular());

        emojiTextPaint = new TextPaint();
        emojiTextPaint.setTextSize(Screen.sp(25));

        time = (TextView) itemView.findViewById(R.id.tv_time);
        ActorSDK.sharedActor().style.getConvTimeColor();
        time.setTypeface(Fonts.regular());
        time.setTextColor(ActorSDK.sharedActor().style.getConvTimeColor());
        status = (TintImageView) itemView.findViewById(R.id.stateIcon);

        waitColor = ActorSDK.sharedActor().style.getConvStatePendingColor();
        sentColor = ActorSDK.sharedActor().style.getConvStateSentColor();
        deliveredColor = ActorSDK.sharedActor().style.getConvStateDeliveredColor();
        readColor = ActorSDK.sharedActor().style.getConvStateReadColor();
        errorColor = ActorSDK.sharedActor().style.getConvStateErrorColor();

        onConfigureViewHolder();
    }

    @Override
    protected void bindData(final Message message, long readDate, long receiveDate, boolean isUpdated, PreprocessedData preprocessedData) {
        PreprocessedTextData textData = (PreprocessedTextData) preprocessedData;
        Spannable reactions = preprocessedData.getReactionsSpannable();
        CharSequence text;

        if (textData.getSpannableString() != null) {
            text = Emoji.replaceEmoji(textData.getSpannableString(), emojiTextPaint.getFontMetricsInt(), Screen.dp(40), false);
        } else {
            text = Emoji.replaceEmoji(new SpannableStringBuilder(textData.getText()), emojiTextPaint.getFontMetricsInt(), Screen.dp(40), false);
        }
        bindRawText(text, readDate, receiveDate, reactions, message, false);
    }

    public void bindRawText(CharSequence rawText, long readDate, long receiveDate, Spannable reactions, Message message, boolean isItalic) {
        text.setTag(R.id.peer, getPeer());
        if (message.getSenderId() == myUid()) {
            messageBubble.setBackgroundResource(R.drawable.bubble_text_out);
        } else {
            messageBubble.setBackgroundResource(R.drawable.bubble_text_in);
        }

        if (isItalic) {
            text.setTypeface(Fonts.italic());
        } else {
            text.setTypeface(Fonts.regular());
        }

        text.setText(rawText);

        // Fixing url long tap
        text.setMovementMethod(new CustomLinkMovementMethod());

        if (message.getSenderId() == myUid()) {
            status.setVisibility(View.VISIBLE);
            switch (message.getMessageState()) {
                case SENT:
                    if (message.getSortDate() <= readDate) {
                        status.setResource(R.drawable.msg_check_2);
                        status.setTint(readColor);
                    } else if (message.getSortDate() <= receiveDate) {
                        status.setResource(R.drawable.msg_check_2);
                        status.setTint(deliveredColor);
                    } else {
                        status.setResource(R.drawable.msg_check_1);
                        status.setTint(sentColor);
                    }
                    break;
                default:
                case PENDING:
                    status.setResource(R.drawable.msg_clock);
                    status.setTint(waitColor);
                    break;
                case ERROR:
                    status.setResource(R.drawable.msg_error);
                    status.setTint(errorColor);
                    break;
            }
        } else {
            status.setVisibility(View.GONE);
        }

        setTimeAndReactions(time);
    }

    class CustomLinkMovementMethod extends LinkMovementMethod {

        @Override
        public boolean onTouchEvent(TextView textView, Spannable spannable, MotionEvent event) {
            super.onTouchEvent(textView, spannable, event);
            mainContainer.onTouchEvent(event);
            return true;
        }
    }
}
