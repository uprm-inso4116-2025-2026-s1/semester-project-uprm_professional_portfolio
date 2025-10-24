import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/recruiter_profile.dart';

class RecruiterProfileController extends ChangeNotifier {
  RecruiterProfileController({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RecruiterProfile? _profile;
  RecruiterProfile? get profile => _profile;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  /// Create or update recruiter profile for this [userId].
  /// Returns `null` on success, or an error message string.
  Future<String?> saveProfile(RecruiterProfile p) async {
    _setLoading(true);
    try {
      final row = _toRow(p)
        ..addAll({
          'user_id': p.userId,
          'updated_at': DateTime.now().toIso8601String(),
        });

      final res = await _supabase
          .from('recruiter_profiles')
          .upsert(row, onConflict: 'user_id')
          .select()
          .single();

      _profile = _fromRow(res);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Saving profile failed';
    } finally {
      _setLoading(false);
    }
  }

  /// Load profile by [userId]. Returns `null` on success or an error message.
  Future<String?> loadProfile(String userId) async {
    _setLoading(true);
    try {
      final res = await _supabase
          .from('recruiter_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      _profile = res == null ? null : _fromRow(res);
      notifyListeners();
      return null;
    } catch (e) {
      _profile = null;
      return 'Loading profile failed';
    } finally {
      _setLoading(false);
    }
  }

  // ---- Mapping helpers ------------------------------------------------------

  Map<String, dynamic> _toRow(RecruiterProfileScreen p) {
    // Adjust keys to your actual table columns.
    return {
      'company_name': p.companyName,
      'job_title': p.jobTitle,
      'company_url': p.companyUrl,          // optional in your model
      'location': p.location,               // optional
      'contact_name': p.contactName,        // optional
      'contact_email': p.contactEmail,      // optional
      'contact_phone': p.contactPhone,      // optional
    };
  }

  RecruiterProfile _fromRow(Map<String, dynamic> r) {
    return RecruiterProfile(
      id: (r['id'] ?? r['user_id']).toString(), // use your PK; fallback to user_id
      userId: r['user_id'] as String,
      companyName: r['company_name'] as String? ?? '',
      jobTitle: r['job_title'] as String? ?? '',
      companyUrl: r['company_url'] as String?,      // optional
      location: r['location'] as String?,           // optional
      contactName: r['contact_name'] as String?,    // optional
      contactEmail: r['contact_email'] as String?,  // optional
      contactPhone: r['contact_phone'] as String?,  // optional
      createdAt: DateTime.tryParse(
            (r['created_at'] ?? r['updated_at'])?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
