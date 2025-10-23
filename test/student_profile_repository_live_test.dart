import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uprm_professional_portfolio/core/constants/env_prod.dart';
import 'package:uprm_professional_portfolio/domain/address.dart';
import 'package:uprm_professional_portfolio/services/student_profile_repository.dart';

// Provide these however you prefer:
//  - hardcode temporarily (quickest), OR
//  - use --dart-define like your chat test
const String kProfileId =
    String.fromEnvironment('PROFILE_ID', defaultValue: '');

// For test login (must be the OWNER of kProfileId)
const String kTestEmail =
    String.fromEnvironment('TEST_EMAIL', defaultValue: '');
const String kTestPassword =
    String.fromEnvironment('TEST_PASSWORD', defaultValue: '');

void main() {
  late StudentProfileRepository repo;

  group('StudentProfileRepository (LIVE)', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      HttpOverrides.global = null; // allow network

      expect(kProfileId.isNotEmpty, true,
          reason:
              'Missing PROFILE_ID. Pass --dart-define=PROFILE_ID=<student_profile_uuid>');

      expect(kTestEmail.isNotEmpty, true,
          reason:
              'Missing TEST_EMAIL. Pass --dart-define=TEST_EMAIL=<email>');
      expect(kTestPassword.isNotEmpty, true,
          reason:
              'Missing TEST_PASSWORD. Pass --dart-define=TEST_PASSWORD=<pw>');

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );

      // Sign in as the actual owner of kProfileId
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: kTestEmail,
        password: kTestPassword,
      );
      expect(res.user, isNotNull, reason: 'Login failed / user not confirmed');

      repo = StudentProfileRepository(Supabase.instance.client);
    });

    test('updateAddress → read back (round trip)', () async {
      final addr = Address(
        line1: '123 Main St',
        line2: 'Apt 2',
        city: 'Mayagüez',
        region: 'PR',
        postalCode: '00680',
        countryCode: 'PR',
      );

      try {
        await repo.updateAddress(profileId: kProfileId, address: addr);
      } on PostgrestException catch (e) {
        // ignore: avoid_print
        print('PG error code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}');
        rethrow;
      }

      final got = await repo.getById(kProfileId);

      expect(got.address, isNotNull);
      expect(got.address!.line1, '123 Main St');
      expect(got.address!.city, 'Mayagüez');
      expect(got.address!.countryCode, 'PR');
    });

    test('null address clears DB columns', () async {
      await repo.updateAddress(profileId: kProfileId, address: null);
      final got = await repo.getById(kProfileId);
      expect(got.address, isNull);
    });
  });
}
