= Standalone SkillTag Value Object
:revnumber: 1.0
:revdate: 2025-11-27
:toc: left
:sectnums:

== Summary
SkillTag is a standalone value object representing individual skills. It has no dependencies on Profile or other aggregates, making it reusable across different modules.

== Design Rationale

=== Why Standalone?
Skills were previously coupled to Profile aggregates, which created problems:
- Testing required creating full Profile instances
- Validation was duplicated
- Matching algorithms couldn't be reused independently

Extracting SkillTag as a separate value object solves these issues.

=== Key Design Decisions

Factory constructor enforces validation before creation:
[source,dart]
----
factory SkillTag.create({
  required String name,
  SkillCategory category = SkillCategory.other,
})
----

Case-insensitive equality prevents duplicates (Python = python).

Character validation allows: letters, numbers, spaces, +, -, ., # to support skill names like C++, C#, Node.js.

Length constraints: 2-50 characters.

Five categories for classification: technical, soft, language, domain, other.

== Validation Rules

[cols="2,3"]
|===
|Rule |Example

|Non-empty
|Empty strings rejected

|Min 2 characters
|"A" rejected, "Go" accepted

|Max 50 characters
|51+ characters rejected

|Valid characters only
|Letters, numbers, spaces, +-.#
|===

All violations throw `SkillTagValidationException`.

== Usage Examples

=== Basic Creation
[source,dart]
----
final skill = SkillTag.create(name: 'Python');

final skill = SkillTag.create(
  name: 'Leadership',
  category: SkillCategory.soft,
);
----

=== Matching
[source,dart]
----
final skill1 = SkillTag.create(name: 'Python');
final skill2 = SkillTag.create(name: 'python');

skill1 == skill2              // true
skill1.matches(skill2)        // true
skill1.matchesQuery('py')     // true
----

=== Serialization
[source,dart]
----
final json = skill.toJson();
final skill = SkillTag.fromJson(json);
----

== Integration with Aggregates

StudentProfile can use SkillTag for validated skill management:
[source,dart]
----
class StudentProfile {
  final List<SkillTag> skills;
  
  StudentProfile addSkill(SkillTag skill) {
    if (skills.contains(skill)) return this;
    return copyWith(skills: [...skills, skill]);
  }
}
----

MatchCalculator can compute skill overlap without Profile dependencies:
[source,dart]
----
double calculateSkillScore(
  List<SkillTag> candidateSkills,
  List<SkillTag> requiredSkills,
) {
  if (requiredSkills.isEmpty) return 1.0;
  
  final matches = candidateSkills
      .where((cs) => requiredSkills.any((rs) => rs.matches(cs)))
      .length;
  
  return matches / requiredSkills.length;
}
----

== Testing
36 test cases verify:
- Creation and validation
- Equality and matching
- Serialization
- Collection behavior
- Independent operation without Profile

See test/skill_tag_test.dart for complete coverage.
