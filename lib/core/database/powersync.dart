import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync_core/powersync_core.dart';

import 'connector.dart';
import 'schema.dart';

late final PowerSyncDatabase db;
late final Directory attachmentsDirectory;

Future<void> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'powersync.db');

  attachmentsDirectory = Directory(join(dir.path, 'attachments'));
  db = PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();
}

Future<void> connectDatabase() async {
  await db.connect(connector: AppPowerSyncConnector());
}

final powerSyncDbProvider = Provider<PowerSyncDatabase>((ref) => db);
