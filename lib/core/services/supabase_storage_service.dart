import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _bucketName = 'profile_pictures';

  /// Uploads the selected profile picture file to Supabase Storage.
  ///
  /// The file is stored securely under a path that matches the user's ID
  /// (e.g., 'UUID/avatar.jpg') to satisfy the RLS INSERT policy.
  /// Returns the public URL of the newly uploaded file.
  Future<String> uploadProfilePicture(XFile imageFile) async {

    final user = _supabase.auth.currentUser;
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
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(filePath);

      return publicUrl;

    } on StorageException catch (e) {
      throw Exception('Storage Upload Failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during upload: $e');
    }
  }
}