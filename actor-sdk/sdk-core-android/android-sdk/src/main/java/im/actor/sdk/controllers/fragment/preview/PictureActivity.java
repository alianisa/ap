package im.actor.sdk.controllers.fragment.preview;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.v13.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.droidkit.progress.CircularView;
import com.github.chrisbanes.photoview.PhotoView;
import com.github.chrisbanes.photoview.PhotoViewAttacher;

import java.io.File;
import java.io.IOException;

import im.actor.core.entity.FileReference;
import im.actor.core.viewmodel.UserVM;
import im.actor.runtime.Log;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.R;
import im.actor.sdk.controllers.Intents;
import im.actor.sdk.controllers.activity.BaseActivity;
import im.actor.sdk.util.Files;
import im.actor.sdk.util.Randoms;
import im.actor.sdk.util.Screen;
import im.actor.sdk.util.images.common.ImageLoadException;
import im.actor.sdk.util.images.ops.ImageLoading;
import im.actor.sdk.view.MaterialInterpolator;
import im.actor.sdk.view.avatar.AvatarView;

import static im.actor.sdk.util.ActorSDKMessenger.users;

public class PictureActivity extends BaseActivity {

    private static final String TAG = PictureActivity.class.getName();

    private static final int PERMISSION_REQ_MEDIA = 0;

    private static final String ARG_FILE_SIZE = "ARG_FILE_SIZE";
    private static final String ARG_FILE_ACCESS_HASH = "ARG_FILE_ACCESS";
    private static final String ARG_FILE_NAME = "ARG_FILE_NAME";
    private static final String ARG_FILE_PATH = "arg_file_path";
    private static final String ARG_FILE_ID = "arg_file_id";
    private static final String ARG_OWNER = "arg_owner";
    private static final String ARG_TIMER = "arg_timer";
    private static final String ARG_IMAGE_TOP = "arg_image_top";
    private static final String ARG_IMAGE_LEFT = "arg_image_left";
    private static final String ARG_IMAGE_WIDTH = "arg_image_width";
    private static final String ARG_IMAGE_HEIGHT = "arg_image_height";
    private static int animationMultiplier = 1;
    private ImageView transitionView;

    private int transitionTop;
    private int transitionLeft;
    private int transitionWidth;
    private int transitionHeight;
    private View backgroundView;
    private PictureFragment fragment;
    private String path;
    private float bitmapWidth, bitmapHeight;
    private boolean uiIsHidden;
    private Toolbar toolbar;
    private View containerView;
    private boolean finished = false;

