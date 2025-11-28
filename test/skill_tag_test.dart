import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/domain/skill_tag.dart';

void main() {
  group('SkillTag Value Object Tests', () {
    group('Creation and Validation', () {
      test('should create valid skill with default category', () {
        final skill = SkillTag.create(name: 'Flutter');

        expect(skill.name, 'Flutter');
        expect(skill.category, SkillCategory.other);
      });

      test('should create valid skill with specified category', () {
        final skill = SkillTag.create(
          name: 'Python',
          category: SkillCategory.technical,
        );

        expect(skill.name, 'Python');
        expect(skill.category, SkillCategory.technical);
      });

      test('should trim whitespace from skill name', () {
        final skill = SkillTag.create(name: '  JavaScript  ');

        expect(skill.name, 'JavaScript');
      });

      test('should create skill using fromString convenience method', () {
        final skill = SkillTag.fromString('React');

        expect(skill.name, 'React');
        expect(skill.category, SkillCategory.other);
      });

      test('should accept valid special characters', () {
        final skills = [
          SkillTag.create(name: 'C++'),
          SkillTag.create(name: 'C#'),
          SkillTag.create(name: 'Node.js'),
          SkillTag.create(name: 'Test-Driven Development'),
        ];

        expect(skills[0].name, 'C++');
        expect(skills[1].name, 'C#');
        expect(skills[2].name, 'Node.js');
        expect(skills[3].name, 'Test-Driven Development');
      });

      test('should reject empty skill name', () {
        expect(
          () => SkillTag.create(name: ''),
          throwsA(isA<SkillTagValidationException>()),
        );
      });

      test('should reject whitespace-only skill name', () {
        expect(
          () => SkillTag.create(name: '   '),
          throwsA(isA<SkillTagValidationException>()),
        );
      });

      test('should reject skill name shorter than 2 characters', () {
        expect(
          () => SkillTag.create(name: 'A'),
          throwsA(isA<SkillTagValidationException>()),
        );
      });

      test('should accept skill name with exactly 2 characters', () {
        final skill = SkillTag.create(name: 'Go');

        expect(skill.name, 'Go');
      });

      test('should reject skill name longer than 50 characters', () {
        final longName = 'A' * 51;

        expect(
          () => SkillTag.create(name: longName),
          throwsA(isA<SkillTagValidationException>()),
        );
      });

      test('should accept skill name with exactly 50 characters', () {
        final maxName = 'A' * 50;
        final skill = SkillTag.create(name: maxName);

        expect(skill.name.length, 50);
      });

      test('should reject skill with invalid characters', () {
        expect(
          () => SkillTag.create(name: 'Skill@Tag'),
          throwsA(isA<SkillTagValidationException>()),
        );

        expect(
          () => SkillTag.create(name: 'Skill&Tag'),
          throwsA(isA<SkillTagValidationException>()),
        );

        expect(
          () => SkillTag.create(name: r'Skill$Tag'),
          throwsA(isA<SkillTagValidationException>()),
        );
      });
    });

    group('Equality and Comparison', () {
      test('should consider identical skills equal', () {
        final skill1 = SkillTag.create(name: 'Python');
        final skill2 = SkillTag.create(name: 'Python');

        expect(skill1, equals(skill2));
        expect(skill1.hashCode, equals(skill2.hashCode));
      });

      test('should be case-insensitive for equality', () {
        final skill1 = SkillTag.create(name: 'Python');
        final skill2 = SkillTag.create(name: 'python');
        final skill3 = SkillTag.create(name: 'PYTHON');

        expect(skill1, equals(skill2));
        expect(skill2, equals(skill3));
        expect(skill1, equals(skill3));
      });

      test('should consider different skills unequal', () {
        final skill1 = SkillTag.create(name: 'Python');
        final skill2 = SkillTag.create(name: 'Java');

        expect(skill1, isNot(equals(skill2)));
      });

      test('should match using matches method', () {
        final skill1 = SkillTag.create(name: 'Flutter');
        final skill2 = SkillTag.create(name: 'flutter');

        expect(skill1.matches(skill2), true);
      });

      test('should not match different skills', () {
        final skill1 = SkillTag.create(name: 'Flutter');
        final skill2 = SkillTag.create(name: 'React');

        expect(skill1.matches(skill2), false);
      });

      test('should ignore category in equality comparison', () {
        final skill1 = SkillTag.create(
          name: 'Python',
          category: SkillCategory.technical,
        );
        final skill2 = SkillTag.create(
          name: 'Python',
          category: SkillCategory.other,
        );

        expect(skill1, equals(skill2));
      });
    });

    group('Search and Matching', () {
      test('should match query case-insensitively', () {
        final skill = SkillTag.create(name: 'JavaScript');

        expect(skill.matchesQuery('java'), true);
        expect(skill.matchesQuery('JAVA'), true);
        expect(skill.matchesQuery('script'), true);
        expect(skill.matchesQuery('JavaScript'), true);
      });

      test('should not match unrelated query', () {
        final skill = SkillTag.create(name: 'Python');

        expect(skill.matchesQuery('java'), false);
        expect(skill.matchesQuery('ruby'), false);
      });

      test('should handle query with whitespace', () {
        final skill = SkillTag.create(name: 'Python');

        expect(skill.matchesQuery('  python  '), true);
      });

      test('should match partial skill names', () {
        final skill = SkillTag.create(name: 'TypeScript');

        expect(skill.matchesQuery('Type'), true);
        expect(skill.matchesQuery('Script'), true);
        expect(skill.matchesQuery('pe'), true);
      });
    });

    group('Serialization', () {
      test('should serialize to JSON', () {
        final skill = SkillTag.create(
          name: 'Python',
          category: SkillCategory.technical,
        );

        final json = skill.toJson();

        expect(json['name'], 'Python');
        expect(json['category'], 'technical');
      });

      test('should deserialize from JSON', () {
        final json = {
          'name': 'Python',
          'category': 'technical',
        };

        final skill = SkillTag.fromJson(json);

        expect(skill.name, 'Python');
        expect(skill.category, SkillCategory.technical);
      });

      test('should round-trip through JSON', () {
        final original = SkillTag.create(
          name: 'Flutter',
          category: SkillCategory.technical,
        );

        final json = original.toJson();
        final restored = SkillTag.fromJson(json);

        expect(restored, equals(original));
        expect(restored.category, original.category);
      });

      test('should default to other category for unknown category in JSON', () {
        final json = {
          'name': 'Python',
          'category': 'unknown_category',
        };

        final skill = SkillTag.fromJson(json);

        expect(skill.category, SkillCategory.other);
      });
    });

    group('Immutability', () {
      test('should be immutable', () {
        final skill = SkillTag.create(name: 'Python');

        // Attempting to modify should create new instance
        // (No modifying methods exist by design)
        expect(skill.name, 'Python');
      });

      test('should maintain identity across operations', () {
        final skill1 = SkillTag.create(name: 'Python');
        final skill2 = skill1;

        expect(identical(skill1, skill2), true);
      });
    });

    group('Categories', () {
      test('should support all skill categories', () {
        final categories = [
          SkillCategory.technical,
          SkillCategory.soft,
          SkillCategory.language,
          SkillCategory.domain,
          SkillCategory.other,
        ];

        for (final category in categories) {
          final skill = SkillTag.create(
            name: 'Test Skill',
            category: category,
          );
          expect(skill.category, category);
        }
      });

      test('should use other as default category', () {
        final skill = SkillTag.create(name: 'Test');

        expect(skill.category, SkillCategory.other);
      });
    });

    group('String Representation', () {
      test('should provide readable toString', () {
        final skill = SkillTag.create(
          name: 'Python',
          category: SkillCategory.technical,
        );

        final str = skill.toString();

        expect(str.contains('Python'), true);
        expect(str.contains('technical'), true);
      });
    });

    group('Collections', () {
      test('should work correctly in Set', () {
        final skill1 = SkillTag.create(name: 'Python');
        final skill2 = SkillTag.create(name: 'python');
        final skill3 = SkillTag.create(name: 'Java');

        final skills = {skill1, skill2, skill3};

        // skill1 and skill2 are equal, so Set should have only 2 items
        expect(skills.length, 2);
        expect(skills.contains(skill1), true);
        expect(skills.contains(skill3), true);
      });

      test('should work correctly in List', () {
        final skills = [
          SkillTag.create(name: 'Python'),
          SkillTag.create(name: 'Java'),
          SkillTag.create(name: 'JavaScript'),
        ];

        expect(skills.length, 3);
        expect(skills[0].name, 'Python');
        expect(skills[1].name, 'Java');
        expect(skills[2].name, 'JavaScript');
      });

      test('should support contains check in List', () {
        final skills = [
          SkillTag.create(name: 'Python'),
          SkillTag.create(name: 'Java'),
        ];

        final pythonSkill = SkillTag.create(name: 'python');
        final rubySkill = SkillTag.create(name: 'Ruby');

        expect(skills.contains(pythonSkill), true);
        expect(skills.contains(rubySkill), false);
      });
    });

    group('Independent Operation', () {
      test('should operate without any Profile dependencies', () {
        // This test verifies SkillTag can be created and used
        // without importing or depending on Profile module
        final skill = SkillTag.create(name: 'Flutter');

        expect(skill.name, 'Flutter');
        expect(skill.category, SkillCategory.other);

        // Verify core operations work independently
        final skill2 = SkillTag.create(name: 'flutter');
        expect(skill.matches(skill2), true);
        expect(skill.matchesQuery('flu'), true);

        final json = skill.toJson();
        final restored = SkillTag.fromJson(json);
        expect(restored, equals(skill));
      });

      test('should be usable in isolation for skill matching', () {
        final requiredSkills = [
          SkillTag.create(name: 'Python'),
          SkillTag.create(name: 'Java'),
          SkillTag.create(name: 'SQL'),
        ];

        final candidateSkills = [
          SkillTag.create(name: 'python'),
          SkillTag.create(name: 'JavaScript'),
        ];

        // Check overlap without any Profile logic
        final matches = candidateSkills
            .where((cs) => requiredSkills.any((rs) => rs.matches(cs)))
            .toList();

        expect(matches.length, 1);
        expect(matches[0].name, 'python');
      });
    });
  });
}
