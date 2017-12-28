package im.actor.sdk.controllers.grouppre;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;


import im.actor.core.entity.Group;
import im.actor.core.entity.GroupPre;
import im.actor.core.entity.GroupType;
import im.actor.core.viewmodel.GroupVM;
import im.actor.runtime.Log;
import im.actor.runtime.android.view.BindedListAdapter;
import im.actor.runtime.android.view.SimpleBindedListAdapter;
import im.actor.runtime.generic.mvvm.BindedDisplayList;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.DisplayListFragment;
import im.actor.sdk.controllers.Intents;
import im.actor.sdk.controllers.SimpleDisplayListFragment;
import im.actor.sdk.controllers.grouppre.admin.GroupPreSelectParentFragment;
import im.actor.sdk.controllers.grouppre.view.GrupoPreAdapter;
import im.actor.sdk.controllers.grouppre.view.GrupoPreHolder;
import im.actor.sdk.controllers.grouppre.view.GrupoPreSimpleAdapter;
import im.actor.sdk.util.Screen;
import im.actor.sdk.util.SnackUtils;
import im.actor.sdk.view.adapters.OnItemClickedListener;

import static im.actor.sdk.util.ActorSDKMessenger.groups;
import static im.actor.sdk.util.ActorSDKMessenger.messenger;

/**
 * Created by diego on 13/05/17.
 */

public class GroupsPreFragment extends SimpleDisplayListFragment<GroupPre, GrupoPreHolder> {

    private static final String TAG = GroupsPreFragment.class.getName();

    private int parentId = GroupPre.DEFAULT_ID;
    private int groupType = GroupType.GROUP;
    private GroupVM parentVm;

    private View emptyGroups;


    public static GroupsPreFragment create(int parentId, int groupType) {
        Bundle bundle = new Bundle();
        bundle.putInt("parentId", parentId);
        bundle.putInt("groupType", groupType);
        GroupsPreFragment fragment = new GroupsPreFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle saveInstance) {
        super.onCreate(saveInstance);
        parentId = getArguments().getInt("parentId", GroupPre.DEFAULT_ID);
        groupType = getArguments().getInt("groupType", GroupType.GROUP);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        SimpleBindedDisplayList<GroupPre> displayList = ActorSDK.sharedActor().getMessenger().getGroupsPreSimpleDisplayList(parentId,
                value -> (groupType == messenger().getGroup(value.getGroupId()).getGroupType()));

        View res = inflate(inflater, container, R.layout.fragment_grupos_pre, displayList);
        res.setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());

        // Footer
        FrameLayout footer = new FrameLayout(getActivity());
        footer.setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, Screen.dp(160)));
        footer.setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());
        addFooterView(footer);

        // Header
        View header = new View(getActivity());
        header.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                Screen.dp(ActorSDK.sharedActor().style.getDialogsPaddingTopDp())));
        header.setBackgroundColor(ActorSDK.sharedActor().style.getMainBackgroundColor());
        addHeaderView(header);

        // Empty View
        emptyGroups = res.findViewById(R.id.emptyGroups);
        ((TextView) emptyGroups.findViewById(R.id.empty_groups_text)).setTextColor(ActorSDK.sharedActor().style.getMainColor());
        emptyGroups.findViewById(R.id.empty_groups_bg).setBackgroundColor(ActorSDK.sharedActor().style.getMainColor());
        emptyGroups.setVisibility(View.GONE);
        return res;
    }

    @Override
    protected void onListStateChange(SimpleBindedDisplayList.State state) {
        super.onListStateChange(state);

        if(state == SimpleBindedDisplayList.State.LOADED){
            emptyGroups.setVisibility(View.GONE);
        }else{
            emptyGroups.setVisibility(View.VISIBLE);
        }
    }

    @Override
    protected SimpleBindedListAdapter onCreateAdapter(SimpleBindedDisplayList displayList, Activity activity) {
        return new GrupoPreSimpleAdapter(displayList, new OnItemClickedListener<GroupPre>() {
            @Override
            public void onClicked(GroupPre groupPre) {
                if(groupPre.getHasChildren()){
                    ((GroupsPreActivity)getActivity()).showFragment(GroupsPreFragment.create(
                            groupPre.getGroupId(), groupType),true);
                }else{
                    enterInGroupById(groupPre);
                }
            }
            @Override
            public boolean onLongClicked(GroupPre item) {
                return false;
            }
        }, getActivity());
    }

    private void enterInGroupById(GroupPre groupPre){
        GroupVM groupVM = groups().get(groupPre.getGroupId());
        if (groupVM.isMember().get()) {
            startActivity(Intents.openGroupDialog(groupPre.getGroupId(), true, getActivity()));
        } else {
            final ProgressDialog dialog = ProgressDialog.show(getContext(), "", "Entrando", true, false);
            messenger().joinGroupById(groupPre.getGroupId()).then(aVoid -> {
                dialog.dismiss();
                startActivity(Intents.openGroupDialog(groupPre.getGroupId(), true, getActivity()));
            }).failure(e -> {
                dialog.dismiss();
                Log.e(TAG, e);
                SnackUtils.showError(getView(), "Você não pode entrar neste grupo", Snackbar.LENGTH_INDEFINITE,
                        view -> enterInGroupById(groupPre), "Tentar Novamente");
            });
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        if(parentId > 0){
            parentVm = groups().get(parentId);
            bind(parentVm.getName(), val -> setTitle(val));
        }else{
            if(groupType == GroupType.CHANNEL){
                setTitle(getString(R.string.predefined_channel));
            }else {
                setTitle(getString(R.string.predefined_group));
            }
        }
    }
}
