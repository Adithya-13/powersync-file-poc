import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/attachments/io.dart';
import 'package:powersync_core/powersync_core.dart';

import '../database/powersync.dart';
import 'attachment_error_handler.dart';
import 'supabase_storage_adapter.dart';

final supabaseStorageAdapterProvider = Provider<SupabaseStorageAdapter>(
  (_) => SupabaseStorageAdapter(),
);

final attachmentErrorHandlerProvider = Provider<AppAttachmentErrorHandler>((ref) {
  final db = ref.watch(powerSyncDbProvider);
  return AppAttachmentErrorHandler(db: db);
});

StreamSubscription<void>? _attachmentStateSubscription;
final Map<String, AttachmentState> _lastAttachmentStates = {};

final attachmentQueueProvider = Provider<AttachmentQueue>((ref) {
  final db = ref.watch(powerSyncDbProvider);
  final remoteStorage = ref.watch(supabaseStorageAdapterProvider);
  final errorHandler = ref.watch(attachmentErrorHandlerProvider);

  return AttachmentQueue(
    db: db,
    remoteStorage: remoteStorage,
    errorHandler: errorHandler,
    localStorage: IOLocalStorage(attachmentsDirectory),
    watchAttachments: () => db
        .watch('SELECT photo_id as id FROM todos WHERE photo_id IS NOT NULL')
        .map(
          (results) => [
            for (final row in results)
              WatchedAttachmentItem(
                id: row['id'] as String,
                fileExtension: 'jpg',
              ),
          ],
        ),
    syncInterval: const Duration(seconds: 30),
    archivedCacheLimit: 50,
    downloadAttachments: true,
  );
});

final attachmentQueueInitProvider = FutureProvider<void>((ref) async {
  final db = ref.read(powerSyncDbProvider);
  final queue = ref.read(attachmentQueueProvider);

  await queue.startSync();
  await _startAttachmentStateLogging(db);
});

Future<void> _startAttachmentStateLogging(PowerSyncDatabase db) async {
  if (_attachmentStateSubscription != null) {
    return;
  }

  _attachmentStateSubscription = db
      .watch('''
        SELECT id, state
        FROM ${AttachmentsQueueTable.defaultTableName}
      ''')
      .listen((results) {
        final nextStates = <String, AttachmentState>{};

        for (final row in results) {
          final id = row['id'] as String;
          final state = AttachmentState.fromInt(row['state'] as int);
          final previousState = _lastAttachmentStates[id];

          if (previousState == AttachmentState.queuedUpload &&
              state == AttachmentState.synced) {
            final message = 'Attachment $id transition QUEUED_UPLOAD -> SYNCED';
            db.logger.info(message);
            debugPrint(message);
          }

          nextStates[id] = state;
        }

        _lastAttachmentStates
          ..clear()
          ..addAll(nextStates);
      });
}
