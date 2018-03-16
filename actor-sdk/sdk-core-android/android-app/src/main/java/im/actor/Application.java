package im.actor;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.os.Build;
import android.os.Bundle;
import android.support.multidex.MultiDex;
import android.support.v4.app.Fragment;
import android.text.Spannable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.Toast;

import com.google.firebase.FirebaseApp;

import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;

import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.core.entity.content.JsonContent;
import im.actor.core.entity.content.PhotoContent;
import im.actor.develop.R;
import im.actor.fragments.AttachFragmentEx;
import im.actor.fragments.RootFragmentEx;
import im.actor.runtime.android.AndroidLogProvider;
import im.actor.runtime.json.JSONException;
import im.actor.runtime.json.JSONObject;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.ActorSDKApplication;
import im.actor.sdk.ActorStyle;
import im.actor.sdk.BaseActorSDKDelegate;
import im.actor.sdk.controllers.auth.AuthActivity;
import im.actor.sdk.controllers.conversation.attach.AbsAttachFragment;
import im.actor.sdk.controllers.conversation.messages.BubbleLayouter;
import im.actor.sdk.controllers.conversation.messages.DefaultLayouter;
import im.actor.sdk.controllers.conversation.messages.JsonXmlBubbleLayouter;
import im.actor.sdk.controllers.conversation.messages.XmlBubbleLayouter;
import im.actor.sdk.controllers.conversation.messages.content.PhotoHolder;
import im.actor.sdk.controllers.conversation.messages.content.TextHolder;
import im.actor.sdk.controllers.conversation.messages.content.preprocessor.PreprocessedData;
import im.actor.sdk.controllers.settings.ActorSettingsCategories;
import im.actor.sdk.controllers.settings.ActorSettingsCategory;
import im.actor.sdk.controllers.settings.ActorSettingsField;
import im.actor.sdk.controllers.settings.BaseActorSettingsActivity;
import im.actor.sdk.controllers.settings.BaseActorSettingsFragment;
import im.actor.sdk.intents.ActorIntentFragmentActivity;

public class Application extends ActorSDKApplication {

