package im.actor.core.viewmodel;

import im.actor.core.entity.GroupPre;
import im.actor.core.viewmodel.generics.BooleanValueModel;
import im.actor.runtime.mvvm.BaseValueModel;
import im.actor.runtime.mvvm.ValueModel;
import im.actor.runtime.mvvm.ValueModelCreator;

/**
 * Created by diego on 27/10/17.
 */

public class GroupPreVM extends BaseValueModel<GroupPre> {

    public static ValueModelCreator<GroupPre, GroupPreVM> CREATOR = baseValue -> new GroupPreVM(baseValue);

    private ValueModel<Integer> parentId;
    private BooleanValueModel isLoaded;
    private BooleanValueModel hasChildren;

    public GroupPreVM(GroupPre rawObj) {
        super(rawObj);
        parentId = new ValueModel<Integer>("grupo_pre.parent_id." + rawObj.getGroupId(), rawObj.getParentId());
        isLoaded = new BooleanValueModel("grupo_pre.is_loaded." + rawObj.getGroupId(), rawObj.getLoaded());
        hasChildren = new BooleanValueModel("grupo_pre.has_children." + rawObj.getGroupId(), rawObj.getHasChildren());
    }

    @Override
    protected void updateValues(GroupPre rawObj) {
        isLoaded.change(rawObj.getLoaded());
        parentId.change(rawObj.getParentId());
        hasChildren.change(rawObj.getHasChildren());
    }

    public BooleanValueModel getIsLoaded() {
        return isLoaded;
    }

    public ValueModel<Integer> getParentId() {
        return parentId;
    }

    public BooleanValueModel getHasChildren() {
        return hasChildren;
    }
}