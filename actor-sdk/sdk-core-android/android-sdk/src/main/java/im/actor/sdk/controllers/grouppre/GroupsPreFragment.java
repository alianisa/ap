package im.actor.sdk.controllers.grouppre;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.helper.ItemTouchHelper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import im.actor.core.entity.GroupPre;
import im.actor.core.entity.GroupType;
import im.actor.core.viewmodel.GroupVM;
import im.actor.runtime.Log;
import im.actor.runtime.android.view.SimpleBindedListAdapter;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.Intents;
import im.actor.sdk.controllers.SimpleDisplayListFragment;
import im.actor.sdk.controllers.grouppre.view.GrupoPreHolder;
import im.actor.sdk.controllers.grouppre.view.GrupoPreSimpleAdapter;
import im.actor.sdk.util.Screen;
import im.actor.sdk.util.SnackUtils;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.drag.OnStartDragListener;
import im.actor.sdk.view.drag.SimpleItemTouchHelperCallback;

import static im.actor.sdk.util.ActorSDKMessenger.groups;
import static im.actor.sdk.util.ActorSDKMessenger.messenger;
import static im.actor.sdk.util.ActorSDKMessenger.myUid;
import static im.actor.sdk.util.ActorSDKMessenger.users;

/**
 * Created by diego on 13/05/17.
 */

public class GroupsPreFragment extends SimpleDisplayListFragment<GroupPre, GrupoPreHolder>
        implements OnStartDragListener {

    private static final String TAG = GroupsPreFragment.class.getName();

    public static final String GROUP_TYPE_PARAM = "groupType";
    public static final String GROUP_PARENT_ID_PARAM = "groupParentId";

    private int parentId = GroupPre.DEFAULT_ID;
    private int groupType = GroupType.GROUP;
    private GroupVM parentVm;

    private View emptyGroups;
    private View loadingGroups;

    private ItemTouchHelper itemTouchHelper;

    public static GroupsPreFragment create(int parentId, int groupType) {
        Bundle bundle = new Bundle();
        bundle.putInt(GROUP_PARENT_ID_PARAM, parentId);
        bundle.putInt(GROUP_TYPE_PARAM, groupType);
        GroupsPreFragment fragment = new GroupsPreFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle saveInstance) {
        super.onCreate(saveInstance);
        parentId = getArguments().getInt(GROUP_PARENT_ID_PARAM, GroupPre.DEFAULT_ID);
        groupType = getArguments().getInt(GROUP_TYPE_PARAM, GroupType.GROUP);
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
        emptyGroups.setVisibility(View.GONE);

        loadingGroups = res.findViewById(R.id.loadingGroups);



        return res;
    }

    @Override
    protected void onListStateChange(SimpleBindedDisplayList.State state) {
        super.onListStateChange(state);
        if(state == SimpleBindedDisplayList.State.LOADED){
            emptyGroups.setVisibility(View.GONE);
            loadingGroups.setVisibility(View.GONE);
        }else if(state == SimpleBindedDisplayList.State.LOADED_EMPTY){
            emptyGroups.setVisibility(View.VISIBLE);
            loadingGroups.setVisibility(View.GONE);
        }else if(state == SimpleBindedDisplayList.State.LOADING_EMPTY){
            emptyGroups.setVisibility(View.GONE);
            loadingGroups.setVisibility(View.VISIBLE);
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
        }, this, getActivity());
    }


    @Override
    protected void afterAdapterCreated() {
        super.afterAdapterCreated();
        configureDrag();
    }

    private void configureDrag(){
        bind(users().get(myUid()).getPhones(), phones -> {
            boolean isSupport = false;
            if(!phones.isEmpty()){
                for(int i = 0; i < phones.size();i++){
                    String helpPhoneNumber = ActorSDK.sharedActor().getHelpPhone().replaceAll("[^0-9]", "");
                    if(Long.parseLong(helpPhoneNumber) == phones.get(i).getPhone()){
                        isSupport = true;
                    }
                }
            }

            if(isSupport){
                SimpleItemTouchHelperCallback callback = new SimpleItemTouchHelperCallback(getAdapter());
                callback.setItemViewSwipeEnabled(false);
                itemTouchHelper = new ItemTouchHelper(callback);
                itemTouchHelper.attachToRecyclerView(getCollection());
            }
        });
    }


    private void enterInGroupById(GroupPre groupPre){
        GroupVM groupVM = groups().get(groupPre.getGroupId());
        if (groupVM.isMember().get()) {
            startActivity(Intents.openGroupDialog(groupPre.getGroupId(), true, getActivity()));
        } else {
            final ProgressDialog dialog = ProgressDialog.show(getContext(), "", getString(R.string.entering), true, false);
            messenger().joinGroupById(groupPre.getGroupId()).then(aVoid -> {
                dialog.dismiss();
                startActivity(Intents.openGroupDialog(groupPre.getGroupId(), true, getActivity()));
            }).failure(e -> {
                dialog.dismiss();
                Log.e(TAG, e);
                SnackUtils.showError(getView(), getString(R.string.you_can_not_enter), Snackbar.LENGTH_INDEFINITE,
                        view -> enterInGroupById(groupPre), getString(R.string.dialog_try_again));
            });
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if(parentId > GroupPre.DEFAULT_ID){
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

    @Override
    public void onStartDrag(RecyclerView.ViewHolder viewHolder) {
        if(itemTouchHelper != null)
            itemTouchHelper.startDrag(viewHolder);
    }
}
