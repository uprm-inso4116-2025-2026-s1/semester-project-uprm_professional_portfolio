import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../models/recruiter_profile.dart';
import '../../models/jobseeker_profile.dart';

/// Service for handling local storage operations
class StorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _recruiterProfileKey = 'recruiter_profile';
  static const String _jobseekerProfileKey = 'jobseeker_profile';
  static const String _credentialsKey =
      'user_credentials'; // Store email:password pairs

  /// Save user data to local storage
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Get user data from local storage
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear user data from local storage
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Save recruiter profile to local storage
  Future<void> saveRecruiterProfile(RecruiterProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_recruiterProfileKey, profileJson);
  }

  /// Get recruiter profile from local storage
  Future<RecruiterProfile?> getRecruiterProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_recruiterProfileKey);

    if (profileJson == null) return null;

    try {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return RecruiterProfile.fromJson(profileMap);
    } catch (e) {
      return null;
    }
  }

  /// Save jobseeker profile to local storage
  Future<void> saveJobSeekerProfile(JobSeekerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_jobseekerProfileKey, profileJson);
  }

  /// Get jobseeker profile from local storage
  Future<JobSeekerProfile?> getJobSeekerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_jobseekerProfileKey);

    if (profileJson == null) return null;

    try {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return JobSeekerProfile.fromJson(profileMap);
    } catch (e) {
      return null;
    }
  }

  /// Clear profile data
  Future<void> clearProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recruiterProfileKey);
    await prefs.remove(_jobseekerProfileKey);
  }

  /// Save user credentials (for login authentication)
  Future<void> saveCredentials(String email, String password, User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing credentials
    final credentialsJson = prefs.getString(_credentialsKey);
    Map<String, dynamic> credentials = {};

    if (credentialsJson != null) {
      credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
    }

    // Store: email -> {password, userData}
    credentials[email] = {
      'password': password,
      'user': user.toJson(),
    };

    await prefs.setString(_credentialsKey, jsonEncode(credentials));
  }

  /// Verify login credentials and return user if valid
  Future<User?> verifyCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_credentialsKey);

    if (credentialsJson == null) return null;

    try {
      final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
      final userCred = credentials[email];

      if (userCred == null) return null;

      // Check if password matches
      if (userCred['password'] == password) {
        return User.fromJson(userCred['user'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
