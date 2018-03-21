package im.actor.core.js.entity;

import com.google.gwt.core.client.JavaScriptObject;

import im.actor.core.api.ApiAdminSettings;
import im.actor.core.entity.GroupPermissions;
import im.actor.runtime.js.mvvm.JsEntityConverter;

public class JsGroupPermissions extends JavaScriptObject {

    public static JsEntityConverter<GroupPermissions, JsGroupPermissions> CONVERTER
            = new JsEntityConverter<GroupPermissions, JsGroupPermissions>() {
        @Override
        public JsGroupPermissions convert(GroupPermissions value) {
            return create(value.isShowAdminsToMembers(), value.isMembersCanInvite(),
                    value.isMembersCanEditInfo(), value.isAdminsCanEditGroupInfo(),
                    value.isShowJoinLeaveMessages());
        }

        @Override
        public boolean isSupportOverlays() {
            return false;
        }

        @Override
        public JavaScriptObject buildOverlay(GroupPermissions prev, GroupPermissions current, GroupPermissions next) {
            return null;
        }
    };

    public static native JsGroupPermissions create(boolean showAdminsToMembers, boolean canMembersInvite, boolean canMembersEditGroupInfo,
                                                   boolean canAdminsEditGroupInfo, boolean showJoinLeaveMessages)/*-{
        return {showAdminsToMembers: showAdminsToMembers, canMembersInvite: canMembersInvite,
            canMembersEditGroupInfo: canMembersEditGroupInfo, canAdminsEditGroupInfo: canAdminsEditGroupInfo, showJoinLeaveMessages: showJoinLeaveMessages};
    }-*/;

    protected JsGroupPermissions() {

    }

    public final native boolean isShowAdminsToMembers()/*-{ return this.showAdminsToMembers; }-*/;

    public final native boolean isCanMembersInvite()/*-{ return this.canMembersInvite; }-*/;

    public final native boolean isCanMembersEditGroupInfo()/*-{ return this.canMembersEditGroupInfo; }-*/;

    public final native boolean isCanAdminsEditGroupInfo()/*-{ return this.canAdminsEditGroupInfo; }-*/;

    public final native boolean isShowJoinLeaveMessages()/*-{ return this.showJoinLeaveMessages; }-*/;


    public final GroupPermissions convert() {
       return new GroupPermissions(new ApiAdminSettings(
               isShowAdminsToMembers(),
               isCanMembersInvite(),
               isCanMembersEditGroupInfo(),
               isCanAdminsEditGroupInfo(),
               isShowJoinLeaveMessages()
       ));
    }
}