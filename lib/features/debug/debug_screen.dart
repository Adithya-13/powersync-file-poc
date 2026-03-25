import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync_core/attachments/attachments.dart';

import '../../core/attachments/attachments_providers.dart';
import '../../core/database/powersync.dart';
import '../todos/presentation/providers/todos_providers.dart';

final _localStorageSizeProvider = StreamProvider<int>((ref) {
  final db = ref.watch(powerSyncDbProvider);
  return db
      .watch('''
    SELECT id FROM ${AttachmentsQueueTable.defaultTableName}
  ''')
      .asyncMap((_) async {
        var totalBytes = 0;
        final dir = attachmentsDirectory;
        if (!dir.existsSync()) return 0;
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            totalBytes += await entity.length();
          }
        }
        return totalBytes;
      });
});

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _stateName(AttachmentState state) {
    switch (state) {
      case AttachmentState.queuedUpload:
        return 'QUEUED_UPLOAD';
      case AttachmentState.queuedDownload:
        return 'QUEUED_DOWNLOAD';
      case AttachmentState.queuedDelete:
        return 'QUEUED_DELETE';
      case AttachmentState.synced:
        return 'SYNCED';
      case AttachmentState.archived:
        return 'ARCHIVED';
    }
  }

  Color _stateColor(AttachmentState state) {
    switch (state) {
      case AttachmentState.queuedUpload:
      case AttachmentState.queuedDownload:
        return Colors.orange;
      case AttachmentState.queuedDelete:
        return Colors.red;
      case AttachmentState.synced:
        return Colors.green;
      case AttachmentState.archived:
        return Colors.grey;
    }
  }

  Future<void> _runExpireCache(BuildContext context, WidgetRef ref) async {
    final queue = ref.read(attachmentQueueProvider);
    developer.log('[DebugScreen] Running expireCache()...', name: 'attachments');
    try {
      await queue.expireCache();
      developer.log('[DebugScreen] expireCache() completed', name: 'attachments');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('expireCache() completed — check logs')),
        );
      }
    } catch (e, st) {
      developer.log(
        '[DebugScreen] expireCache() error: $e',
        name: 'attachments',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('expireCache() error: $e')),
        );
      }
    }
  }

  // verifyAttachments() is private in AttachmentQueue. Triggering it by
  // restarting sync (stopSyncing + startSync), which calls _verifyAttachments
  // internally as part of the startup sequence.
  Future<void> _runVerifyAttachments(BuildContext context, WidgetRef ref) async {
    final queue = ref.read(attachmentQueueProvider);
    developer.log(
      '[DebugScreen] Running verifyAttachments() via sync restart...',
      name: 'attachments',
    );
    try {
      await queue.stopSyncing();
      await queue.startSync();
      developer.log(
        '[DebugScreen] verifyAttachments() completed (sync restarted)',
        name: 'attachments',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('verifyAttachments() completed — check logs'),
          ),
        );
      }
    } catch (e, st) {
      developer.log(
        '[DebugScreen] verifyAttachments() error: $e',
        name: 'attachments',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('verifyAttachments() error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(attachmentsProvider);
    final storageAsync = ref.watch(_localStorageSizeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attachment Debug')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache Info',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    storageAsync.when(
                      loading: () => const Text('Calculating storage...'),
                      error: (e, _) => Text('Storage error: $e'),
                      data: (bytes) => Text('Local storage: ${_formatBytes(bytes)}'),
                    ),
                    attachmentsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (map) => Text('Total records: ${map.length}'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _runExpireCache(context, ref),
                    child: const Text('expireCache()'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _runVerifyAttachments(context, ref),
                    child: const Text('verifyAttachments()'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: attachmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (attachmentsById) {
                final attachments = attachmentsById.values.toList();
                if (attachments.isEmpty) {
                  return const Center(child: Text('No attachment records'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    final a = attachments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 6,
                          backgroundColor: _stateColor(a.state),
                        ),
                        title: Text(
                          a.filename,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${a.id}'),
                            if (a.localUri != null)
                              Text(
                                'URI: ${a.localUri}',
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            _stateName(a.state),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _stateColor(a.state).withValues(alpha: 0.15),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                        isThreeLine: a.localUri != null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
