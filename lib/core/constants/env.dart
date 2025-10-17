class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void assertProvided() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing --dart-define SUPABASE_URL or SUPABASE_ANON_KEY.',
      );
    }
  }
}
