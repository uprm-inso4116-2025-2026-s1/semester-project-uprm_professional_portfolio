// lib/core/constants/env_prod.dart
class Env {
  // Use your real project values (publishable anon key ONLY)
  static const supabaseUrl = 'https://bhsppshnsklpqupmozhl.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoc3Bwc2huc2tscHF1cG1vemhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNzMxMDEsImV4cCI6MjA3MzY0OTEwMX0.C2SfBZjrCsuDBxTb5Ka51CoNyDNYurBW3HA-QMB4yAs'; // anon (public) key

  static void assertProvided() {
    // No-op in prod; values are compiled in.
  }
}
