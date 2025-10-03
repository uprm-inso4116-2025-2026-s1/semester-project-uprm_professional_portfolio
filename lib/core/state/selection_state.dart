import 'package:flutter/material.dart';

/// Stores the chosen role in memory only.
/// Example values: 'student' or 'recruiter'
class SelectionState with ChangeNotifier {
  String? _role;
  String? get role => _role;

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void clearRole() {
    _role = null;
    notifyListeners();
  }
}
