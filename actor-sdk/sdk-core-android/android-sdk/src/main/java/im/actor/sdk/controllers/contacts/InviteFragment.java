package im.actor.sdk.controllers.contacts;

import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import im.actor.core.entity.PhoneBookContact;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.BaseFragment;
import im.actor.sdk.core.AndroidPhoneBook;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.adapters.RecyclerListView;

public class InviteFragment extends BaseFragment {


    private RecyclerListView collection;
    private InviteAdapter adapter;
    private List<PhoneBookContact> contacts;
    private TextView emptyText;
    private Menu menu;
    private MenuInflater inflater;

    public InviteFragment() {
        setRootFragment(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View res = inflater.inflate(R.layout.fragment_list, container, false);

        res.findViewById(R.id.listView).setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());

        emptyText = (TextView) res.findViewById(R.id.emptyView);
        emptyText.setTextColor(ActorSDK.sharedActor().style.getTextSecondaryColor());
        emptyText.setText(R.string.progress_common);

        collection = (RecyclerListView) res.findViewById(R.id.listView);
        AndroidPhoneBook phoneBookLoader = new AndroidPhoneBook();
        phoneBookLoader.useDelay(false);

        res.setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());

        phoneBookLoader.loadPhoneBook(contacts -> {
            if (contacts.size() > 0) {

                getActivity().runOnUiThread(() -> {
                    InviteFragment.this.contacts = contacts;

                    adapter = new InviteAdapter(getActivity(), contacts, new OnItemClickedListener<PhoneBookContact>() {
                        @Override
                        public void onClicked(PhoneBookContact item) {

                            onItemClicked(item);
                        }

                        @Override
                        public boolean onLongClicked(PhoneBookContact item) {
                            return false;
                        }

                    });

                    collection.setAdapter(adapter);

                    hideView(emptyText);
                    showView(collection);
                    showMenu();
                });

            }
        });

        return res;
    }


    public void onItemClicked(PhoneBookContact contact) {
        boolean selected = isSelected(contact);
        boolean needDialog = contact.getEmails().size() > 0 && contact.getPhones().size() > 0;

        if (needDialog) {
            String[] items = new String[selected ? 3 : 2];
            items[0] = Long.toString(contact.getPhones().get(0).getNumber());
            items[1] = contact.getEmails().get(0).getEmail();
            if (selected) {
                items[2] = getString(R.string.dialog_cancel);
            }
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            builder.setItems(items, (dialog, which) -> {
                if (which == 2) {
                    unselect(contact);
                } else {
                    select(contact, which);
                }
                getAdapter().notifyDataSetChanged();

                dialog.dismiss();
            }).show();

        } else {
            if (selected) {
                unselect(contact);
            } else {
                select(contact, -1);
            }
            getAdapter().notifyDataSetChanged();
        }
    }

    public void select(PhoneBookContact id, int type) {
        getAdapter().select(id, type);
    }

    public void unselect(PhoneBookContact id) {
        getAdapter().unselect(id);
    }

    public boolean isSelected(PhoneBookContact id) {
        return getAdapter().isSelected(id);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        this.menu = menu;
        this.inflater = inflater;
        showMenu();
    }

    public void showMenu() {
        if (menu != null && inflater != null && adapter != null) {
            if (adapter.getCount() > 0) {
                inflater.inflate(R.menu.invite, menu);
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.send_invites) {
            sendInvites();
            return true;
        } else if (id == R.id.select_all) {
            adapter.selectAll();
        } else if (id == R.id.select_none) {
            adapter.selectNone();
        }
        return super.onOptionsItemSelected(item);
    }

    private void sendInvites() {
        ArrayList<Long> phones = new ArrayList<Long>();
        ArrayList<String> emails = new ArrayList<String>();
        PhoneBookContact[] selected = getAdapter().getSelected();
        HashMap<PhoneBookContact, Integer> selectedTypes = getAdapter().getSelectedContactsTypes();

        Integer selectedType;

        //Prepare email/phones lists
        String phoneNumbersStrings = "";
        String emailsString = "";
        String email;
        long number;

        for (PhoneBookContact contact : selected) {

            selectedType = selectedTypes.get(contact);
            selectedType = selectedType != null ? selectedType : InviteContactHolder.TYPE_PHONE;
            if ((selectedType == InviteContactHolder.TYPE_EMAIL && contact.getEmails().size() > 0) || contact.getPhones().size() == 0) {
                email = contact.getEmails().get(0).getEmail();
                emails.add(email);
                emailsString += email + ";";

            } else {
                number = contact.getPhones().get(0).getNumber();
                phones.add(number);
                phoneNumbersStrings += number + ";";
            }

        }

        String inviteMessage = getResources().getString(R.string.invite_message).replace("{inviteUrl}", ActorSDK.sharedActor().getInviteUrl()).replace("{appName}", ActorSDK.sharedActor().getAppName());

        if (phones.size() > 0 && emails.size() > 0) {
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            String[] options = new String[]{getString(R.string.invite_options_sms), getString(R.string.invite_options_email)};
            final String finalPhoneNumbersStrings = phoneNumbersStrings;
            final String finalEmailsString = emailsString;
            builder.setItems(options, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    if (which == 0) {
                        sendSmsInvites(finalPhoneNumbersStrings, inviteMessage);
                    } else {
                        sendEmailInvites(finalEmailsString, inviteMessage);
                    }
                    dialog.dismiss();
                }
            }).show();
        } else if (phones.size() > 0) {
            sendSmsInvites(phoneNumbersStrings, inviteMessage);

        } else {
            sendEmailInvites(emailsString, inviteMessage);
        }

//        SmsManager smsManager = SmsManager.getDefault();
//        smsManager.sendTextMessage(phoneNumbers, null, inviteMessage, null, null);
    }

    private void sendEmailInvites(String emailsString, String inviteMessage) {
        Uri emailsToUri = Uri.parse("mailto:" + emailsString);
        Intent i = new Intent(Intent.ACTION_SENDTO, emailsToUri);
        i.putExtra(Intent.EXTRA_TEXT, inviteMessage);
        startActivity(Intent.createChooser(i, getString(R.string.contacts_invite_via_link)));
    }

    private void sendSmsInvites(String phoneNumbersStrings, String inviteMessage) {
        Uri smsToUri = Uri.parse("smsto:" + phoneNumbersStrings);
        Intent i = new Intent(Intent.ACTION_SENDTO, smsToUri);
        i.putExtra("sms_body", inviteMessage);
        startActivity(i);
    }


    public InviteAdapter getAdapter() {
        return adapter;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (adapter != null) {
            adapter.dispose();
        }
    }
}