    @Override
    public void onCreate() {
        super.onCreate();

        if (Build.VERSION.SDK_INT < 18) {
            System.loadLibrary("vclibrary");
        }
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void onConfigureActorSDK() {
        FirebaseApp.initializeApp(this);
        ActorSDK.sharedActor().setDelegate(new ActorSDKDelegate());
        ActorSDK.sharedActor().setPushId(157558192914L);
        ActorSDK.sharedActor().setOnClientPrivacyEnabled(true);
        ActorStyle style = ActorSDK.sharedActor().style;

//        style.setDialogsActiveTextColor(0xff5882ac);
//        style.setShowAvatarPrivateInTitle(false);
//        style.setDialogsActiveTextColor(0xff5882ac);
//        style.setMainColor(Color.parseColor("#A43436"));
//        style.setAccentColor(Color.parseColor("#1F3255"));
//        style.setStatusBarColor(Color.parseColor("#A43436"));
//        style.setAccentPressedColor(Color.parseColor("#1F3255"));
//        style.setPrimaryAltColor(Color.parseColor("#A43436"));
//        style.setToolBarColor(Color.parseColor("#A43436"));
//        style.setFabColor(Color.parseColor("#A43436"));

        ActorSDK.sharedActor().setFastShareEnabled(true);
        ActorSDK.sharedActor().setCallsEnabled(true);
        ActorSDK.sharedActor().setAppName(getApplicationContext().getString(R.string.app_name));

        ActorSDK.sharedActor().setTosUrl("https://conecta.im/politica.html");
        ActorSDK.sharedActor().setTosText("Conecta IM, all rights reserved");
        ActorSDK.sharedActor().setPrivacyText("Conecta IM, all rights reserved");
        ActorSDK.sharedActor().setCustomApplicationName("Conecta");
        ActorSDK.sharedActor().setHelpPhone("+55 (55) 55555-5555");
        ActorSDK.sharedActor().setHomePage("https://conecta.im");
        ActorSDK.sharedActor().setTwitter("conecta_im");

        ActorSDK.sharedActor().setVideoCallsEnabled(true);

        ActorSDK.sharedActor().setHelpPhone("+55 (55) 55555-5555");
        ActorSDK.sharedActor().setAutoJoinGroups(new String[]{"ConectaGlobal"});
        ActorSDK.sharedActor().setEndpoints(new String[]{getApplicationContext().getString(R.string.app_endpoint)});

        ActorSDK.sharedActor().setStickersEnabled(true);

        ActorSDK.sharedActor().setInviteUrl("https://play.google.com/store/apps/details?id=br.com.diegosilva.conecta");
        ActorSDK.sharedActor().setGroupInvitePrefix("https://j.conecta.im/#/join/");
        ActorSDK.sharedActor().setInviteDataUrl("https://api.conecta.im/v1/groups/invites/");

//        ActorStyle style = ActorSDK.sharedActor().style;
//        style.setMainColor(Color.parseColor("#529a88"));
//        style.setAvatarBackgroundResource(R.drawable.img_profile_avatar_default);
//        AbsContent.registerConverter(new ContentConverter() {
//            @Override
//            public AbsContent convert(AbsContentContainer container) {
//                return JsonContent.convert(container, new TCBotMesaage());
//            }
//
//            @Override
//            public boolean validate(AbsContent content) {
//                return content instanceof TCBotMesaage;
//            }
//        });

        AndroidLogProvider.setWriteLogs(true);

    }

    private class ActorSDKDelegate extends BaseActorSDKDelegate {

        @Override
        public void configureChatViewHolders(ArrayList<BubbleLayouter> layouters) {
//            layouters.add(0, new BubbleTextHolderLayouter());
            layouters.add(0, new DefaultLayouter(DefaultLayouter.TEXT_HOLDER, (adapter2, root2, peer2) -> new TextHolder(adapter2, root2, peer2) {
                @Override
                public void bindRawText(CharSequence rawText, long readDate, long receiveDate, Spannable reactions, Message message, boolean isItalic) {
                    super.bindRawText(rawText, readDate, receiveDate, reactions, message, isItalic);
                    text.append("\n\n" + message.getSortDate());
                }
            }));

            layouters.add(0, new DefaultLayouter(DefaultLayouter.TEXT_HOLDER, CensoredTextHolderEx::new));

            layouters.add(0, new XmlBubbleLayouter(content -> content instanceof PhotoContent, R.layout.adapter_dialog_photo, (adapter1, root1, peer1) -> new PhotoHolder(adapter1, root1, peer1) {
                @Override
                protected void onConfigureViewHolder() {
                    previewView.setColorFilter(ActorStyle.adjustColorAlpha(Color.CYAN, 20), PorterDuff.Mode.ADD);
                }
            }));
            layouters.add(0, new JsonXmlBubbleLayouter(null, R.layout.adapter_dialog_text, (adapter, root, peer) -> new TextHolder(adapter, root, peer) {
                @Override
                protected void bindData(Message message, long readDate, long receiveDate, boolean isUpdated, PreprocessedData preprocessedData) {
                    String jsonString = "can't read json";
                    try {
                        JSONObject jsonObject = new JSONObject(((JsonContent) message.getContent()).getRawJson());
                        String dataType = jsonObject.getString("dataType");
                        JSONObject data = jsonObject.getJSONObject("data");
                        jsonString = dataType + "\n\n";
                        jsonString += data.toString(3);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    bindRawText(jsonString, readDate, receiveDate, reactions, message, false);
                }
            }));
        }

        @Nullable
        @Override
        public Fragment fragmentForRoot() {
            return new RootFragmentEx();
        }

        @Nullable
        @Override
        public AbsAttachFragment fragmentForAttachMenu(Peer peer) {
            return new AttachFragmentEx(peer);
        }

//        @Override
//        public BaseGroupInfoActivity getGroupInfoIntent(int gid) {
//            return new BaseGroupInfoActivity() {
//                @Override
//                public GroupInfoFragment getGroupInfoFragment(int chatId) {
//                    return GroupInfoEx.create(chatId);
//                }
//            };
//        }

        @Override
        public ActorIntentFragmentActivity getSettingsIntent() {

            return new BaseActorSettingsActivity() {
                @Override
                public BaseActorSettingsFragment getSettingsFragment() {
                    return new MyBaseActorSettingsFragment();
                }
            };
        }
    }


    public static class MyBaseActorSettingsActivity extends BaseActorSettingsActivity {

        @Override
        public BaseActorSettingsFragment getSettingsFragment() {
            return new MyBaseActorSettingsFragment();
        }
    }


    public static class MyBaseActorSettingsFragment extends BaseActorSettingsFragment {
        CheckBox blablaCheckBox;

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
            blablaCheckBox = new CheckBox(getContext());
            return super.onCreateView(inflater, container, savedInstanceState);
        }

        @Override
        public ActorSettingsCategories getBeforeSettingsCategories() {
            return new ActorSettingsCategories()
                    .addCategory(new ActorSettingsCategory("azaza")
                            .addField(new ActorSettingsField(R.id.terminateSessions)
                                    .setName("blabla")
                                    .setIconResourceId(R.drawable.ic_edit_black_24dp)
                                    .setRightView(blablaCheckBox)
                            )
                    );
        }

        @Override
        public View.OnClickListener getMenuFieldOnClickListener() {
            return v -> {
                switch (v.getId()) {
                    case R.id.terminateSessions:
                        Toast.makeText(v.getContext(), "hey", Toast.LENGTH_LONG).show();
                        blablaCheckBox.toggle();
                        break;
                }
            };
        }
    }

}
