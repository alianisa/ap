package im.actor.sdk.controllers.grouppre.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.Layout;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.ViewGroup;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.view.DraweeHolder;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;

import java.io.File;

import im.actor.core.entity.Avatar;
import im.actor.core.entity.AvatarImage;
import im.actor.core.entity.GroupPre;
import im.actor.core.entity.GroupType;
import im.actor.core.viewmodel.FileCallback;
import im.actor.core.viewmodel.GroupVM;
import im.actor.runtime.files.FileSystemReference;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.ActorStyle;
import im.actor.sdk.R;
import im.actor.sdk.util.Fonts;
import im.actor.sdk.util.Screen;
import im.actor.sdk.view.ListItemBackgroundView;
import im.actor.sdk.view.TintDrawable;
import im.actor.sdk.view.emoji.keyboard.emoji.Emoji;

import static im.actor.sdk.util.ActorSDKMessenger.groups;
import static im.actor.sdk.util.ActorSDKMessenger.messenger;

/**
 * Created by diego on 06/06/17.
 */

public class GrupoPreView extends ListItemBackgroundView<GroupPre, GrupoPreView.GrupoPreLayout> {

    private static boolean isStylesLoaded = false;
    private static TextPaint titlePaint;
    private static TextPaint textPaint;
    private static TextPaint counterTextPaint;

    private static int[] placeholderColors;
    private static Paint avatarBorder;
    private static Paint fillPaint;
    private static TextPaint avatarTextColor;

    private static Drawable groupIcon;
    private static Drawable channelIcon;
    private static Drawable chevronIcon;

    private long bindedId;
    private DraweeHolder<GenericDraweeHierarchy> draweeHolder;
    private GroupVM groupVM;

    public GrupoPreView(Context context) {
        super(context);
        initStyles();
    }

