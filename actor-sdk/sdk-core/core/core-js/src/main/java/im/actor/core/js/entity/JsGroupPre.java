/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.js.entity;

import com.google.gwt.core.client.JavaScriptObject;
import im.actor.core.js.JsMessenger;
import im.actor.core.viewmodel.GroupPreVM;

public class JsGroupPre extends JavaScriptObject {

    public static JsGroupPre fromGroupVM(GroupPreVM groupPreVM, JsMessenger messenger) {
        int parentId = groupPreVM.getParentId().get();
        boolean isLoaded = groupPreVM.getIsLoaded().get();
        boolean hasChildren = groupPreVM.getHasChildren().get();
        return create(parentId, isLoaded, hasChildren);
    }

    public static native JsGroupPre create(int parentId, boolean isLoaded, boolean hasChildren)/*-{
        return {
            parentId: parentId, isLoaded: isLoaded, hasChildren: hasChildren
        };
    }-*/;

    protected JsGroupPre() {

    }
}
