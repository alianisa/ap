package im.actor.runtime.video;

import com.google.j2objc.annotations.ObjectiveCName;
import com.google.j2objc.annotations.Property;

import org.jetbrains.annotations.NotNull;

import im.actor.runtime.actors.ActorRef;
import im.actor.runtime.annotations.Stable;

/**
 * Created by diego on 14/05/17.
 */
@Stable
public class CompressedVideo {

    @NotNull
    @Property("readonly, nonatomic")
    private long rid;
    @NotNull
    @Property("readonly, nonatomic")
    private String fileName;
    @NotNull
    @Property("readonly, nonatomic")
    private String filePath;
    @NotNull
    @Property("readonly, nonatomic")
    private ActorRef sender;

    @ObjectiveCName("initWithRid:withFileName:withFilePath:withSender:")
    public CompressedVideo(long rid, String fileName, String filePath, ActorRef sender) {
        this.rid = rid;
        this.fileName = fileName;
        this.filePath = filePath;
        this.sender = sender;
    }

    @ObjectiveCName("getRid")
    public long getRid() {
        return rid;
    }

    @ObjectiveCName("getFileName")
    public String getFileName() {
        return fileName;
    }

    @ObjectiveCName("getFilePath")
    public String getFilePath() {
        return filePath;
    }

    @ObjectiveCName("getSender")
    public ActorRef getSender() {
        return sender;
    }
}
