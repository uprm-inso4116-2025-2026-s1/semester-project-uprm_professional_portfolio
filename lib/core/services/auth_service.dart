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

  static const String _resetRedirectUri = 'uprm-portfolio://reset-password';

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

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      // First try with deep link (best UX if redirect is whitelisted in Supabase)
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: _resetRedirectUri, // e.g., uprm-portfolio://reset-password
      );
      return AuthResult(success: true);
    } on AuthException catch (e) {
      // Fallback: if redirectTo isn’t verified/allowed yet, retry without it
      final msg = e.message.toLowerCase();
      final looksLikeRedirectBlocked = msg.contains('redirect') &&
          (msg.contains('verify') || msg.contains('verified'));

      if (looksLikeRedirectBlocked) {
        try {
          await _supabase.auth.resetPasswordForEmail(email);
          return AuthResult(success: true);
        } on AuthException catch (e2) {
          return AuthResult(success: false, error: e2.message);
        }
      }

      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(success: false, error: 'Unexpected error: $e');
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

  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return AuthResult(success: true);
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(success: false, error: 'Unexpected error: $e');
    }
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

  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Emits true when Supabase signals password recovery via deep link
  Stream<bool> get onPasswordRecovery => _supabase.auth.onAuthStateChange.map(
        (s) => s.event == AuthChangeEvent.passwordRecovery,
      );
}
