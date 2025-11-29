import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Updates the 'avatar_url' column in the 'users' table
  /// for the current authenticated user.
  ///
  /// @param publicUrl - The URL returned after successful file upload.
  Future<void> updateAvatarUrl(String publicUrl) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated. Cannot update profile.");
    }

    final userId = user.id;

    try {
      await _supabase
          .from('users')
          .update({
        'avatar_url': publicUrl,
      })
          .eq('id', userId);


    } on PostgrestException catch (e) {
      throw Exception('Failed to update profile URL in database: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during profile update: $e');
    }
  }
}
