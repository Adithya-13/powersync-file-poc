import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/attachments/io.dart';

import '../database/powersync.dart';
import 'attachments_providers.dart';

final attachmentQueueProvider = FutureProvider<AttachmentQueue>((ref) async {
  final db = ref.watch(powerSyncDbProvider);
  final remoteStorage = ref.watch(supabaseStorageAdapterProvider);
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  final localStorage = IOLocalStorage(
    Directory(path.join(appDocumentsDir.path, 'attachments')),
  );

  final queue = AttachmentQueue(
    db: db,
    remoteStorage: remoteStorage,
    watchAttachments: () => db
        .watch('SELECT photo_id FROM todos WHERE photo_id IS NOT NULL')
        .map(
          (results) => [
            for (final row in results)
              WatchedAttachmentItem(
                id: row['photo_id'] as String,
                fileExtension: 'jpg',
              ),
          ],
        ),
    localStorage: localStorage,
    attachmentsQueueTableName: 'attachments',
    syncInterval: const Duration(seconds: 30),
    downloadAttachments: true,
    archivedCacheLimit: 50,
  );

  ref.onDispose(() {
    queue.close();
  });

  return queue;
});
