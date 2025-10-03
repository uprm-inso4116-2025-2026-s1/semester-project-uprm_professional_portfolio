import 'package:flutter/material.dart';
import '../../../models/recruiter_profile.dart';

// Recruiter profile controller
class RecruiterProfileController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RecruiterProfile? _profile;
  RecruiterProfile? get profile => _profile;

  // Save recruiter profile
  Future<bool> saveProfile(RecruiterProfile profile) async {
    _setLoading(true);

    try {
      // TODO: Implement API call to save profile
      await Future<void>.delayed(
          const Duration(seconds: 2)); // Simulate API call

      _profile = profile;
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load recruiter profile
  Future<void> loadProfile(String userId) async {
    _setLoading(true);

    try {
      // TODO: Implement API call to load profile
      await Future<void>.delayed(
          const Duration(seconds: 1)); // Simulate API call

      // Mock profile data
      _profile = RecruiterProfile(
        id: 'mock-profile-id',
        userId: userId,
        companyName: 'Mock Company',
        jobTitle: 'Technical Recruiter',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _profile = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
