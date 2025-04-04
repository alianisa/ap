package im.actor.sdk.controllers.auth;

import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.util.Patterns;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.regex.Pattern;

import im.actor.runtime.Log;
import im.actor.runtime.mtproto.ConnectionEndpointArray;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.BaseFragment;
import im.actor.sdk.util.Screen;
import im.actor.sdk.view.BaseUrlSpan;
import im.actor.sdk.view.CustomClicableSpan;

import static im.actor.sdk.util.ActorSDKMessenger.messenger;

public abstract class BaseAuthFragment extends BaseFragment {

    private static final String TAG = BaseAuthFragment.class.getSimpleName();

    private static final int PERMISSIONS_REQUEST_ACCOUNT = 1;
    public static final boolean USE_SUGGESTED_EMAIL = false;
    private EditText edittextToFill;

    public BaseAuthFragment() {
        setRootFragment(true);
    }

//    protected void startSignIn() {
//        ((AuthActivity) getActivity()).startSignIn();
//    }
//
//    protected void startSignUp() {
//        ((AuthActivity) getActivity()).startSignUp();
//    }

    protected void startPhoneAuth(long phone) {
        messenger().getPreferences().putString("sign_in_auth_id", Long.toString(phone));
        ((AuthActivity) getActivity()).startPhoneAuth(messenger().doStartPhoneAuth(phone), phone);
    }

    protected void startEmailAuth(String email) {
        messenger().getPreferences().putString("sign_in_auth_id", email);
        ((AuthActivity) getActivity()).startEmailAuth(messenger().doStartEmailAuth(email), email);
    }

    protected void validateCode(String code) {
        AuthActivity activity = (AuthActivity) getActivity();
        activity.validateCode(messenger().doValidateCode(code, activity.getTransactionHash()), code);
    }

//    protected void signUp(String name, int sex) {
//        AuthActivity activity = (AuthActivity) getActivity();
//        Promise<AuthRes> promise = messenger().doSignup(name, sex, activity.getTransactionHash());
//        ((AuthActivity) getActivity()).signUp(promise, name, sex);
//    }

    protected void startAuth(String name) {
        ((AuthActivity) getActivity()).startAuth(name);
    }

    protected void startAuth() {
        ((AuthActivity) getActivity()).startAuth();
    }

    protected void switchToEmail() {
        ((AuthActivity) getActivity()).switchToEmailAuth();
    }

    protected void switchToPhone() {
        ((AuthActivity) getActivity()).switchToPhoneAuth();
    }

