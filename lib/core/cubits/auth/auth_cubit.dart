import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uprm_professional_portfolio/models/user.dart';
import 'auth_state.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final StorageService _storageService;
  final AuthService _authService;

  AuthCubit(this._storageService, this._authService) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _storageService.getUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _storageService.verifyCredentials(email, password);

      if (user != null) {
        await _storageService.saveUser(user);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(
      String email, String password, String name, String role) async {
    emit(AuthLoading());
    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        fullName: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await _storageService.saveCredentials(email, password, user);
      await _storageService.saveUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // OAuth Sign In Method
  Future<void> signInWithOAuth({
    required String provider,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      final result = await _authService.signInWithOAuth(
        provider: provider,
        role: role,
      );

      if (result.success) {
        // OAuth successful - wait a moment for Supabase to process
        await Future.delayed(Duration(seconds: 2));
        
        // Check if we have a user from Supabase
        final user = _authService.currentUser;
        if (user != null) {
          // Save to local storage for consistency
          await _storageService.saveUser(user);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('OAuth authentication completed but no user data received'));
        }
      } else {
        emit(AuthError(result.error ?? 'OAuth authentication failed'));
      }
    } catch (e) {
      emit(AuthError('OAuth sign in failed: ${e.toString()}'));
    }
  }

  // Link account with OAuth
  Future<void> linkAccountWithOAuth(String provider) async {
    emit(AuthLoading());
    try {
      final result = await _authService.linkAccountWithOAuth(provider);

      if (result.success) {
        // Refresh user data after linking
        final user = _authService.currentUser;
        if (user != null) {
          await _storageService.saveUser(user);
          emit(AuthAuthenticated(user));
        }
      } else {
        emit(AuthError(result.error ?? 'Account linking failed'));
      }
    } catch (e) {
      emit(AuthError('Account linking failed: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _storageService.clearUser();
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _storageService.saveUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Get current user
  User? get currentUser {
    final state = this.state;
    if (state is AuthAuthenticated) {
      return state.user;
    }
    return null;
  }
}