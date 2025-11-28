import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/domain/student_profile.dart';
import 'package:uprm_professional_portfolio/domain/address.dart';

void main() {
  group('StudentProfile Invariant Tests', () {
    group('Invariant 1: Active Matches Limit', () {
      test('should create profile with valid active matches count', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 5,
          status: ProfileStatus.active,
        );

        expect(profile.activeMatchesCount, 5);
        expect(profile.canAcceptNewMatch(), true);
      });

      test('should enforce maximum of 10 active matches on creation', () {
        expect(
          () => StudentProfile.create(
            id: 'profile-1',
            userId: 'user-1',
            skills: ['Flutter'],
            activeMatchesCount: 11,
          ),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should not allow negative active matches count', () {
        expect(
          () => StudentProfile.create(
            id: 'profile-1',
            userId: 'user-1',
            skills: ['Flutter'],
            activeMatchesCount: -1,
          ),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should increment active matches successfully', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 5,
          status: ProfileStatus.active,
        );

        final updated = profile.incrementActiveMatches();
        expect(updated.activeMatchesCount, 6);
      });

      test('should not increment beyond maximum matches', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 10,
          status: ProfileStatus.active,
        );

        expect(
          () => profile.incrementActiveMatches(),
          throwsA(isA<ProfileInvariantViolation>()),
        );
        expect(profile.canAcceptNewMatch(), false);
      });

      test('should decrement active matches successfully', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 5,
          status: ProfileStatus.active,
        );

        final updated = profile.decrementActiveMatches();
        expect(updated.activeMatchesCount, 4);
      });

      test('should not decrement below zero', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 0,
          status: ProfileStatus.active,
        );

        expect(
          () => profile.decrementActiveMatches(),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should allow exactly 10 active matches', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 10,
          status: ProfileStatus.active,
        );

        expect(profile.activeMatchesCount, 10);
        expect(profile.canAcceptNewMatch(), false);
      });
    });

    group('Invariant 2: Skill Requirements', () {
      test('should create draft profile without skills', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: [],
          status: ProfileStatus.draft,
        );

        expect(profile.skills.isEmpty, true);
        expect(profile.status, ProfileStatus.draft);
      });

      test('should not allow active profile without skills', () {
        expect(
          () => StudentProfile.create(
            id: 'profile-1',
            userId: 'user-1',
            skills: [],
            status: ProfileStatus.active,
          ),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should not activate profile without skills', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: [],
          status: ProfileStatus.draft,
        );

        expect(
          () => profile.activate(),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should activate profile with at least one skill', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        final activated = profile.activate();
        expect(activated.status, ProfileStatus.active);
      });

      test('should add skill to profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        final updated = profile.addSkill('Dart');
        expect(updated.skills.length, 2);
        expect(updated.skills.contains('Dart'), true);
      });

      test('should not add empty skill', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        expect(
          () => profile.addSkill('   '),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should not add duplicate skill', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        final updated = profile.addSkill('Flutter');
        expect(updated.skills.length, 1);
      });

      test('should remove skill from profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter', 'Dart'],
          status: ProfileStatus.draft,
        );

        final updated = profile.removeSkill('Dart');
        expect(updated.skills.length, 1);
        expect(updated.skills.contains('Dart'), false);
      });

      test('should not remove last skill from active profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.active,
        );

        expect(
          () => profile.removeSkill('Flutter'),
          throwsA(isA<ProfileInvariantViolation>()),
        );
      });

      test('should allow removing last skill from draft profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        final updated = profile.removeSkill('Flutter');
        expect(updated.skills.isEmpty, true);
      });

      test('should not remove non-existent skill', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.draft,
        );

        final updated = profile.removeSkill('Python');
        expect(updated.skills.length, 1);
      });
    });

    group('Profile Status Transitions', () {
      test('should create profile in draft status by default', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
        );

        expect(profile.status, ProfileStatus.draft);
      });

      test('should archive active profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.active,
        );

        final archived = profile.archive();
        expect(archived.status, ProfileStatus.archived);
      });

      test('should not re-activate already active profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.active,
        );

        final reactivated = profile.activate();
        expect(identical(profile, reactivated), true);
      });

      test('should not re-archive already archived profile', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          status: ProfileStatus.archived,
        );

        final rearchived = profile.archive();
        expect(identical(profile, rearchived), true);
      });
    });

    group('Complex Scenarios', () {
      test('should handle workflow: draft → add skills → activate', () {
        var profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          status: ProfileStatus.draft,
        );

        // Start as draft with no skills
        expect(profile.status, ProfileStatus.draft);
        expect(profile.skills.isEmpty, true);

        // Add skills
        profile = profile.addSkill('Flutter');
        profile = profile.addSkill('Dart');
        profile = profile.addSkill('Firebase');

        expect(profile.skills.length, 3);

        // Activate profile
        profile = profile.activate();
        expect(profile.status, ProfileStatus.active);
        expect(profile.isActiveAndComplete, true);
      });

      test('should handle match lifecycle', () {
        var profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 0,
          status: ProfileStatus.active,
        );

        // Add matches progressively
        for (int i = 1; i <= 10; i++) {
          expect(profile.canAcceptNewMatch(), true);
          profile = profile.incrementActiveMatches();
          expect(profile.activeMatchesCount, i);
        }

        // Should be at max
        expect(profile.canAcceptNewMatch(), false);
        expect(
          () => profile.incrementActiveMatches(),
          throwsA(isA<ProfileInvariantViolation>()),
        );

        // Remove some matches
        profile = profile.decrementActiveMatches();
        expect(profile.activeMatchesCount, 9);
        expect(profile.canAcceptNewMatch(), true);
      });

      test('should maintain profile with address', () {
        final address = Address(
          line1: '123 University Ave',
          city: 'Mayagüez',
          region: 'PR',
          postalCode: '00680',
          countryCode: 'PR',
        );

        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          address: address,
          skills: ['Flutter'],
          status: ProfileStatus.active,
        );

        expect(profile.address, isNotNull);
        expect(profile.address!.city, 'Mayagüez');
      });

      test('should preserve immutability through operations', () {
        final original = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
          activeMatchesCount: 5,
          status: ProfileStatus.active,
        );

        final withNewSkill = original.addSkill('Dart');
        final withMoreMatches = original.incrementActiveMatches();

        // Original should be unchanged
        expect(original.skills.length, 1);
        expect(original.activeMatchesCount, 5);

        // New instances should reflect changes
        expect(withNewSkill.skills.length, 2);
        expect(withNewSkill.activeMatchesCount, 5); // Unchanged

        expect(withMoreMatches.skills.length, 1); // Unchanged
        expect(withMoreMatches.activeMatchesCount, 6);
      });
    });

    group('Edge Cases', () {
      test('should handle profile with maximum skills and matches', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: List.generate(20, (i) => 'Skill$i'),
          activeMatchesCount: 10,
          status: ProfileStatus.active,
        );

        expect(profile.skills.length, 20);
        expect(profile.activeMatchesCount, 10);
        expect(profile.canAcceptNewMatch(), false);
      });

      test('should handle equality correctly', () {
        final profile1 = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter'],
        );

        final profile2 = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Dart'],
        );

        final profile3 = StudentProfile.create(
          id: 'profile-2',
          userId: 'user-1',
          skills: ['Flutter'],
        );

        expect(profile1 == profile2, true); // Same ID and userId
        expect(profile1 == profile3, false); // Different ID
      });

      test('should handle toString formatting', () {
        final profile = StudentProfile.create(
          id: 'profile-1',
          userId: 'user-1',
          skills: ['Flutter', 'Dart'],
          activeMatchesCount: 3,
          status: ProfileStatus.active,
        );

        final str = profile.toString();
        expect(str.contains('profile-1'), true);
        expect(str.contains('user-1'), true);
        expect(str.contains('active'), true);
        expect(str.contains('skills: 2'), true);
        expect(str.contains('activeMatches: 3'), true);
      });
    });
  });
}
