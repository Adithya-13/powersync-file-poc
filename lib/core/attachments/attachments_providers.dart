import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_storage_adapter.dart';

final supabaseStorageAdapterProvider = Provider<SupabaseStorageAdapter>(
  (_) => SupabaseStorageAdapter(),
);
