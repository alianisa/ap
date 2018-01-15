package im.actor.core;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.display.DisplayManager;
import android.media.ExifInterface;
import android.media.MediaMetadataRetriever;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.PowerManager;
import android.provider.ContactsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.view.Display;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Random;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import im.actor.core.entity.Contact;
import im.actor.core.entity.Dialog;
import im.actor.core.entity.Group;
import im.actor.core.entity.GroupPre;
import im.actor.core.entity.Message;
import im.actor.core.entity.Peer;
import im.actor.core.entity.SearchEntity;
import im.actor.core.entity.content.FastThumb;
import im.actor.core.network.NetworkState;
import im.actor.core.utils.AppStateActor;
import im.actor.core.utils.GalleryScannerActor;
import im.actor.core.utils.IOUtils;
import im.actor.core.utils.ImageHelper;
import im.actor.core.viewmodel.AppStateVM;
import im.actor.core.viewmodel.Command;
import im.actor.core.viewmodel.GalleryVM;
import im.actor.runtime.Log;
import im.actor.runtime.Runtime;
import im.actor.runtime.actors.Actor;
import im.actor.runtime.actors.ActorCreator;
import im.actor.runtime.actors.ActorRef;
import im.actor.runtime.actors.ActorSystem;
import im.actor.runtime.actors.Props;
import im.actor.runtime.android.AndroidContext;
import im.actor.runtime.eventbus.EventBus;
import im.actor.runtime.generic.mvvm.BindedDisplayList;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.runtime.storage.ListEngineDisplayExt;
import me.leolin.shortcutbadger.ShortcutBadger;

import static im.actor.runtime.actors.ActorSystem.system;

public class AndroidMessenger extends im.actor.core.Messenger {

    private final static String TAG = AndroidMessenger.class.getName();

    private final Executor fileDownloader = Executors.newSingleThreadExecutor();

    private Context context;
    private final Random random = new Random();
    private ActorRef appStateActor;
    private BindedDisplayList<Dialog> dialogList;
    private HashMap<Peer, BindedDisplayList<Message>> messagesLists = new HashMap<>();
    private HashMap<Peer, BindedDisplayList<Message>> docsLists = new HashMap<>();
    private HashMap<Peer, BindedDisplayList<Message>> photosList = new HashMap<>();
    private HashMap<Peer, BindedDisplayList<Message>> videosLists = new HashMap<>();

    private GalleryVM galleryVM;
    private ActorRef galleryScannerActor;

