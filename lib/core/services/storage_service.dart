import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../models/jobseeker_profile.dart';
import '../../models/recruiter_profile.dart';
import '../../models/user.dart' as app_models;

/// Service for handling local storage operations AND file storage (Supabase)
class StorageService {
  final supa.SupabaseClient _supabase = supa.Supabase.instance.client;
  static const String _bucketName = 'profile_pictures';

  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _recruiterProfileKey = 'recruiter_profile';
  static const String _jobseekerProfileKey = 'jobseeker_profile';
  static const String _credentialsKey = 'user_credentials';

  /// Uploads the selected profile picture file to Supabase Storage.
  Future<String> uploadProfilePicture(XFile imageFile) async {
    final supa.User? user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated. Cannot upload file.");
    }
    final userId = user.id;

    final file = File(imageFile.path);

    const fileName = 'avatar.jpg';
    final filePath = '$userId/$fileName';

    try {
      await _supabase.storage.from(_bucketName).upload(
        filePath,
        file,
        fileOptions: const supa.FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl =
      _supabase.storage.from(_bucketName).getPublicUrl(filePath);
      return publicUrl;
    } on supa.StorageException catch (e) {
      throw Exception('Storage Upload Failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during upload: $e');
    }
  }


  /// Save user data to local storage (our app User model)
  Future<void> saveUser(app_models.User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Get user data from local storage (our app User model)
  Future<app_models.User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return app_models.User.fromJson(userMap);
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
  Future<void> saveCredentials(
      String email,
      String password,
      app_models.User user,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final credentialsJson = prefs.getString(_credentialsKey);
    Map<String, dynamic> credentials = {};

    if (credentialsJson != null) {
      credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
    }

    credentials[email] = {
      'password': password,
      'user': user.toJson(),
    };

    await prefs.setString(_credentialsKey, jsonEncode(credentials));
  }

  /// Verify login credentials and return user if valid
  Future<app_models.User?> verifyCredentials(
      String email,
      String password,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_credentialsKey);

    if (credentialsJson == null) return null;

    try {
      final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
      final userCred = credentials[email];

      if (userCred == null) return null;

      if (userCred['password'] == password) {
        return app_models.User.fromJson(
          userCred['user'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
