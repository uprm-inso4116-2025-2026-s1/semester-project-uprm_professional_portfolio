= Aggregate Invariants in the StudentProfile Domain
:revnumber: 1.0
:revdate: 2025-11-27
:toc: left
:sectnums:

== Summary
This document defines the core invariants enforced within the StudentProfile aggregate root.  
These business rules maintain data consistency and ensure profiles meet system requirements before participating in matching activities.

The two primary invariants implemented:

1. **Maximum Active Matches Limit**
2. **Minimum Skills Requirement for Active Status**

Both invariants are enforced through the aggregate's factory constructor and business methods.

== Goals
- Ensure StudentProfile aggregate maintains valid state at all times.
- Prevent invalid profile operations through domain-level validation.
- Centralize business rules within the aggregate boundary.
- Provide clear error handling for invariant violations.

== Non-Goals
- UI-level validation (domain rules are authoritative).
- Soft warnings or partial enforcement.
- Runtime configuration of invariant thresholds.

== Domain Invariants

=== Invariant 1: Maximum Active Matches Limit
*Rule:*  
A student profile cannot have more than **10 active matches** simultaneously.

*Why:*  
- Encourages meaningful engagement rather than match accumulation.  
- Prevents system abuse and resource overload.  
- Maintains match quality over quantity.

*Applies to:*  
- Profile creation via factory constructor  
- Match acceptance operations  
- Active match increment operations  

=== Invariant 2: Minimum Skills Requirement
*Rule:*  
A profile must contain **at least 1 skill** before transitioning to active status.

*Why:*  
- Active profiles are visible to recruiters for matching.  
- Skills provide the basis for compatibility algorithms.  
- Ensures all searchable profiles contain actionable data.

*Applies to:*  
- Profile activation  
- Skill removal from active profiles  
- Direct creation of active profiles  

== Centralized Invariant Constants

=== StudentProfile Constants
All invariant thresholds are defined as class constants.

[source,dart]
----
class StudentProfile {
  static const int maxActiveMatches = 10;
  static const int minSkillsForActive = 1;
  // ...
}
----

No magic numbers may appear in business methods.

=== Validation Functions

[source,dart]
----
factory StudentProfile.create({...}) {
  if (activeMatchesCount > maxActiveMatches) {
    throw ProfileInvariantViolation(
      'Cannot have more than $maxActiveMatches active matches.'
    );
  }
  
  if (status == ProfileStatus.active && skills.isEmpty) {
    throw ProfileInvariantViolation(
      'Profile must have at least $minSkillsForActive skill to be active'
    );
  }
  // ...
}
----

These validations execute *before* object construction.

== Enforcement Points

=== Active Matches Limit Enforcement
- Factory constructor validation  
- `incrementActiveMatches()` method guard  
- `canAcceptNewMatch()` boundary check  

=== Skills Requirement Enforcement
- Factory constructor validation  
- `activate()` method guard  
- `removeSkill()` last-skill protection  

== ASCII Diagrams

=== Active Match Increment Flow
```
incrementActiveMatches() ---> Check current count
                               |
                               valid (< 10)?
                         +-----+-----+
                         |           |
                        YES          NO
                         |           |
                    Return new   Throw ProfileInvariantViolation
                    StudentProfile
```

=== Profile Activation Flow
```
activate() ---> Check skills.length
                |
                >= 1 skill?
          +-----+-----+
          |           |
         YES          NO
          |           |
     Set status    Throw ProfileInvariantViolation
     to active
```

== Profile Status Lifecycle

=== Valid Transitions
```
draft -----> active -----> archived
  ^            |
  |            |
  +------------+
   (reactivation)
```

*Status Definitions:*

- **draft**: Initial state, no skill requirement, not visible to recruiters  
- **active**: Requires ≥1 skill, visible for matching, accepts up to 10 matches  
- **archived**: Inactive state, preserves data, not visible to recruiters  

== Business Methods

[cols="2,3,3"]
|===
|Method |Purpose |Invariant Checks

|`activate()`
|Transition profile to active status
|Validates ≥1 skill present

|`addSkill(String)`
|Add skill to profile
|Rejects empty/whitespace strings

|`removeSkill(String)`
|Remove skill from profile
|Prevents removing last skill from active profile

|`incrementActiveMatches()`
|Record new match acceptance
|Enforces max 10 active matches

|`decrementActiveMatches()`
|Record match closure
|Prevents negative count

|`archive()`
|Deactivate profile
|None

|`canAcceptNewMatch()`
|Check if new match allowed
|Returns false at 10 matches or if inactive
|===

== Exception Handling

=== ProfileInvariantViolation
Custom domain exception thrown when invariants are violated.

*Properties:*
- `message`: Human-readable violation description
- `code`: Optional error code for client handling

*Usage Pattern:*
[source,dart]
----
try {
  final profile = StudentProfile.create(
    id: 'profile-1',
    userId: 'user-1',
    skills: [],
    status: ProfileStatus.active,
  );
} on ProfileInvariantViolation catch (e) {
  // Handle domain error appropriately
  print('Invariant violation: ${e.message}');
}
----

== Testing Strategy

=== Active Matches Tests
- Count = **0** → allowed  
- Count = **5** → allowed  
- Count = **10** → allowed (boundary)  
- Count = **11** → must throw exception  
- Increment at **10** → must throw exception  
- Decrement at **0** → must throw exception  

=== Skills Requirement Tests
- Draft with 0 skills → allowed  
- Active with 0 skills → must throw exception  
- Activate with 0 skills → must throw exception  
- Remove last skill from active → must throw exception  
- Remove last skill from draft → allowed  

=== Test Coverage
See `test/student_profile_invariants_test.dart` for **30 test cases** covering:
- Boundary conditions  
- State transitions  
- Negative scenarios  
- Immutability guarantees  

== Extensibility
Future invariants may include:
- Maximum skills per profile  
- Minimum profile completeness score  
- Geographic location requirements  
- Rate limiting for status changes  
- Temporal constraints (cooldown periods)  

To add a new invariant:
1. Define constant in `StudentProfile`  
2. Add validation in factory constructor  
3. Implement enforcement in relevant business methods  
4. Document in this file  
5. Add comprehensive test coverage  

== Risks & Mitigations

[cols="2,2,3"]
|===
|Risk |Impact |Mitigation

|Magic numbers in business logic
|Inconsistent enforcement
|Use class constants exclusively

|Validation bypassed
|Invalid state persists
|Private constructor, factory pattern only

|Future requirement changes
|Breaking existing data
|Version invariants, migration strategy

|Over-restrictive rules
|Poor user experience
|Clear error messages, UX guidance
|===

== Conclusion
Aggregate invariants ensure StudentProfile maintains valid state throughout its lifecycle.  
This document serves as the authoritative source for all business rules governing profile eligibility and match participation.
