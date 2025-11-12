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

  // Login method
  Future<AuthResult> login(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
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
    }
  }

  // Logout method
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}