    public GrupoPreView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initStyles();
    }

    public GrupoPreView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initStyles();
    }

    public GrupoPreView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        initStyles();
    }

    protected void initStyles() {
        GenericDraweeHierarchy hierarchy = new GenericDraweeHierarchyBuilder(getResources())
                .setFadeDuration(0)
                .setRoundingParams(new RoundingParams()
                        .setRoundAsCircle(true))
                .build();

        draweeHolder = DraweeHolder.create(hierarchy, getContext());
        draweeHolder.getTopLevelDrawable().setCallback(this);

        setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, Screen.dp(72)));
        setDividerPaddingLeft(Screen.dp(72));
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        GrupoPreView.GrupoPreLayout layout = getLayout();
        if (layout != null) {

            //
            // Avatar
            //

            fillPaint.setColor(placeholderColors[layout.getPlaceholderIndex()]);
            if (layout.getImageRequest() != null) {
                Drawable drawable = draweeHolder.getTopLevelDrawable();
                drawable.setBounds(Screen.dp(12), Screen.dp(12), Screen.dp(60), Screen.dp(60));
                drawable.draw(canvas);
            } else {
                canvas.drawCircle(Screen.dp(36), Screen.dp(36), Screen.dp(24), fillPaint);
                canvas.drawText(layout.getShortName(),
                        0, layout.getShortName().length(),
                        Screen.dp(36), Screen.dp(44), avatarTextColor);
            }
            canvas.drawCircle(Screen.dp(36), Screen.dp(36), Screen.dp(24), avatarBorder);

            //
            // Title
            //

            if (layout.getTitleIcon() != null) {
                int left = Screen.dp(72) + (Screen.dp(16) - layout.getTitleIcon().getIntrinsicWidth()) / 2;
                int bottom = layout.getTitleIconTop();
                if(layout.hasChildren){
                    bottom += Screen.dp(12);
                }
                layout.getTitleIcon().setBounds(left, bottom - layout.getTitleIcon().getIntrinsicHeight(),
                        left + layout.getTitleIcon().getIntrinsicWidth(), bottom);
                layout.getTitleIcon().draw(canvas);
            }

            canvas.save();

            if (layout.getTitleIcon() == null) {
                canvas.translate(Screen.dp(72), Screen.dp(14));
            } else {
                canvas.translate(Screen.dp(72 + 16 + 4), Screen.dp(14));
            }

            if(layout.hasChildren){
                canvas.translate(0, Screen.dp(12));
                layout.getTitleLayout().draw(canvas);
            }else{
                layout.getTitleLayout().draw(canvas);
            }

            canvas.restore();

            //
            // Chevron
            //

            if (layout.isHasChildren()) {
                layout.getChevronIcon().setBounds(layout.chevronLeft, layout.chevronTop,
                        layout.chevronLeft + layout.getChevronIcon().getIntrinsicWidth(),
                        layout.chevronTop + layout.getChevronIcon().getIntrinsicHeight());
                layout.getChevronIcon().draw(canvas);
            }

            canvas.save();
        }
    }

    //
    // Binding
    //
    public void bind(GroupPre grupoPre) {
        groupVM = groups().get(grupoPre.getGroupId());
        requestLayout(grupoPre, bindedId != grupoPre.getEngineId());
        bindedId = grupoPre.getEngineId();
    }

    public void unbind() {
        cancelLayout();
        bindedId = -1;
        draweeHolder.onDetach();
    }

    @Override
    public GrupoPreView.GrupoPreLayout buildLayout(GroupPre groupPre, int width, int height) {
        if (!isStylesLoaded) {
            isStylesLoaded = true;
            ActorStyle style = ActorSDK.sharedActor().style;
            Context context = getContext();
            titlePaint = createTextPaint(Fonts.medium(), 16, style.getDialogsTitleColor());
            textPaint = createTextPaint(Fonts.regular(), 16, style.getDialogsTimeColor());

            groupIcon = new TintDrawable(context.getResources().getDrawable(im.actor.sdk.R.drawable.ic_group_black_18dp),
                    style.getDialogsTitleColor());

            channelIcon = new TintDrawable(context.getResources().getDrawable(im.actor.sdk.R.drawable.ic_megaphone_18dp_black),
                    style.getDialogsTitleColor());

            counterTextPaint = createTextPaint(Fonts.medium(), 14, style.getDialogsCounterTextColor());
            counterTextPaint.setTextAlign(Paint.Align.CENTER);

            fillPaint = createFilledPaint(Color.BLACK);
            placeholderColors = ActorSDK.sharedActor().style.getDefaultAvatarPlaceholders();
            avatarBorder = new Paint();
            avatarBorder.setStyle(Paint.Style.STROKE);
            avatarBorder.setAntiAlias(true);
            avatarBorder.setColor(0x19000000);
            avatarBorder.setStrokeWidth(1);
            avatarTextColor = createTextPaint(Fonts.regular(), 20, Color.WHITE);
            avatarTextColor.setTextAlign(Paint.Align.CENTER);

            chevronIcon = new TintDrawable(context.getResources().getDrawable(R.drawable.ic_chevron_right_black_24dp),
                    style.getDialogsTitleColor());

        }

        GrupoPreView.GrupoPreLayout res = new GrupoPreView.GrupoPreLayout();

        res.setPlaceholderIndex(Math.abs(groupPre.getGroupId()) % placeholderColors.length);
        res.setShortName(buildShortName(groupVM.getName().get()));

        if (groupVM.getAvatar().get() != null) {
            AvatarImage image = getAvatarImage(groupVM.getAvatar().get());
            if (image != null) {
                String desc = messenger().findDownloadedDescriptor(image.getFileReference().getFileId());
                if (desc != null) {
                    ImageRequest request = ImageRequestBuilder.newBuilderWithSource(
                            Uri.fromFile(new File(desc)))
                            .setResizeOptions(new ResizeOptions(Screen.dp(52), Screen.dp(52)))
                            .build();
                    res.setImageRequest(request);
                } else {
                    InvalidationContext invalidationContext = getCurrentLayoutContext();
                    messenger().bindRawFile(image.getFileReference(), true, new FileCallback() {
                        @Override
                        public void onNotDownloaded() {
                            if (invalidationContext.isCancelled()) {
                                messenger().unbindRawFile(image.getFileReference().getFileId(), false, this);
                            }
                        }
                        @Override
                        public void onDownloading(float progress) {
                            if (invalidationContext.isCancelled()) {
                                messenger().unbindRawFile(image.getFileReference().getFileId(), false, this);
                            }
                        }
                        @Override
                        public void onDownloaded(FileSystemReference reference) {
                            messenger().unbindRawFile(image.getFileReference().getFileId(), false, this);
                            invalidationContext.invalidate();
                        }
                    });
                }
            }
        }

        int maxTitleWidth = (width - Screen.dp(72)) - Screen.dp(8);

        if (groupVM.getGroupType() == GroupType.CHANNEL) {
            res.setTitleIcon(channelIcon);
            res.setTitleIconTop(Screen.dp(33));
        } else {
            res.setTitleIcon(groupIcon);
            res.setTitleIconTop(Screen.dp(33));
        }

        res.setHasChildren(groupPre.getHasChildren());
        res.setChevronIcon(chevronIcon);
        res.setChevronLeft((width - Screen.dp(40)));
        res.setChevronTop(Screen.dp(23));

        maxTitleWidth -= Screen.dp(16 + 4);
        res.setTitleLayout(singleLineText(groupVM.getName().get(), titlePaint, maxTitleWidth));

        return res;
    }

    @Override
    public void layoutReady(GrupoPreView.GrupoPreLayout res) {
        super.layoutReady(res);

        draweeHolder.onAttach();

        if (res.getImageRequest() != null) {
            draweeHolder.setController(Fresco.newDraweeControllerBuilder()
                    .setImageRequest(res.getImageRequest())
                    .setOldController(draweeHolder.getController())
                    .build());
        } else {
            draweeHolder.setController(Fresco.newDraweeControllerBuilder()
                    .setOldController(draweeHolder.getController())
                    .build());
        }
    }

    private CharSequence buildShortName(String name) {
        if (name == null) {
            name = "?";
        } else if (name.length() == 0) {
            name = "?";
        } else {
            String[] parts = name.trim().split(" ", 2);
            if (parts.length == 0 || parts[0].length() == 0) {
                name = "?";
            } else {
                name = parts[0].substring(0, 1).toUpperCase();
                if (parts.length == 2 && parts[1].length() > 0) {
                    name += parts[1].substring(0, 1).toUpperCase();
                }
            }
        }
        return Emoji.replaceEmoji(name, textPaint.getFontMetricsInt(), Screen.dp(20), false);
    }

    private AvatarImage getAvatarImage(Avatar avatar) {
        return Screen.dp(52) >= 100 ? avatar.getLargeImage() : avatar.getSmallImage();
    }

    @Override
    protected boolean verifyDrawable(Drawable who) {
        if (who == draweeHolder.getTopLevelDrawable()) {
            return true;
        }
        return super.verifyDrawable(who);
    }

    public static class GrupoPreLayout {

        private ImageRequest imageRequest;
        private int placeholderIndex;
        private CharSequence shortName;
        private Layout titleLayout;
        private Drawable titleIcon;
        private int titleIconTop;
        private boolean hasChildren;
        private Drawable chevronIcon;
        private int chevronLeft;
        private int chevronTop;

        public int getTitleIconTop() {
            return titleIconTop;
        }

        public void setTitleIconTop(int titleIconTop) {
            this.titleIconTop = titleIconTop;
        }

        public ImageRequest getImageRequest() {
            return imageRequest;
        }

        public void setImageRequest(ImageRequest imageRequest) {
            this.imageRequest = imageRequest;
        }

        public int getPlaceholderIndex() {
            return placeholderIndex;
        }

        public void setPlaceholderIndex(int placeholderIndex) {
            this.placeholderIndex = placeholderIndex;
        }

        public CharSequence getShortName() {
            return shortName;
        }

        public void setShortName(CharSequence shortName) {
            this.shortName = shortName;
        }

        public Layout getTitleLayout() {
            return titleLayout;
        }

        public void setTitleLayout(Layout titleLayout) {
            this.titleLayout = titleLayout;
        }

        public Drawable getTitleIcon() {
            return titleIcon;
        }

        public void setTitleIcon(Drawable titleIcon) {
            this.titleIcon = titleIcon;
        }

        public boolean isHasChildren() {
            return hasChildren;
        }

        public void setHasChildren(boolean hasChildren) {
            this.hasChildren = hasChildren;
        }

        public Drawable getChevronIcon() {
            return chevronIcon;
        }

        public void setChevronIcon(Drawable chevronIcon) {
            this.chevronIcon = chevronIcon;
        }

        public int getChevronLeft() {
            return chevronLeft;
        }

        public void setChevronLeft(int chevronLeft) {
            this.chevronLeft = chevronLeft;
        }

        public int getChevronTop() {
            return chevronTop;
        }

        public void setChevronTop(int chevronTop) {
            this.chevronTop = chevronTop;
        }
    }
}