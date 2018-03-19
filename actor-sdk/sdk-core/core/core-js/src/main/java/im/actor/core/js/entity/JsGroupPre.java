/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.js.entity;

import com.google.gwt.core.client.JavaScriptObject;

import im.actor.core.entity.Contact;
import im.actor.core.entity.GroupPre;
import im.actor.core.js.JsMessenger;
import im.actor.core.viewmodel.GroupPreVM;
import im.actor.runtime.js.mvvm.JsEntityConverter;

public class JsGroupPre extends JavaScriptObject {

    public static JsEntityConverter<GroupPre, JsGroupPre> CONVERTER = new JsEntityConverter<GroupPre, JsGroupPre>() {
        @Override
        public JsGroupPre convert(GroupPre value) {
            return create(value.getGroupId(), value.getParentId(), value.getLoaded(), value.getHasChildren());
        }

        @Override
        public boolean isSupportOverlays() {
            return false;
        }

        @Override
        public JavaScriptObject buildOverlay(GroupPre prev, GroupPre current, GroupPre next) {
            return null;
        }
    };

    public static native JsGroupPre create(int groupId, int parentId, boolean isLoaded, boolean hasChildren)/*-{
        return {
            groupId: groupId, parentId: parentId, isLoaded: isLoaded, hasChildren: hasChildren
        };
    }-*/;

    protected JsGroupPre() {

    }
}
