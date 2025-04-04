package im.actor.core.api;
/*
 *  Generated by the Actor API Scheme generator.  DO NOT EDIT!
 */

import im.actor.runtime.bser.*;
import im.actor.runtime.collections.*;
import static im.actor.runtime.bser.Utils.*;
import im.actor.core.network.parser.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;
import com.google.j2objc.annotations.ObjectiveCName;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

public class ApiGroupFull extends BserObject {

    private int id;
    private long createDate;
    private Integer ownerUid;
    private List<ApiMember> members;
    private String theme;
    private String about;
    private ApiMapValue ext;
    private Boolean isAsyncMembers;
    private Boolean isSharedHistory;
    private String shortName;
    private Long permissions;
    private String restrictedDomains;
    private ApiLocation location;

    public ApiGroupFull(int id, long createDate, @Nullable Integer ownerUid, @NotNull List<ApiMember> members, @Nullable String theme, @Nullable String about, @Nullable ApiMapValue ext, @Nullable Boolean isAsyncMembers, @Nullable Boolean isSharedHistory, @Nullable String shortName, @Nullable Long permissions, @Nullable String restrictedDomains, @Nullable ApiLocation location) {
        this.id = id;
        this.createDate = createDate;
        this.ownerUid = ownerUid;
        this.members = members;
        this.theme = theme;
        this.about = about;
        this.ext = ext;
        this.isAsyncMembers = isAsyncMembers;
        this.isSharedHistory = isSharedHistory;
        this.shortName = shortName;
        this.permissions = permissions;
        this.restrictedDomains = restrictedDomains;
        this.location = location;
    }

    public ApiGroupFull() {

    }

    public int getId() {
        return this.id;
    }

    public long getCreateDate() {
        return this.createDate;
    }

    @Nullable
    public Integer getOwnerUid() {
        return this.ownerUid;
    }

    @NotNull
    public List<ApiMember> getMembers() {
        return this.members;
    }

    @Nullable
    public String getTheme() {
        return this.theme;
    }

    @Nullable
    public String getAbout() {
        return this.about;
    }

    @Nullable
    public ApiMapValue getExt() {
        return this.ext;
    }

    @Nullable
    public Boolean isAsyncMembers() {
        return this.isAsyncMembers;
    }

    @Nullable
    public Boolean isSharedHistory() {
        return this.isSharedHistory;
    }

    @Nullable
    public String getShortName() {
        return this.shortName;
    }

    @Nullable
    public Long getPermissions() {
        return this.permissions;
    }

    @Nullable
    public String getRestrictedDomains() {
        return this.restrictedDomains;
    }

    @Nullable
    public ApiLocation getLocation() {
        return this.location;
    }

    @Override
    public void parse(BserValues values) throws IOException {
        this.id = values.getInt(1);
        this.createDate = values.getLong(6);
        this.ownerUid = values.optInt(5);
        List<ApiMember> _members = new ArrayList<ApiMember>();
        for (int i = 0; i < values.getRepeatedCount(12); i ++) {
            _members.add(new ApiMember());
        }
        this.members = values.getRepeatedObj(12, _members);
        this.theme = values.optString(2);
        this.about = values.optString(3);
        this.ext = values.optObj(7, new ApiMapValue());
        this.isAsyncMembers = values.optBool(11);
        this.isSharedHistory = values.optBool(10);
        this.shortName = values.optString(14);
        this.permissions = values.optLong(27);
        this.restrictedDomains = values.optString(28);
        this.location = values.optObj(29, new ApiLocation());
        if (values.hasRemaining()) {
            setUnmappedObjects(values.buildRemaining());
        }
    }

    @Override
    public void serialize(BserWriter writer) throws IOException {
        writer.writeInt(1, this.id);
        writer.writeLong(6, this.createDate);
        if (this.ownerUid != null) {
            writer.writeInt(5, this.ownerUid);
        }
        writer.writeRepeatedObj(12, this.members);
        if (this.theme != null) {
            writer.writeString(2, this.theme);
        }
        if (this.about != null) {
            writer.writeString(3, this.about);
        }
        if (this.ext != null) {
            writer.writeObject(7, this.ext);
        }
        if (this.isAsyncMembers != null) {
            writer.writeBool(11, this.isAsyncMembers);
        }
        if (this.isSharedHistory != null) {
            writer.writeBool(10, this.isSharedHistory);
        }
        if (this.shortName != null) {
            writer.writeString(14, this.shortName);
        }
        if (this.permissions != null) {
            writer.writeLong(27, this.permissions);
        }
        if (this.restrictedDomains != null) {
            writer.writeString(28, this.restrictedDomains);
        }
        if (this.location != null) {
            writer.writeObject(29, this.location);
        }
        if (this.getUnmappedObjects() != null) {
            SparseArray<Object> unmapped = this.getUnmappedObjects();
            for (int i = 0; i < unmapped.size(); i++) {
                int key = unmapped.keyAt(i);
                writer.writeUnmapped(key, unmapped.get(key));
            }
        }
    }

    @Override
    public String toString() {
        String res = "struct GroupFull{";
        res += "id=" + this.id;
        res += ", createDate=" + this.createDate;
        res += ", ownerUid=" + this.ownerUid;
        res += ", members=" + this.members;
        res += ", theme=" + this.theme;
        res += ", about=" + this.about;
        res += ", isAsyncMembers=" + this.isAsyncMembers;
        res += ", isSharedHistory=" + this.isSharedHistory;
        res += ", shortName=" + this.shortName;
        res += ", permissions=" + this.permissions;
        res += "}";
        return res;
    }

}
