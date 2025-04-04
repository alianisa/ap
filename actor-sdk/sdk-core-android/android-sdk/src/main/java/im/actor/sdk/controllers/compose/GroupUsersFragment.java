package im.actor.sdk.controllers.compose;

import android.os.Bundle;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

import im.actor.core.entity.Contact;
import im.actor.runtime.promise.Promise;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.Intents;
import im.actor.sdk.controllers.compose.view.UserSpan;
import im.actor.sdk.controllers.contacts.BaseContactFragment;
import im.actor.sdk.util.BoxUtil;
import im.actor.sdk.util.KeyboardHelper;
import im.actor.sdk.util.Screen;

import static im.actor.sdk.util.ActorSDKMessenger.messenger;
import static im.actor.sdk.util.ActorSDKMessenger.users;

public class GroupUsersFragment extends BaseContactFragment {

    private String title;
    private String avatarPath;
    private EditText searchField;
    private TextWatcher textWatcher;
    private boolean isChannel;
    private int gid;

    public GroupUsersFragment() {
        super(true, false, true);

        setRootFragment(true);
        setHomeAsUp(true);
    }

    public static GroupUsersFragment createGroup(String title, String avatarPath) {
        GroupUsersFragment res = new GroupUsersFragment();
        Bundle args = new Bundle();
        args.putString("title", title);
        args.putString("avatarPath", avatarPath);
        res.setArguments(args);
        return res;
    }

    public static GroupUsersFragment createChannel(int gid) {
        GroupUsersFragment res = new GroupUsersFragment();
        Bundle args = new Bundle();
        args.putBoolean("isChannel", true);
        args.putInt("gid", gid);
        res.setArguments(args);
        return res;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        isChannel = getArguments().getBoolean("isChannel", false);
        setTitle(isChannel ? R.string.channel_add_members : R.string.create_group_title);

        gid = getArguments().getInt("gid");
        title = getArguments().getString("title");
        avatarPath = getArguments().getString("avatarPath");

        View res = onCreateContactsView(R.layout.fragment_create_group_participants, inflater,
                container, savedInstanceState);
        res.setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());
        searchField = (EditText) res.findViewById(R.id.searchField);
        searchField.setTextColor(ActorSDK.sharedActor().style.getTextPrimaryColor());
        searchField.setHintTextColor(ActorSDK.sharedActor().style.getTextHintColor());
        textWatcher = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                checkForDeletions(s);
                String filter = s.toString().trim();
                while (filter.length() > 0 && filter.charAt(0) == '!') {
                    filter = filter.substring(1);
                }
                filter(filter);
            }
        };
        KeyboardHelper helper = new KeyboardHelper(getActivity());
        helper.setImeVisibility(searchField, false);
        return res;
    }

    @Override
    public void onResume() {
        super.onResume();
        searchField.addTextChangedListener(textWatcher);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.create_group, menu);
        menu.findItem(R.id.done).setEnabled(getSelectedCount() > 0 || isChannel);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.done) {
            if (isChannel) {
                if (getSelectedCount() > 0) {
                    Promise invites = null;
                    for (int uid : getSelected()) {
                        if (invites == null) {
                            invites = messenger().inviteMemberPromise(gid, uid);
                        } else {
                            invites.chain(o -> messenger().inviteMemberPromise(gid, uid));
                        }
                    }
                    execute(invites.then(o -> openChannel()), R.string.progress_common);
                } else {
                    openChannel();
                }
            } else {
                if (getSelectedCount() > 0) {
                    execute(messenger().createGroup(title, avatarPath, BoxUtil.unbox(getSelected())).then(gid -> {
                        getActivity().startActivity(Intents.openGroupDialog(gid, true, getActivity()));
                        getActivity().finish();
                    }).failure(e -> {
                        Toast.makeText(getActivity(), getString(R.string.toast_unable_create_group),
                                Toast.LENGTH_LONG).show();
                    }));
                }
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    protected void openChannel() {
        getActivity().startActivity(Intents.openGroupDialog(gid, true, getActivity()));
        getActivity().finish();
    }

    @Override
    public void onItemClicked(Contact contact) {
        if (isSelected(contact.getUid())) {
            unselect(contact.getUid());
        } else {
            select(contact.getUid());
        }
        getActivity().invalidateOptionsMenu();
        updateEditText();
    }

    private void updateEditText() {
        Integer[] selected = getSelected();
        String src = "";
        for (int i = 0; i < selected.length; i++) {
            src += "!";
        }
        Spannable spannable = new SpannableString(src);
        for (int i = 0; i < selected.length; i++) {
            spannable.setSpan(new UserSpan(users().get(selected[i]), Screen.dp(200)), i, i + 1, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        }
        searchField.removeTextChangedListener(textWatcher);
        searchField.setText(spannable);
        searchField.setSelection(spannable.length());
        searchField.addTextChangedListener(textWatcher);
        filter("");
        getAdapter().notifyDataSetChanged();
    }

    private void checkForDeletions(Editable editable) {
        Integer[] selected = getSelected();
        boolean hasDeletions = false;
        UserSpan[] spans = editable.getSpans(0, editable.length(), UserSpan.class);
        for (Integer u : selected) {
            boolean founded = false;
            for (UserSpan span : spans) {
                if (span.getUser().getId() == u) {
                    if (editable.getSpanStart(span) == editable.getSpanEnd(span)) {
                        break;
                    } else {
                        founded = true;
                        break;
                    }
                }
            }

            if (!founded) {
                hasDeletions = true;
                unselect(u);
            }
        }
        if (hasDeletions) {
            getActivity().invalidateOptionsMenu();
            getAdapter().notifyDataSetChanged();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        searchField.removeTextChangedListener(textWatcher);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        textWatcher = null;
        searchField = null;
    }
}
