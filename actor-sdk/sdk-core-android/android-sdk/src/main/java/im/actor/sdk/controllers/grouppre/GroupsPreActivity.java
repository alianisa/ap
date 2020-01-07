package im.actor.sdk.controllers.grouppre;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import im.actor.core.entity.GroupPre;
import im.actor.core.entity.GroupType;
import im.actor.sdk.controllers.activity.BaseFragmentActivity;

/**
 * Created by diego on 26/12/2017.
 */

public class GroupsPreActivity extends BaseFragmentActivity {

    public static Intent createIntent(Context ctx, int groupType) {
        Intent i = new Intent(ctx, GroupsPreActivity.class);
        i.putExtra(GroupsPreFragment.GROUP_TYPE_PARAM, groupType);
        return i;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            showFragment(GroupsPreFragment.create(
                    getIntent().getIntExtra(GroupsPreFragment.GROUP_PARENT_ID_PARAM, GroupPre.DEFAULT_ID),
                    getIntent().getIntExtra(GroupsPreFragment.GROUP_TYPE_PARAM, GroupType.GROUP)),
                    false);
        }
    }

}