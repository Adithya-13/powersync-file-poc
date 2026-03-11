import 'dart:typed_data';

import 'package:powersync_core/attachments/attachments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageAdapter implements RemoteStorage {
  static const _bucket = 'attachments';

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  String _attachmentPath(Attachment attachment) {
    final userId = _userId;
    if (userId == null) {
      throw StateError('User must be signed in before syncing attachments.');
    }
    return '$userId/${attachment.filename}';
  }

  Future<Uint8List> _collectBytes(Stream<Uint8List> stream) async {
    final chunks = await stream.toList();
    final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final bytes = Uint8List(totalLength);

    var offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return bytes;
  }

  @override
  Future<void> uploadFile(
    Stream<Uint8List> fileData,
    Attachment attachment,
  ) async {
    final bytes = await _collectBytes(fileData);
    final path = _attachmentPath(attachment);
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: attachment.mediaType ?? 'application/octet-stream',
          ),
        );
  }

  @override
  Future<Stream<List<int>>> downloadFile(Attachment attachment) async {
    final path = _attachmentPath(attachment);
    final bytes = await _client.storage.from(_bucket).download(path);
    return Stream<List<int>>.value(bytes);
  }

  @override
  Future<void> deleteFile(Attachment attachment) async {
    final path = _attachmentPath(attachment);
    await _client.storage.from(_bucket).remove([path]);
  }
}
