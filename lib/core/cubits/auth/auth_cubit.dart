import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uprm_professional_portfolio/models/user.dart';
import 'auth_state.dart';
import '../../services/storage_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final StorageService _storageService;

  AuthCubit(this._storageService) : super(AuthInitial()) {
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
      // Verify credentials from storage
      final user = await _storageService.verifyCredentials(email, password);

      if (user != null) {
        // Save as current user
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
      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        fullName: name,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save credentials for future logins
      await _storageService.saveCredentials(email, password, user);

      // Save as current user
      await _storageService.saveUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // Only clear current session, keep credentials for re-login
      await _storageService.clearUser();
      // Don't clear profiles - they'll be loaded on next login
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
