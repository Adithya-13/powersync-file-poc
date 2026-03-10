import 'package:powersync_core/powersync_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AppPowerSyncConnector extends PowerSyncBackendConnector {
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    return PowerSyncCredentials(
      endpoint: AppConfig.powerSyncUrl,
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final batch = await database.getCrudBatch(limit: 100);
    if (batch == null) return;

    final client = Supabase.instance.client;

    for (final op in batch.crud) {
      final table = client.from(op.table);
      switch (op.op) {
        case UpdateType.put:
          await table.upsert({...op.opData!, 'id': op.id});
        case UpdateType.patch:
          await table.update(op.opData!).eq('id', op.id);
        case UpdateType.delete:
          await table.delete().eq('id', op.id);
      }
    }

    await batch.complete();
  }
}
