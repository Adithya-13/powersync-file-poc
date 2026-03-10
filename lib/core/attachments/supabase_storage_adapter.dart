import 'dart:io';
import 'dart:typed_data';

import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageAdapter implements AbstractRemoteStorageAdapter {
  static const _bucket = 'attachments';

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<void> uploadFile(
    String filePath,
    File file, {
    String mediaType = 'application/octet-stream',
  }) async {
    final path = '$_userId/$filePath';
    final bytes = await file.readAsBytes();
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mediaType),
        );
  }

  @override
  Future<Uint8List> downloadFile(String filePath) async {
    final path = '$_userId/$filePath';
    return _client.storage.from(_bucket).download(path);
  }

  @override
  Future<void> deleteFile(String filename) async {
    final path = '$_userId/$filename';
    await _client.storage.from(_bucket).remove([path]);
  }
}
