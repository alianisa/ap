package im.actor.sdk.controllers.grouppre.admin;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import im.actor.core.entity.GroupPre;
import im.actor.core.entity.GroupType;
import im.actor.sdk.controllers.Intents;
import im.actor.sdk.controllers.activity.BaseFragmentActivity;

/**
 * Created by dsilv on 18/11/2017.
 */

public class GroupPreSelectParentActivity extends BaseFragmentActivity {

    public static Intent createIntent(Context ctx, int chatId, int groupType) {
        return new Intent(ctx, GroupPreSelectParentActivity.class)
                .putExtra(Intents.EXTRA_GROUP_ID, chatId)
                .putExtra(GroupPreSelectParentFragment.GROUP_TYPE_PARAM, groupType);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState == null) {
            showFragment(GroupPreSelectParentFragment.create(
                    getIntent().getIntExtra(Intents.EXTRA_GROUP_ID, GroupPre.DEFAULT_ID),
                    GroupPre.DEFAULT_ID,
                    getIntent().getIntExtra(GroupPreSelectParentFragment.GROUP_TYPE_PARAM, GroupType.GROUP)
            ), false);
        }
    }

}
