import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/address.dart';
import '../domain/student_profile.dart';

class StudentProfileRepository {
  final SupabaseClient _client;
  StudentProfileRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  // --- mappers ---
  Address? _rowToAddress(Map<String, dynamic> r) {
    if (r['address_line1'] == null) return null;
    return Address(
      line1: r['address_line1'] as String? ?? '',
      line2: r['address_line2'] as String?,
      city: r['address_city'] as String? ?? '',
      region: r['address_region'] as String? ?? '',
      postalCode: r['address_postal_code'] as String? ?? '',
      countryCode: (r['address_country_code'] as String? ?? '').toUpperCase(),
    );
  }

  Map<String, Object?> _addressParams(Address? a) => a == null
      ? {
          'address_line1': null,
          'address_line2': null,
          'address_city': null,
          'address_region': null,
          'address_postal_code': null,
          'address_country_code': null,
        }
      : {
          'address_line1': a.line1,
          'address_line2': a.line2,
          'address_city': a.city,
          'address_region': a.region,
          'address_postal_code': a.postalCode,
          'address_country_code': a.countryCode,
        };

  StudentProfile _rowToStudentProfile(Map<String, dynamic> r) {
    return StudentProfile(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      createdAt: r['created_at'] == null
          ? null
          : DateTime.parse(r['created_at'] as String),
      address: _rowToAddress(r),
    );
  }

  // --- public API ---
  Future<StudentProfile> getById(String profileId) async {
    final row = await _client
        .from('student_profiles')
        .select('id,user_id,created_at,'
                'address_line1,address_line2,address_city,'
                'address_region,address_postal_code,address_country_code')
        .eq('id', profileId)
        .single();
    return _rowToStudentProfile(row);
  }

  Future<void> updateAddress({
    required String profileId,
    required Address? address,
  }) async {
    await _client
        .from('student_profiles')
        .update(_addressParams(address))
        .eq('id', profileId)
        .select();
  }
}
