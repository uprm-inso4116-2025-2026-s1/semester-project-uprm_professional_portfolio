import 'package:flutter/material.dart';
import '../../../models/jobseeker_profile.dart';

// JobSeeker profile controller
class JobSeekerProfileController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  JobSeekerProfile? _profile;
  JobSeekerProfile? get profile => _profile;

  // Save job seeker profile
  Future<bool> saveProfile(JobSeekerProfile profile) async {
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

  // Load job seeker profile
  Future<void> loadProfile(String userId) async {
    _setLoading(true);

    try {
      // TODO: Implement API call to load profile
      await Future<void>.delayed(
          const Duration(seconds: 1)); // Simulate API call

      // Mock profile data
      _profile = JobSeekerProfile(
        id: 'mock-profile-id',
        userId: userId,
        major: 'Computer Science',
        graduationYear: 2025,
        isStudent: true,
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
