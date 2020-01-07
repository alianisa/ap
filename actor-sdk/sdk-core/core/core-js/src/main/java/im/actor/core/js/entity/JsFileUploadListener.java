package im.actor.core.js.entity;

import org.timepedia.exporter.client.Export;
import org.timepedia.exporter.client.ExportClosure;
import org.timepedia.exporter.client.Exportable;

import im.actor.runtime.files.FileSystemReference;

@Export
@ExportClosure
public interface JsFileUploadListener extends Exportable {
    void onStatusUpdate(float progress, boolean isUploading);
}
