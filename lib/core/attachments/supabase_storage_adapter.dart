import 'dart:typed_data';

import 'package:powersync_core/attachments/attachments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageAdapter implements RemoteStorage {
  static const _bucket = 'attachments';

  SupabaseClient get _client => Supabase.instance.client;

  String _attachmentPath(Attachment attachment) {
    return attachment.filename;
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

  Future<Uint8List> _collectBytes(Stream<Uint8List> chunks) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in chunks) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }
}
