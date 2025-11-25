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
      final res = await _sb.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final sUser = res.user;
      if (sUser == null) {
        return AuthResult(
            success: false, error: 'Login failed. No active session.');
      }

      _currentUser = _fromSupabaseUser(sUser);
      return AuthResult(success: true);
    } on supa.AuthException catch (e) {
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } on Exception catch (_) {
      return AuthResult(
          success: false,
          error: 'Unexpected error during sign in. Please try again.');
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
      print('[AuthService] Attempting signup for: $email');
      final res = await _sb.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      print(
          '[AuthService] Signup response - User: ${res.user?.id}, Session: ${res.session?.accessToken != null}');

      final sUser = res.user;
      if (sUser == null) {
        print('[AuthService] ERROR: No user returned from signup');
        return AuthResult(
            success: false, error: 'Sign up failed. No user returned.');
      }

      print(
          '[AuthService] User created successfully - ID: ${sUser.id}, Email: ${sUser.email}');

      // Check if email confirmation is required
      if (res.session == null) {
        print('[AuthService] No session - email confirmation required');
        return AuthResult(
          success: false,
          error:
              'Please check your email to confirm your account before logging in.',
        );
      }

      _currentUser = _fromSupabaseUser(sUser);
      return AuthResult(success: true);
    } on supa.AuthException catch (e) {
      print('[AuthService] Signup AuthException: ${e.message}');
      return AuthResult(success: false, error: _friendlyAuthMessage(e));
    } on Exception catch (e) {
      print('[AuthService] Signup Exception: $e');
      return AuthResult(
          success: false,
          error: 'Unexpected error during sign up. Please try again.');
    }
  }

  // ----------------------------
  // Logout (Supabase)
  // ----------------------------
  Future<void> logout() async {
    await _sb.auth.signOut();
    _currentUser = null;
  }

  // ----------------------------
  // Check authentication status (unchanged signature)
  // Now uses Supabase's currentSession; hydrates _currentUser if needed.
  // ----------------------------
  Future<bool> checkAuthStatus() async {
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
  Stream<supa.AuthState> get authStateChanges => _sb.auth.onAuthStateChange;
}

// Auth result class
class AuthResult {
  AuthResult({required this.success, this.error});
  final bool success;
  final String? error;
}
