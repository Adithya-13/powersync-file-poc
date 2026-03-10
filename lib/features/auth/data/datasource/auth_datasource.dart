import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';

class AuthDatasource {
  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  Future<User> ensureSignedIn() async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser != null) return client.auth.currentUser!;
    final response = await client.auth.signInAnonymously();
    return response.user!;
  }

  User? get currentUser => Supabase.instance.client.auth.currentUser;
}
