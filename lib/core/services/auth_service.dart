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

  app_models.User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    return app_models.User(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] ?? 'User',
      role: user.userMetadata?['role'] ?? AppConstants.jobseekerRole,
      createdAt: DateTime.now(),
    );
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Existing email/password signup
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
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../models/user.dart' as model;
import '../constants/app_constants.dart';

/// Supabase-backed AuthService that preserves the existing public API.
class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final supa.SupabaseClient _sb = supa.Supabase.instance.client;

  model.User? _currentUser;

  // Current user getter (unchanged)
  model.User? get currentUser => _currentUser;

  // Check if user is logged in (unchanged)
  bool get isLoggedIn => _sb.auth.currentSession != null;

  // ----------------------------
  // Login (Supabase)
  // ----------------------------
  Future<AuthResult> login(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
      final res = await _sb.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
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

  // OAuth Sign In - UPDATED with correct method signature
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
          return AuthResult(success: false, error: 'Unsupported OAuth provider');
      }

      await _supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: kIsWeb ? null : 'your-app-scheme://login-callback',
      final sUser = res.user;
      if (sUser == null) {
        return AuthResult(success: false, error: 'Login failed. No active session.');
      }

      _currentUser = _fromSupabaseUser(sUser);
      return AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } on Exception catch (_) {
      return AuthResult(success: false, error: 'Unexpected error during sign in. Please try again.');
    }
  }

  // ----------------------------
  // Sign up (Supabase)
  // ----------------------------
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final res = await _sb.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      // If email confirmation is ON, session may be null—this is fine.
      final sUser = res.user;
      if (sUser == null) {
        return AuthResult(success: false, error: 'Sign up failed. No user returned.');
      }

      _currentUser = _fromSupabaseUser(sUser);
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

  // Link existing account with OAuth provider - REMOVED for now
  // The linkWithOAuth method doesn't exist in current Supabase version
  Future<AuthResult> linkAccountWithOAuth(String provider) async {
    // This feature is not available in current Supabase Flutter SDK
    return AuthResult(
      success: false,
      error: 'Account linking is not currently supported',
    );
  }

  // Alternative: Update user data instead
  Future<AuthResult> updateUserData(Map<String, dynamic> data) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );

      if (response.user != null) {
        return AuthResult(success: true);
      } else {
        return AuthResult(
          success: false,
          error: 'Failed to update user data',
        );
      }
    } on AuthException catch (e) {
      return AuthResult(success: false, error: e.message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to update user data: ${e.toString()}',
      );
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } on Exception catch (_) {
      return AuthResult(success: false, error: 'Unexpected error during sign up. Please try again.');
    }
  }

  // ----------------------------
  // Logout (Supabase)
  // ----------------------------
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _sb.auth.signOut();
    _currentUser = null;
  }

  // ----------------------------
  // Check authentication status (unchanged signature)
  // Now uses Supabase's currentSession; hydrates _currentUser if needed.
  // ----------------------------
  Future<bool> checkAuthStatus() async {
    final session = _supabase.auth.currentSession;
    return session != null;
    final session = _sb.auth.currentSession;
    if (session?.user != null) {
      _currentUser ??= _fromSupabaseUser(session!.user);
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
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
// Auth result class
class AuthResult {
  AuthResult({required this.success, this.error});
  final bool success;
  final String? error;
}
