import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

// Signup controller for handling signup logic
class SignupController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
