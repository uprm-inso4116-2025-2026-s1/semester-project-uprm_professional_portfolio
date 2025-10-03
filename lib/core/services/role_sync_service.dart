import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../state/app_state.dart';
import 'supabase_service.dart';

class RoleSyncService {
  static const _deviceKey = 'role_device_id';

  /// Set the role locally (updates the badge immediately) and
  /// try to upsert it to Supabase (best effort).
  static Future<void> setRole(String role) async {
    // 1) Local: show the badge
    AppState.role.value = role;

    // 2) Remote: best-effort save (skip if not initialized)
    try {
      final client = SupabaseService.client; // throws if not initialized
      final id = await _deviceId();
      await client.from('role_selections').upsert(
        {
          'id': id,
          'role': role,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } catch (_) {
      // swallow errors — we don't want to break the UI for missing config
    }
  }

  static Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceKey);
    if (id != null) return id;
    id = _randomId();
    await prefs.setString(_deviceKey, id);
    return id;
  }

  static String _randomId() {
    const chars = 'abcdef0123456789';
    final r = Random.secure();
    return List.generate(32, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
