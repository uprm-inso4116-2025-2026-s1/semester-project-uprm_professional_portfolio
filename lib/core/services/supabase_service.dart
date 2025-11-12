import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    // Skip initialization if credentials are not provided (optional for now)
    if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
      print(
          '⚠️  Supabase credentials not found in .env - running without Supabase');
      return;
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
          'Supabase not initialized. Add credentials to .env file.');
    }
    return Supabase.instance.client;
  }
}
