import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:powersync_core/attachments/attachments.dart';

import '../../../../core/database/powersync.dart';
import '../../domain/entity/todo.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final Attachment? attachment;
  final Future<void> Function(bool completed) onToggle;
  final Future<void> Function() onDelete;
  final Future<void> Function() onAttachPhoto;

  const TodoItemWidget({
    required this.todo,
    required this.attachment,
    required this.onToggle,
    required this.onDelete,
    required this.onAttachPhoto,
    super.key,
  });

  String? get _localPhotoPath {
    final localUri = attachment?.localUri;
    if (localUri == null) {
      return null;
    }
    return path.join(attachmentsDirectory.path, localUri);
  }

  @override
  Widget build(BuildContext context) {
    final localPhotoPath = _localPhotoPath;
    final isUploading = attachment?.state == AttachmentState.queuedUpload;
    final isSynced = attachment?.state == AttachmentState.synced;
    final isDownloading = attachment?.state == AttachmentState.queuedDownload;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: todo.completed,
                  onChanged: (value) => onToggle(value ?? false),
                ),
                Expanded(
                  child: Text(
                    todo.description,
                    style: TextStyle(
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onAttachPhoto,
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Attach photo',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete todo',
                ),
              ],
            ),
            if (localPhotoPath != null)
              Padding(
                padding: const EdgeInsets.only(left: 48, right: 8, bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(localPhotoPath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            if (isDownloading)
              const Padding(
                padding: EdgeInsets.only(left: 48, right: 8, bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Downloading photo...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (todo.photoId == null)
              const Padding(
                padding: EdgeInsets.only(left: 48, right: 8, bottom: 8),
                child: Opacity(
                  opacity: 0.5,
                  child: Icon(Icons.photo_size_select_large_outlined, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (todo.photoId != null)
                    const Chip(
                      label: Text('Photo linked'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (isUploading)
                    const Chip(
                      label: Text('Uploading'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (isSynced)
                    const Chip(
                      label: Text('Synced'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
