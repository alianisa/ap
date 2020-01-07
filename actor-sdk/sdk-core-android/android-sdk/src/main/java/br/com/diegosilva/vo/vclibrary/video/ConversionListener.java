package br.com.diegosilva.vo.vclibrary.video;

import java.io.File;

/**
 * Created by diego on 20/05/17.
 */

public interface ConversionListener {

    void onError(Exception ex);

    void onProgress(float progress);

    void onSuccess(File compressedFile);

}
