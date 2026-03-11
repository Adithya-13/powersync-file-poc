import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/attachments/attachments_providers.dart';
import '../../../../core/database/powersync.dart';
import '../../data/datasource/auth_datasource.dart';

final authDatasourceProvider = Provider<AuthDatasource>(
  (_) => AuthDatasource(),
);

final authInitProvider = FutureProvider<User>((ref) async {
  final datasource = ref.read(authDatasourceProvider);
  await datasource.initialize();
  await openDatabase();
  final user = await datasource.ensureSignedIn();
  await connectDatabase();
  await ref.read(attachmentQueueInitProvider.future);
  return user;
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authInitProvider).valueOrNull?.id;
});
