import 'package:flutter/foundation.dart';

/// Global, in-memory state (no backend).
class AppState {
  /// 'student' | 'recruiter' | null
  static final ValueNotifier<String?> role = ValueNotifier<String?>(null);
}