    protected void setSuggestedEmail(EditText et) {
        if (USE_SUGGESTED_EMAIL) {
            edittextToFill = et;
            if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.GET_ACCOUNTS) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.GET_ACCOUNTS},
                        PERMISSIONS_REQUEST_ACCOUNT);

            } else {
                et.setText(getSuggestedEmailChecked());
            }
        }
    }


    private String getSuggestedEmailChecked() {
        Pattern emailPattern = Patterns.EMAIL_ADDRESS;
        Account[] accounts = AccountManager.get(getActivity()).getAccounts();
        for (Account account : accounts) {
            if (emailPattern.matcher(account.name).matches()) {
                return account.name;
            }
        }

        return null;
    }

    protected void focus(final EditText editText) {
        editText.postDelayed(() -> {
            editText.requestFocus();
            if (editText.getText().toString().indexOf('-') > 0) {
                editText.setSelection(editText.getText().toString().indexOf('-'));
            } else {
                editText.setSelection(editText.getText().length());
            }
        }, 500);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSIONS_REQUEST_ACCOUNT && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            if (edittextToFill != null) {
                edittextToFill.setText(getSuggestedEmailChecked());
            }
        }
    }

    protected void setTosAndPrivacy(TextView tv) {
        ActorSDK actorSDK = ActorSDK.sharedActor();

        String tosUrl = actorSDK.getTosUrl();
        String tosText = actorSDK.getTosText();
        boolean tosUrlAvailable = tosUrl != null && !tosUrl.isEmpty();
        boolean tosTextAvailable = tosText != null && !tosText.isEmpty();
        boolean tosAvailable = tosUrlAvailable || tosTextAvailable;

        String privacyUrl = actorSDK.getPrivacyUrl();
        String privacyText = actorSDK.getPrivacyText();
        boolean privacyUrlAvailable = privacyUrl != null && !privacyUrl.isEmpty();
        boolean privacyTextAvailable = privacyText != null && !privacyText.isEmpty();
        boolean ppAvailable = privacyUrlAvailable || privacyTextAvailable;

        boolean tosOrPrivacyAvailable = tosAvailable || ppAvailable;

        if (!tosOrPrivacyAvailable) {
            tv.setVisibility(View.GONE);
            return;
        }

        String text;
        SpannableStringBuilder builder;
        if (tosAvailable && ppAvailable) {
            text = getString(R.string.auth_tos_privacy);
            builder = new SpannableStringBuilder(text);

            findAndHilightTos(builder, text, tosUrlAvailable);
            findAndHilightPrivacy(builder, text, privacyUrlAvailable);
        } else if (tosAvailable) {
            text = getString(R.string.auth_tos);
            builder = new SpannableStringBuilder(text);
            findAndHilightTos(builder, text, tosUrlAvailable);
        } else {
            text = getString(R.string.auth_privacy);
            builder = new SpannableStringBuilder(text);

            tv.setText(getString(R.string.auth_privacy));
            findAndHilightPrivacy(builder, text, privacyUrlAvailable);
        }
        builder.append(" ".concat(getString(R.string.auth_find_by_diclamer)));
        tv.setText(builder);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void findAndHilightTos(SpannableStringBuilder builder, String text, boolean urlAvailable) {
        String tosIndex = getString(R.string.auth_tos_index);
        int index = text.indexOf(tosIndex);
        ClickableSpan span;
        if (urlAvailable) {
            span = new BaseUrlSpan(ActorSDK.sharedActor().getTosUrl(), false);
        } else {
            span = new CustomClicableSpan(() -> new AlertDialog.Builder(getContext())
                    .setTitle(R.string.auth_tos_index)
                    .setMessage(ActorSDK.sharedActor().getTosText())
                    .setPositiveButton(R.string.dialog_ok, (dialog, which) -> dialog.dismiss())
                    .show());
        }
        builder.setSpan(span, index, index + tosIndex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
    }

    private void findAndHilightPrivacy(SpannableStringBuilder builder, String text, boolean urlAvailable) {
        String ppIndex = getString(R.string.auth_privacy_index);
        int index = text.indexOf(ppIndex);
        ClickableSpan span;
        if (urlAvailable) {
            span = new BaseUrlSpan(ActorSDK.sharedActor().getPrivacyUrl(), false);
        } else {
            span = new CustomClicableSpan(() -> new AlertDialog.Builder(getContext())
                    .setTitle(R.string.auth_privacy_index)
                    .setMessage(ActorSDK.sharedActor().getPrivacyText())
                    .setPositiveButton(R.string.dialog_ok, (dialog, which) -> dialog.dismiss())
                    .show());
        }
        builder.setSpan(span, index, index + ppIndex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
    }

    private void changeEndpoint() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(R.string.auth_change_endpoint);

        final EditText input = new EditText(getActivity());
        input.setText("tcp://");
        input.setSelection(input.getText().length());

        int padding = Screen.dp(25);
        FrameLayout inputContainer = new FrameLayout(getActivity());
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(padding, padding, padding, 0);
        inputContainer.addView(input, params);
        builder.setView(inputContainer);

        builder.setPositiveButton(R.string.dialog_ok, (dialog, which) -> {
            try {
                messenger().changeEndpoint(input.getText().toString());
            } catch (ConnectionEndpointArray.UnknownSchemeException e) {
                Toast.makeText(getActivity(), e.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
        builder.setNegativeButton(R.string.auth_reset_default_endpoint, (dialog, which) -> {
            try {
                messenger().changeEndpoint(null);
            } catch (ConnectionEndpointArray.UnknownSchemeException e) {
                Log.e(TAG, e);
            }
        });

        builder.show();
        input.requestFocus();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int i = item.getItemId();
        if (i == R.id.email) {
            switchToEmail();
            return true;
        } else if (i == R.id.phone) {
            switchToPhone();
            return true;
//        } else if (i == R.id.change_endpoint) {
//            return true;
        } else {
            return super.onOptionsItemSelected(item);
        }
    }
}
