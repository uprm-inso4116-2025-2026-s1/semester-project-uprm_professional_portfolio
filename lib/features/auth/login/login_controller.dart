import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

// Login controller for handling login logic
class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.login(email, password);
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