    public AndroidMessenger(Context context, im.actor.core.Configuration configuration) {
        super(configuration);

        this.context = context;

        this.appStateActor = system().actorOf("actor/android/state", () -> new AppStateActor(AndroidMessenger.this));

        // Catch all phone book changes
        Runtime.dispatch(() ->
                context.getContentResolver()
                        .registerContentObserver(ContactsContract.Contacts.CONTENT_URI, true,
                                new ContentObserver(null) {
                                    @Override
                                    public void onChange(boolean selfChange) {
                                        onPhoneBookChanged();
                                    }
                                }));

        // Counters
        modules.getConductor()
                .getGlobalStateVM()
                .getGlobalCounter()
                .subscribe((val, valueModel) -> {
                    if (val != null) {
                        ShortcutBadger.applyCount(AndroidContext.getContext(), val);
                    }
                });

        // Catch network change
        Runtime.dispatch(() -> context.registerReceiver(
                new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        Log.d(TAG, "Network Connection Changed");
                        verifyNetworkState(context);
                    }
                }, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)));

        Runtime.dispatch(() -> context.registerReceiver(
                new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        Log.d(TAG, "Idle Mode is changed");
                        verifyNetworkState(context);
                    }
                }, new IntentFilter(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)));


        // Screen change processor
        Runtime.dispatch(() -> {
            IntentFilter screenFilter = new IntentFilter();
            screenFilter.addAction(Intent.ACTION_SCREEN_OFF);
            screenFilter.addAction(Intent.ACTION_SCREEN_ON);
            context.registerReceiver(new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)) {
                        appStateActor.send(new AppStateActor.OnScreenOn());
                    } else if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)) {
                        appStateActor.send(new AppStateActor.OnScreenOff());
                    }
                }
            }, screenFilter);
            if (isScreenOn()) {
                appStateActor.send(new AppStateActor.OnScreenOn());
            } else {
                appStateActor.send(new AppStateActor.OnScreenOff());
            }
        });
    }

    private void verifyNetworkState(Context ctx) {
        ConnectivityManager cm =
                (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        boolean isConnected = activeNetwork != null && activeNetwork.isConnectedOrConnecting();

        int state;

        if (isConnected) {
            switch (activeNetwork.getType()) {
                case ConnectivityManager.TYPE_WIFI:
                case ConnectivityManager.TYPE_WIMAX:
                case ConnectivityManager.TYPE_ETHERNET:
                    state = NetworkState.WI_FI;
                    break;
                case ConnectivityManager.TYPE_MOBILE:
                    state = NetworkState.MOBILE;
                    break;
                default:
                    state = NetworkState.UNKNOWN;
            }
        } else {
            state = NetworkState.NO_CONNECTION;
        }

        Log.d(TAG, "Connection State: " + NetworkState.getDesription(state));
        onNetworkChanged(state);
    }

    public Context getContext() {
        return context;
    }

    @Override
    public void changeGroupAvatar(int gid, String descriptor) {
        try {
            Bitmap bmp = ImageHelper.loadOptimizedHQ(descriptor);
            if (bmp == null) {
                return;
            }
            String resultFileName = getExternalTempFile("image", "jpg");
            if (resultFileName == null) {
                return;
            }
            ImageHelper.save(bmp, resultFileName);

            super.changeGroupAvatar(gid, resultFileName);
        } catch (IOException e) {
            Log.e(TAG, e);
        }
    }

    @Override
    public void changeMyAvatar(String descriptor) {
        try {
            Bitmap bmp = ImageHelper.loadOptimizedHQ(descriptor);
            if (bmp == null) {
                return;
            }
            String resultFileName = getExternalTempFile("image", "jpg");
            if (resultFileName == null) {
                return;
            }
            ImageHelper.save(bmp, resultFileName);

            super.changeMyAvatar(resultFileName);
        } catch (IOException e) {
            Log.e(TAG, e);
        }
    }

    public void sendDocument(Peer peer, String fullFilePath) {
        sendDocument(peer, fullFilePath, new File(fullFilePath).getName());
    }

    public void sendDocument(Peer peer, String fullFilePath, String fileName) {

        int dot = fileName.indexOf('.');
        String mimeType = null;
        if (dot >= 0) {
            String ext = fileName.substring(dot + 1);
            mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
        }
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }

        Bitmap fastThumb = ImageHelper.loadOptimizedHQ(fullFilePath);
        if (fastThumb != null) {
            fastThumb = ImageHelper.scaleFit(fastThumb, 90, 90);
            byte[] fastThumbData = ImageHelper.save(fastThumb);
            sendDocument(peer, fileName, mimeType,
                    new FastThumb(fastThumb.getWidth(), fastThumb.getHeight(), fastThumbData),
                    fullFilePath);
        } else {
            sendDocument(peer, fileName, mimeType, fullFilePath);
        }
    }

    public void sendAnimation(Peer peer, String fullFilePath) {
        ImageHelper.BitmapSize size = ImageHelper.getImageSize(fullFilePath);
        if (size == null) {
            return;
        }

        Bitmap bmp = BitmapFactory.decodeFile(fullFilePath);
        if (bmp == null) {
            return;
        }
        Bitmap fastThumb = ImageHelper.scaleFit(bmp, 90, 90);

        byte[] fastThumbData = ImageHelper.save(fastThumb);

        sendAnimation(peer, fullFilePath, size.getWidth(), size.getHeight(),
                new FastThumb(fastThumb.getWidth(), fastThumb.getHeight(), fastThumbData), fullFilePath);
    }

    public void sendPhoto(Peer peer, String fullFilePath) {
        sendPhoto(peer, fullFilePath, new File(fullFilePath).getName());
    }

    public void sendPhoto(Peer peer, String fullFilePath, String fileName) {
        try {
            Bitmap bmp = ImageHelper.loadOptimizedHQ(fullFilePath);
            if (bmp == null) {
                return;
            }
            Bitmap fastThumb = ImageHelper.scaleFit(bmp, 90, 90);

            byte[] fastThumbData = ImageHelper.save(fastThumb);

            boolean isGif = fullFilePath.endsWith(".gif");

            String resultFileName = getExternalUploadTempFile("image", isGif ? "gif" : "jpg");
            if (resultFileName == null) {
                return;
            }

            if (isGif) {
                IOUtils.copy(new File(fullFilePath), new File(resultFileName));
                sendAnimation(peer, fileName, bmp.getWidth(), bmp.getHeight(), new FastThumb(fastThumb.getWidth(), fastThumb.getHeight(),
                        fastThumbData), resultFileName);
            } else {
                ImageHelper.save(bmp, resultFileName);
                sendPhoto(peer, fileName, bmp.getWidth(), bmp.getHeight(), new FastThumb(fastThumb.getWidth(), fastThumb.getHeight(),
                        fastThumbData), resultFileName);
            }

        } catch (Throwable t) {
            Log.e(TAG, t);
        }
    }

    public void sendVoice(Peer peer, int duration, String fullFilePath) {
        File f = new File(fullFilePath);
        sendAudio(peer, f.getName(), duration, fullFilePath);
    }

    public void sendVideo(Peer peer, String fullFilePath, boolean deleteOriginal) {
        sendVideo(peer, fullFilePath, new File(fullFilePath).getName(), deleteOriginal);
    }

    public void sendVideo(final Peer peer, final String fullFilePath, final String fileName, boolean deleteOriginal) {
        try {
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();

            retriever.setDataSource(fullFilePath);
            int duration = (int) (Long.parseLong(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)) / 1000L);
            Bitmap img = retriever.getFrameAtTime(0);
            int width = img.getWidth();
            int height = img.getHeight();
            Bitmap smallThumb = ImageHelper.scaleFit(img, 90, 90);
            byte[] smallThumbData = ImageHelper.save(smallThumb);

            FastThumb thumb = new FastThumb(smallThumb.getWidth(), smallThumb.getHeight(), smallThumbData);

            sendVideo(peer, fileName, width, height, duration, thumb, fullFilePath);

        } catch (Throwable e) {
            Log.e(TAG, e);
        }
    }

    public Command<Boolean> sendUri(final Peer peer, final Uri uri) {
        return sendUri(peer, uri, "actor");
    }

    public Command<Boolean> sendUri(final Peer peer, final Uri uri, String appName) {
        return callback -> fileDownloader.execute(() -> {

            String filePath;
            String mimeType;
            String fileName;

            String ext = "";

            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);

            if (cursor != null && cursor.moveToFirst()) {
                filePath = uri.getPath();
                mimeType = context.getContentResolver().getType(uri);
                fileName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                cursor.close();
            } else {
                filePath = uri.getPath();
                fileName = new File(uri.getPath()).getName();
                int index = fileName.lastIndexOf(".");

                if (index > 0) {
                    ext = fileName.substring(index + 1);
                    mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
                } else {
                    mimeType = "?/?";
                }
            }

            if (mimeType == null) {
                mimeType = "?/?";
            }

            if (filePath == null || !uri.getScheme().equals("file")) {

                File externalFile = Environment.getExternalStorageDirectory();

                if (externalFile == null) {
                    callback.onError(new NullPointerException());
                    return;
                }
                String externalPath = externalFile.getAbsolutePath();

                File dest = new File(externalPath + "/" + appName + "/" + appName + " images" + "/");

                dest.mkdirs();

                if (ext.isEmpty() && filePath != null) {
                    int index = filePath.lastIndexOf(".");
                    ext = filePath.substring(index + 1);
                }

                File outputFile = new File(dest, "upload_" + random.nextLong() + "." + ext);
                filePath = outputFile.getAbsolutePath();

                try {
                    IOUtils.copy(context.getContentResolver().openInputStream(uri), new File(filePath));
                } catch (IOException e) {
                    Log.e(TAG, e);
                    callback.onError(e);
                    return;
                }
            }

            if (fileName == null) {
                fileName = filePath;
            }

            if (!ext.isEmpty() && !fileName.endsWith(ext))
                fileName += "." + ext;
            if (mimeType.startsWith("video/")) {
                sendVideo(peer, filePath, fileName, false);
            } else if (mimeType.startsWith("image/")) {
                sendPhoto(peer, filePath, new File(fileName).getName());
            } else {
                sendDocument(peer, filePath, new File(fileName).getName());
            }
            callback.onResult(true);
        });
    }

    public void onActivityOpen() {
        appStateActor.send(new AppStateActor.OnActivityOpened());
    }

    public void onActivityClosed() {
        appStateActor.send(new AppStateActor.OnActivityClosed());
    }

    public BindedDisplayList<SearchEntity> buildSearchDisplayList() {
        return (BindedDisplayList<SearchEntity>) modules.getDisplayListsModule().buildSearchList(false);
    }

    public BindedDisplayList<Contact> buildContactsDisplayList() {
        return (BindedDisplayList<Contact>) modules.getDisplayListsModule().buildContactList(false);
    }

    private boolean isScreenOn() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            DisplayManager dm = (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
            boolean screenOn = false;
            for (Display display : dm.getDisplays()) {
                if (display.getState() != Display.STATE_OFF) {
                    screenOn = true;
                }
            }
            return screenOn;
        } else {
            PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            //noinspection deprecation
            return pm.isScreenOn();
        }
    }

    public String getExternalTempFile(String prefix, String postfix) {
        File externalFile = context.getExternalFilesDir(null);
        if (externalFile == null) {
            return null;
        }
        String externalPath = externalFile.getAbsolutePath();

        File dest = new File(externalPath + "/actor/tmp/");
        dest.mkdirs();

        File outputFile = new File(dest, prefix + "_" + random.nextLong() + "." + postfix);
        return outputFile.getAbsolutePath();
    }


    public String getExternalUploadTempFile(String prefix, String postfix) {
        File externalFile = context.getExternalFilesDir(null);
        if (externalFile == null) {
            return null;
        }
        String externalPath = externalFile.getAbsolutePath();

        File dest = new File(externalPath + "/actor/upload_tmp/");
        dest.mkdirs();

        File outputFile = new File(dest, prefix + "_" + random.nextLong() + "." + postfix);
        return outputFile.getAbsolutePath();
    }

    public String getInternalTempFile(String prefix, String postfix) {
        File externalFile = context.getFilesDir();
        if (externalFile == null) {
            return null;
        }
        String externalPath = externalFile.getAbsolutePath();

        File dest = new File(externalPath + "/actor/tmp/");
        dest.mkdirs();

        File outputFile = new File(dest, prefix + "_" + random.nextLong() + "." + postfix);
        return outputFile.getAbsolutePath();
    }

    public BindedDisplayList<Dialog> getDialogsDisplayList() {
        if (dialogList == null) {
            dialogList = (BindedDisplayList<Dialog>) modules.getDisplayListsModule().getDialogsSharedList();
            dialogList.setBindHook(new BindedDisplayList.BindHook<Dialog>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreDialogs();
                }

                @Override
                public void onItemTouched(Dialog item) {
                    Log.d(AndroidMessenger.class.getName(), "Title" + item.getDialogTitle());
                    Log.d(AndroidMessenger.class.getName(), "IsBot" + item.isBot());
                    Log.d(AndroidMessenger.class.getName(), "IsChannel" + item.isChannel());
                }
            });
        }
        return dialogList;
    }

    public BindedDisplayList<Message> getMessageDisplayList(final Peer peer) {
        if (!messagesLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getMessagesSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            messagesLists.put(peer, list);
        }

        return messagesLists.get(peer);
    }

    public BindedDisplayList<Message> getDocsDisplayList(final Peer peer) {
        if (!docsLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getDocsSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreDocsHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            docsLists.put(peer, list);
        }
        return docsLists.get(peer);
    }

    public BindedDisplayList<Message> getPhotosDisplayList(final Peer peer) {
        if (!photosList.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getPhotosSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMorePhotosHistory(peer);
                }

                @Override
                public void onItemTouched(Message item) {

                }
            });
            photosList.put(peer, list);
        }
        return photosList.get(peer);
    }

    public BindedDisplayList<Message> getVideosDisplayList(final Peer peer) {
        if (!videosLists.containsKey(peer)) {
            BindedDisplayList<Message> list = (BindedDisplayList<Message>) modules.getDisplayListsModule().getVideoSharedList(peer);
            list.setBindHook(new BindedDisplayList.BindHook<Message>() {
                @Override
                public void onScrolledToEnd() {
                    modules.getMessagesModule().loadMoreVideosHistory(peer);
                }
                @Override
                public void onItemTouched(Message item) {

                }
            });
            videosLists.put(peer, list);
        }
        return videosLists.get(peer);
    }

    public BindedDisplayList<GroupPre> getGroupPreDisplayList(Integer idGrupoPai, Integer type, int groupId) {

        BindedDisplayList<GroupPre> groupPreList = (BindedDisplayList<GroupPre>) modules.getDisplayListsModule().buildGrupoPreList(idGrupoPai, false);

        return groupPreList;
    }

    public SimpleBindedDisplayList<GroupPre> getGroupsPreSimpleDisplayList(Integer parentId,
                                                                           SimpleBindedDisplayList.Filter<GroupPre> filter){
       return new SimpleBindedDisplayList<>((ListEngineDisplayExt<GroupPre>) modules.getGrupoPreModule().getGrupospreEngine(parentId),
               filter);
    }

    public GalleryVM getGalleryVM() {
        if (galleryVM == null) {
            galleryVM = new GalleryVM();
            checkGalleryScannerActor();
        }
        return galleryVM;
    }

    protected void checkGalleryScannerActor() {
        if (galleryScannerActor == null) {
            galleryScannerActor = ActorSystem.system().actorOf(Props.create(new ActorCreator() {
                @Override
                public Actor create() {
                    return new GalleryScannerActor(AndroidContext.getContext(), galleryVM);
                }
            }), "actor/gallery_scanner");
        }
    }

    public ActorRef getGalleryScannerActor() {
        checkGalleryScannerActor();
        return galleryScannerActor;
    }

    public EventBus getEvents() {
        return modules.getEvents();
    }

    public AppStateVM getAppStateVM() {
        return modules.getConductor().getAppStateVM();
    }

    public void startImport() {
        modules.getContactsModule().startImport();
    }

//    @Override
//    public void onLoggedIn() {
//        super.onLoggedIn();
//    }
}