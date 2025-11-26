import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/user.dart' as app_models;
import '../constants/app_constants.dart';

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  app_models.User? _currentUser;

  app_models.User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return _currentUser;

    return app_models.User(
      id: user.id,
      email: user.email!,
      fullName: (user.userMetadata?['full_name'] as String?) ?? 'User',
      role:
          (user.userMetadata?['role'] as String?) ?? AppConstants.jobseekerRole,
      createdAt: DateTime.now(),
    );
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        _currentUser = app_models.User(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: 'Signup failed. Please try again.',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = response.user!;
        _currentUser = app_models.User(
          id: user.id,
          email: user.email!,
          fullName: (user.userMetadata?['full_name'] as String?) ?? 'User',
          role: (user.userMetadata?['role'] as String?) ??
              AppConstants.jobseekerRole,
          createdAt: DateTime.now(),
        );
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: 'Login failed. Please try again.',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signInWithOAuth({
    required String provider,
    String? role,
  }) async {
    try {
      OAuthProvider oauthProvider;

      switch (provider.toLowerCase()) {
        case 'google':
          oauthProvider = OAuthProvider.google;
          break;
        case 'linkedin':
          oauthProvider = OAuthProvider.linkedin;
          break;
        default:
          return AuthResult(
              success: false, error: 'Unsupported OAuth provider');
      }

      await _supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: kIsWeb ? null : 'your-app-scheme://login-callback',
      );

      return AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'OAuth sign in failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> linkAccountWithOAuth(String provider) async {
    return AuthResult(
      success: false,
      error: 'Account linking is not currently supported',
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  Future<bool> checkAuthStatus() async {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      final user = session!.user;
      _currentUser = app_models.User(
        id: user.id,
        email: user.email!,
        fullName: (user.userMetadata?['full_name'] as String?) ?? 'User',
        role: (user.userMetadata?['role'] as String?) ??
            AppConstants.jobseekerRole,
        createdAt: DateTime.now(),
      );
      return true;
    }
    _currentUser = null;
    return false;
  }

  // ----------------------------
  // Helpers
  // ----------------------------
  model.User _fromSupabaseUser(supa.User sUser) {
    final meta = sUser.userMetadata ?? const <String, dynamic>{};

    // Supabase's createdAt is String (ISO-8601). Convert to DateTime safely.
    final createdAtStr = sUser.createdAt;
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    return model.User(
      id: sUser.id,
      email: sUser.email ?? '',
      fullName: (meta['full_name'] as String?) ?? '',
      role: (meta['role'] as String?) ?? AppConstants.jobseekerRole,
      createdAt: createdAt,
    );
  }

  String _friendlyAuthMessage(supa.AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') ||
        msg.contains('invalid email') ||
        msg.contains('invalid credentials') ||
        msg.contains('email or password is invalid')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('user already registered') || msg.contains('duplicate')) {
      return 'This email is already registered.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email to continue.';
    }
    return e.message;
  }

  // Get auth state changes stream
  Stream<supa.AuthState> get authStateChanges => _sb.auth.onAuthStateChange;
}

// Auth result class
class AuthResult {
  AuthResult({required this.success, this.error});
  final bool success;
  final String? error;
}
