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
      // Check Supabase auth status first
      final isAuthenticated = await _authService.checkAuthStatus();

      if (isAuthenticated) {
        final user = _authService.currentUser;
        if (user != null) {
          // Update local storage with Supabase user
          await _storageService.saveUser(user);
          emit(AuthAuthenticated(user));
          return;
        }
      }

      // Fallback to local storage if Supabase not available
      final localUser = await _storageService.getUser();
      if (localUser != null) {
        emit(AuthAuthenticated(localUser));
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
      print('[AuthCubit] Starting login for: $email');

      // Call Supabase AuthService
      final result = await _authService.login(email, password);

      if (!result.success) {
        print('[AuthCubit] Login failed: ${result.error}');
        emit(AuthError(result.error ?? 'Login failed'));
        return;
      }

      print('[AuthCubit] Login successful, checking for user');

      // Get the current user from AuthService
      final user = _authService.currentUser;
      if (user != null) {
        print(
            '[AuthCubit] User found, saving and emitting authenticated state');
        await _storageService.saveUser(user);
        emit(AuthAuthenticated(user));
      } else {
        print('[AuthCubit] No user found after login');
        emit(AuthError('Login succeeded but no user data available'));
      }
    } catch (e) {
      print('[AuthCubit] Login exception: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(
      String email, String password, String name, String role) async {
    emit(AuthLoading());
    try {
      print('[AuthCubit] Starting signup for: $email');

      // Call Supabase AuthService
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: name,
        role: role,
      );

      if (result.success) {
        // Get the user from Supabase
        final user = _authService.currentUser;
        if (user != null) {
          // Save to local storage for offline access
          await _storageService.saveUser(user);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Sign up successful but user data not available'));
        }
      } else {
        emit(AuthError(result.error ?? 'Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

      print('[AuthCubit] Signup successful, checking for user');

      if (result.success) {
        // OAuth successful - wait a moment for Supabase to process
        await Future<void>.delayed(const Duration(seconds: 2));

        // Check if we have a user from Supabase
        final user = _authService.currentUser;
        if (user != null) {
          // Save to local storage for consistency
          await _storageService.saveUser(user);
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError(
              'OAuth authentication completed but no user data received'));
        }
      } else {
        print('[AuthCubit] No user found after signup');
        emit(AuthError('Sign up succeeded but no user data available'));
      }
    } catch (e) {
      print('[AuthCubit] Signup exception: $e');
      emit(AuthError(e.toString()));
    }
  }

  // OAuth Sign In Method - DISABLED (not implemented in AuthService)
  // Future<void> signInWithOAuth({
  //   required String provider,
  //   required String role,
  // }) async {
  //   emit(AuthLoading());
  //   try {
  //     final result = await _authService.signInWithOAuth(
  //       provider: provider,
  //       role: role,
  //     );
  //
  //     if (result.success) {
  //       // OAuth successful - wait a moment for Supabase to process
  //       await Future.delayed(Duration(seconds: 2));
  //
  //       // Check if we have a user from Supabase
  //       final user = _authService.currentUser;
  //       if (user != null) {
  //         // Save to local storage for consistency
  //         await _storageService.saveUser(user);
  //         emit(AuthAuthenticated(user));
  //       } else {
  //         emit(AuthError('OAuth authentication completed but no user data received'));
  //       }
  //     } else {
  //       emit(AuthError(result.error ?? 'OAuth authentication failed'));
  //     }
  //   } catch (e) {
  //     emit(AuthError('OAuth sign in failed: ${e.toString()}'));
  //   }
  // }

  // Link account with OAuth - DISABLED (not implemented in AuthService)
  // Future<void> linkAccountWithOAuth(String provider) async {
  //   emit(AuthLoading());
  //   try {
  //     final result = await _authService.linkAccountWithOAuth(provider);
  //
  //     if (result.success) {
  //       // Refresh user data after linking
  //       final user = _authService.currentUser;
  //       if (user != null) {
  //         await _storageService.saveUser(user);
  //         emit(AuthAuthenticated(user));
  //       }
  //     } else {
  //       emit(AuthError(result.error ?? 'Account linking failed'));
  //     }
  //   } catch (e) {
  //     emit(AuthError('Account linking failed: ${e.toString()}'));
  //   }
  // }

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