    public static void launchPhoto(Activity activity, View transitionView, String path, int senderId) {

        Intent intent = new Intent(activity, PictureActivity.class);
        intent.putExtra(ARG_FILE_PATH, path);
        intent.putExtra(ARG_OWNER, senderId);

        int[] location = new int[2];
        transitionView.getLocationInWindow(location);
        intent.putExtra(ARG_IMAGE_TOP, location[1]);
        intent.putExtra(ARG_IMAGE_LEFT, location[0]);
        intent.putExtra(ARG_IMAGE_WIDTH, transitionView.getWidth());
        intent.putExtra(ARG_IMAGE_HEIGHT, transitionView.getHeight());

        activity.startActivity(intent);
        activity.overridePendingTransition(0, 0);
    }

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_picture);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setDisplayShowHomeEnabled(false);
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setDisplayShowCustomEnabled(false);
        actionBar.setTitle(R.string.media_picture);

        int statbarHeight = Screen.getStatusBarHeight();

        if (Build.VERSION.SDK_INT >= 19) {
            toolbar.setPadding(0, statbarHeight, 0, 0);
        }

        final Bundle bundle = getIntent().getExtras();
        path = bundle.getString(ARG_FILE_PATH);
        int sender = bundle.getInt(ARG_OWNER, 0);

        toolbar.setVisibility(View.GONE);

        transitionTop = bundle.getInt(ARG_IMAGE_TOP, 0);
        transitionLeft = bundle.getInt(ARG_IMAGE_LEFT, 0);
        transitionWidth = bundle.getInt(ARG_IMAGE_WIDTH, 0);
        transitionHeight = bundle.getInt(ARG_IMAGE_HEIGHT, 0);

        transitionView = (ImageView) findViewById(R.id.transition);
        backgroundView = findViewById(R.id.background);
        containerView = findViewById(R.id.container);
        containerView.setAlpha(0);
        fragment = new PictureFragment();
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .add(R.id.container, fragment)
                .commit();


        Bitmap bitmap = null;
        try {
            bitmap = ImageLoading.loadBitmapOptimized(path);
            bitmapWidth = bitmap.getWidth();
            bitmapHeight = bitmap.getHeight();
        } catch (ImageLoadException e) {
            return;
        }
        transitionView.setImageBitmap(bitmap);
        if (bitmap != null)
            bitmap = null;

        MediaFullscreenAnimationUtils.animateForward(transitionView, bitmapWidth, bitmapHeight, transitionLeft, transitionTop, transitionWidth, transitionHeight,
                new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        containerView.setAlpha(1);
                        transitionView.setAlpha(0f);
                    }
                });
        MediaFullscreenAnimationUtils.animateBackgroundForward(backgroundView, null);
    }

    @Override
    public void onBackPressed() {
        finish();
    }

    @Override
    public void finish() {
        // transitionView.setVisibility(View.VISIBLE);
        if (finished) {
            return;
        }
        finished = true;
        transitionView.setAlpha(1f);
        transitionView.postDelayed(new Runnable() {
            @Override
            public void run() {
                getSupportFragmentManager().beginTransaction()
                        .remove(fragment)
                        .commit();
                containerView.setVisibility(View.GONE);

                MediaFullscreenAnimationUtils.animateBack(transitionView, bitmapWidth, bitmapHeight, transitionLeft, transitionTop, transitionWidth, transitionHeight,
                        new AnimatorListenerAdapter() {
                            @Override
                            public void onAnimationEnd(Animator animation) {
                                PictureActivity.super.finish();
                                overridePendingTransition(0, 0);
                            }
                        });
                MediaFullscreenAnimationUtils.animateBackgroundBack(backgroundView, null);
            }
        }, 50);
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int i = item.getItemId();
        if (i == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }


    public static class PictureFragment extends Fragment {

        private PhotoView imageView;
        private boolean uiIsHidden = true;
        private AvatarView ownerAvatarView;
        private TextView ownerNameView;
        private View ownerContainer;
        private Toolbar toolbar;
        private boolean firstShowing = true;
        private PhotoViewAttacher attacher;
        private String path;
        private long fileId;
        private long accessHash;
        private int fileSize;
        private String fileName;
        private CircularView circularView;
        private View backgroundView;
        private MenuItem saveMenuItem;

        public PictureFragment() {
        }

        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setHasOptionsMenu(true);
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_media_picture, container, false);

            final Bundle bundle = getArguments();
            path = bundle.getString(ARG_FILE_PATH);
            fileId = bundle.getLong(ARG_FILE_ID);
            accessHash = bundle.getLong(ARG_FILE_ACCESS_HASH);
            fileSize = bundle.getInt(ARG_FILE_SIZE);
            fileName = bundle.getString(ARG_FILE_NAME);
            int sender = bundle.getInt(ARG_OWNER, 0);
            circularView = (CircularView) rootView.findViewById(R.id.progress);
            circularView.setValue(50);
            circularView.setVisibility(View.GONE);
            imageView = (PhotoView) rootView.findViewById(R.id.image);

            Bitmap bitmap = null;
            try {
                bitmap = ImageLoading.loadBitmapOptimized(path);
                imageView.setImageBitmap(bitmap);
            } catch (ImageLoadException e) {

            }

            if (bitmap != null)
                bitmap = null;

            attacher = new PhotoViewAttacher(imageView);
            attacher.setOnClickListener(view -> {
                if (!uiIsHidden) {
                    hideSystemUi();
                } else {
                    showSystemUi();
                }
            });


            ownerAvatarView = (AvatarView) rootView.findViewById(R.id.avatar);
            ownerNameView = (TextView) rootView.findViewById(R.id.name);
            ownerContainer = rootView.findViewById(R.id.ownerContainer);

            if (Build.VERSION.SDK_INT >= 19) {
                ownerContainer.setPadding(0, 0, 0, Screen.getNavbarHeight());
            }

            UserVM owner = users().get(sender);

            ownerAvatarView.init(Screen.dp(48), 18);
            ownerAvatarView.bind(owner);
            ownerNameView.setText(owner.getName().get());

            backgroundView = null;


            backgroundView = rootView.findViewById(R.id.background);
            if (backgroundView != null)
                backgroundView.setOnClickListener(v -> {
                    if (!uiIsHidden) {
                        hideSystemUi();
                    } else {
                        showSystemUi();
                    }
                });

            ownerContainer.setVisibility(View.GONE);

            return rootView;
        }

        @Override
        public void onDestroyView() {
            super.onDestroyView();
        }

        @Override
        public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
            inflater.inflate(R.menu.media_picture, menu);
            saveMenuItem = menu.findItem(R.id.save);
        }

        @Override
        public boolean onOptionsItemSelected(MenuItem item) {
            if (item.getItemId() == R.id.share) {
                startActivity(Intents.shareDoc("picture.jpeg", path, getContext()));
            /*startActivity(new Intent(Intent.ACTION_SEND)
                    .setType("image/jpeg")
                    .putExtra(Intent.EXTRA_STREAM,Uri.parse(path)));*/
                return true;
            } else if (item.getItemId() == R.id.save) {
                savePicture();
                return true;
            }
            return super.onOptionsItemSelected(item);
        }

        private void savePicture() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, PERMISSION_REQ_MEDIA);
                    Log.d("Permissions", "savePhoto - no permission :c");
                    return;
                }
            }

            File externalFile = Environment.getExternalStorageDirectory();
            if (externalFile == null) {
                Toast.makeText(getActivity(), R.string.toast_no_sdcard, Toast.LENGTH_LONG).show();
            } else {
                boolean isGif = path.endsWith(".gif");
                String externalPath = externalFile.getAbsolutePath();
                String exportPathBase = externalPath + "/" + ActorSDK.sharedActor().getAppName() + "/" + ActorSDK.sharedActor().getAppName() + " images" + "/";
                new File(exportPathBase).mkdirs();
                try {
                    String exportPath = exportPathBase + (fileName != null ? fileName : "exported") + "_" + Randoms.randomId() + (isGif ? ".gif" : ".jpg");
                    Files.copy(new File(this.path), new File(exportPath));
                    MediaScannerConnection.scanFile(getActivity(), new String[]{exportPath}, new String[]{"image/" + (isGif ? "gif" : "jpeg")}, null);
                    Toast.makeText(getActivity(), getString(R.string.file_saved) + " " + exportPath, Toast.LENGTH_LONG).show();
                    saveMenuItem.setEnabled(false);
                    saveMenuItem.setTitle(R.string.menu_saved);
                } catch (IOException e) {
                    Log.e(TAG, e);
                }
            }
        }

        @Override
        public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
            if (requestCode == PERMISSION_REQ_MEDIA) {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    savePicture();
                }
            }
        }

        private void showSystemUi() {
            toolbar.setVisibility(View.VISIBLE);
            ownerContainer.setVisibility(View.VISIBLE);

            uiIsHidden = false;
            syncUiState();
        }

        private void hideSystemUi() {
            uiIsHidden = true;
            syncUiState();
        }

        @Override
        public void onAttach(Activity activity) {
            super.onAttach(activity);
            if (activity instanceof PictureActivity) {
                toolbar = ((PictureActivity) activity).toolbar;
            } else {
//                if (activity instanceof MediaActivity) {
//                    toolbar = ((MediaActivity) activity).toolbar;
//                }
            }
        }

        private void syncUiState() {

            toolbar.clearAnimation();
            ownerContainer.clearAnimation();
            if (uiIsHidden) {

                toolbar.animate()
                        .setInterpolator(new MaterialInterpolator())
                        .y(-toolbar.getHeight())
                        .alpha(0)
                        .setStartDelay(0)
                        .setDuration(300 * animationMultiplier)
                        .start();

                ownerContainer.animate()
                        .setInterpolator(new MaterialInterpolator())
                        .alpha(0)
                        .setStartDelay(0)
                        .setDuration(300 * animationMultiplier)
                        .start();
            } else {
                if (firstShowing) {
                    firstShowing = false;
                    // костыль
                    toolbar.setAlpha(0);
                    toolbar.setTop(-toolbar.getHeight());
                    ownerContainer.setAlpha(0);
                    toolbar.post(new Runnable() {
                        @Override
                        public void run() {
                            toolbar.animate()
                                    .setInterpolator(new MaterialInterpolator())
                                    .y(0)
                                    .alpha(1)
                                    .setStartDelay(50)
                                    .setDuration(450 * animationMultiplier)
                                    .start();
                            ownerContainer.animate()
                                    .setInterpolator(new MaterialInterpolator())
                                    .alpha(1)
                                    .setStartDelay(50)
                                    .setDuration(450 * animationMultiplier)
                                    .start();
                        }
                    });
                    return;
                }
                toolbar.animate()
                        .setInterpolator(new MaterialInterpolator())
                        .y(0)
                        .alpha(1)
                        .setStartDelay(120)
                        .setDuration(420 * animationMultiplier)
                        .start();
                ownerContainer.animate()
                        .setInterpolator(new MaterialInterpolator())
                        .alpha(1)
                        .setStartDelay(120)
                        .setDuration(420 * animationMultiplier)
                        .start();
            }

        }

        public static Fragment getInstance(String path, int senderId) {

            Bundle bundle = new Bundle();
            bundle.putString(ARG_FILE_PATH, path);
            bundle.putInt(ARG_OWNER, senderId);
            Fragment fragment = new PictureFragment();
            fragment.setArguments(bundle);
            return fragment;
        }

        public static Fragment getInstance(long fileId, int senderId) {
            Bundle bundle = new Bundle();
            bundle.putLong(ARG_FILE_ID, fileId);
            bundle.putInt(ARG_OWNER, senderId);
            Fragment fragment = new PictureFragment();
            fragment.setArguments(bundle);
            return fragment;
        }

        public static Fragment getInstance(FileReference ref, int senderId) {
            Bundle bundle = new Bundle();
            bundle.putLong(ARG_FILE_ID, ref.getFileId());
            bundle.putInt(ARG_FILE_SIZE, ref.getFileSize());
            bundle.putLong(ARG_FILE_ACCESS_HASH, ref.getAccessHash());
            bundle.putString(ARG_FILE_NAME, ref.getFileName());
            bundle.putInt(ARG_OWNER, senderId);
            Fragment fragment = new PictureFragment();
            fragment.setArguments(bundle);
            return fragment;
        }
    }
}