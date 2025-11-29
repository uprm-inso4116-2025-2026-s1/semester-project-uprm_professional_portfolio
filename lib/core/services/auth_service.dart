import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../models/user.dart' as app_models;
import '../constants/app_constants.dart';

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}

class AuthService {
  final supa.SupabaseClient _supabase = supa.Supabase.instance.client;

  app_models.User? _currentUserCache;

  /// App-level current user
  app_models.User? get currentUser {
    final supa.User? user = _supabase.auth.currentUser;
    if (user == null) {
      return _currentUserCache;
    }
    return _fromSupabaseUser(user);
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final supa.AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        _currentUserCache = _fromSupabaseUser(response.user!);
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: 'Signup failed. Please try again.',
        );
      }
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final supa.AuthResponse response =
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUserCache = _fromSupabaseUser(response.user!);
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: 'Login failed. Please try again.',
        );
      }
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
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
      supa.OAuthProvider oauthProvider;

      switch (provider.toLowerCase()) {
        case 'google':
          oauthProvider = supa.OAuthProvider.google;
          break;
        case 'linkedin':
          oauthProvider = supa.OAuthProvider.linkedin;
          break;
        default:
          return AuthResult(
            success: false,
            error: 'Unsupported OAuth provider',
          );
      }

      await _supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: kIsWeb ? null : 'your-app-scheme://login-callback',
      );

      return AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'OAuth sign in failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> linkAccountWithOAuth(String provider) async {
    // Not implemented right now
    return AuthResult(
      success: false,
      error: 'Account linking is not currently supported',
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUserCache = null;
  }

  Future<bool> checkAuthStatus() async {
    final supa.Session? session = _supabase.auth.currentSession;
    if (session?.user != null) {
      _currentUserCache = _fromSupabaseUser(session!.user);
      return true;
    }
    _currentUserCache = null;
    return false;
  }

  /// Map Supabase user → our app user model
  app_models.User _fromSupabaseUser(supa.User sUser) {
    final meta = sUser.userMetadata ?? const <String, dynamic>{};

    final createdAtStr = sUser.createdAt;
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    return app_models.User(
      id: sUser.id,
      email: sUser.email ?? '',
      fullName: (meta['full_name'] as String?) ?? 'User',
      role: (meta['role'] as String?) ?? AppConstants.jobseekerRole,
      createdAt: createdAt,
      avatarUrl: meta['avatar_url'] as String?,
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

  /// Update avatar_url in Supabase user metadata and refresh cache
  Future<AuthResult> updateAvatarUrl(String avatarUrl) async {
    try {
      final supa.User? user = _supabase.auth.currentUser;
      if (user == null) {
        return AuthResult(success: false, error: 'Not logged in');
      }

      final newMeta = Map<String, dynamic>.from(user.userMetadata ?? {});
      newMeta['avatar_url'] = avatarUrl;

      final res = await _supabase.auth.updateUser(
        supa.UserAttributes(data: newMeta),
      );

      if (res.user != null) {
        _currentUserCache = _fromSupabaseUser(res.user!);
      }

      return AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to update avatar: ${e.toString()}',
      );
    }
  }

  /// Stream of Supabase auth state changes (not the Cubit state)
  Stream<supa.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
