import 'package:flutter/foundation.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/powersync_core.dart';

class AppAttachmentErrorHandler implements AttachmentErrorHandler {
  final PowerSyncDatabase db;

  const AppAttachmentErrorHandler({required this.db});

  @override
  Future<bool> onUploadError(
    Attachment attachment,
    Object error,
    StackTrace stackTrace,
  ) async {
    final message = 'Upload failed: ${attachment.filename} — $error';
    db.logger.info(message);
    debugPrint(message);
    return true; // always retry uploads
  }

  @override
  Future<bool> onDownloadError(
    Attachment attachment,
    Object error,
    StackTrace stackTrace,
  ) async {
    final message = 'Download failed: ${attachment.filename} — $error';
    db.logger.info(message);
    debugPrint(message);

    // Skip retry on 404 (file not found on remote)
    if (error.toString().contains('404')) {
      return false;
    }

    return true; // retry other download errors
  }

  @override
  Future<bool> onDeleteError(
    Attachment attachment,
    Object error,
    StackTrace stackTrace,
  ) async {
    final message = 'Delete failed: ${attachment.filename} — $error';
    db.logger.info(message);
    debugPrint(message);
    return true; // always retry deletes
  }
}
