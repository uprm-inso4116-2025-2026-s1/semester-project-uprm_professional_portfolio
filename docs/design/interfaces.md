= Intention-Revealing Interfaces
:revnumber: 1.0
:revdate: 2025-11-27
:toc: left
:sectnums:

== Summary
This document describes the refactoring of public method names across the Profile and Matching modules to follow intention-revealing interface principles.  
Method names now explicitly communicate domain intent rather than generic technical operations.

*Related Issue:* LTT 46  
*Modules Affected:* Profile Module, Matching Module

== Goals
- Replace ambiguous method names with domain-specific terminology.
- Eliminate confusion about method purpose and scope.
- Make code self-documenting through clear naming.
- Align method names with ubiquitous language.

== Non-Goals
- Changing method signatures or parameters.
- Modifying internal implementation logic.
- Refactoring private methods.

== Profile Module

=== UML Class Diagram

----
┌─────────────────────────────────────────────────────────────┐
│                      <<interface>>                          │
│                  IProfileRepository                         │
├─────────────────────────────────────────────────────────────┤
│ + retrieveStudentProfileById(profileId: String)             │
│     → Future<StudentProfile>                                │
│ + updateStudentContactAddress(profileId: String,            │
│     address: Address?) → Future<void>                       │
└─────────────────────────────────────────────────────────────┘
                            △
                            │
                            │ implements
                            │
┌─────────────────────────────────────────────────────────────┐
│              StudentProfileRepository                       │
├─────────────────────────────────────────────────────────────┤
│ - _client: SupabaseClient                                   │
├─────────────────────────────────────────────────────────────┤
│ + retrieveStudentProfileById(profileId: String)             │
│     → Future<StudentProfile>                                │
│ + updateStudentContactAddress(profileId: String,            │
│     address: Address?) → Future<void>                       │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                    StorageService                           │
├─────────────────────────────────────────────────────────────┤
│ Profile Management:                                         │
│ + persistRecruiterProfileLocally(profile: RecruiterProfile) │
│     → Future<void>                                          │
│ + retrieveRecruiterProfileFromLocalStorage()                │
│     → Future<RecruiterProfile?>                             │
│ + persistJobSeekerProfileLocally(profile: JobSeekerProfile) │
│     → Future<void>                                          │
│ + retrieveJobSeekerProfileFromLocalStorage()                │
│     → Future<JobSeekerProfile?>                             │
├─────────────────────────────────────────────────────────────┤
│ User Session Management:                                    │
│ + saveUser(user: User) → Future<void>                       │
│ + getUser() → Future<User?>                                 │
│ + isLoggedIn() → Future<bool>                               │
│ + clearUser() → Future<void>                                │
│ + clearAll() → Future<void>                                 │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│           RecruiterProfileController                        │
├─────────────────────────────────────────────────────────────┤
│ - _isLoading: bool                                          │
│ - _profile: RecruiterProfile?                               │
├─────────────────────────────────────────────────────────────┤
│ + persistRecruiterProfile(profile: RecruiterProfile)        │
│     → Future<bool>                                          │
│ + retrieveRecruiterProfileByUserId(userId: String)          │
│     → Future<void>                                          │
│ + isLoading: bool                                           │
│ + profile: RecruiterProfile?                                │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│           JobSeekerProfileController                        │
├─────────────────────────────────────────────────────────────┤
│ - formKey: GlobalKey<FormState>                             │
│ - majorCtrl: TextEditingController                          │
│ - bioCtrl: TextEditingController                            │
│ - locationCtrl: TextEditingController                       │
│ - skillsCtrl: TextEditingController                         │
│ - ... (additional form controllers)                         │
│ - isStudent: bool                                           │
│ - jobType: String                                           │
│ - willingToRelocate: bool                                   │
│ - resumeName: String?                                       │
├─────────────────────────────────────────────────────────────┤
│ + pickResume() → Future<String?>                            │
│ + toDraftMap() → Map<String, dynamic>                       │
│ + toModel(id: String, userId: String) → JobSeekerProfile    │
│ + loadFromModel(profile: JobSeekerProfile) → void           │
│ + setIsStudent(value: bool) → void                          │
│ + setJobType(value: String) → void                          │
│ + setWillingToRelocate(value: bool) → void                  │
│ + requiredField(value: String?) → String?                   │
│ + optionalInt(value: String?) → String?                     │
│ + optionalUrl(value: String?) → String?                     │
└─────────────────────────────────────────────────────────────┘
----

== Matching Module

=== UML Class Diagram

----
┌─────────────────────────────────────────────────────────────┐
│                   MatchCalculator                           │
├─────────────────────────────────────────────────────────────┤
│ + algorithmVersion: String = "1.0.0" <<static const>>       │
├─────────────────────────────────────────────────────────────┤
│ + evaluateCandidateCompatibility(                           │
│     candidate: CandidateData,                               │
│     requirements: JobRequirements,                          │
│     weights: ScoringWeights) → MatchScore <<static>>        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ creates
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      MatchScore                             │
├─────────────────────────────────────────────────────────────┤
│ + overallScore: double                                      │
│ + breakdown: ScoreBreakdown                                 │
│ + metadata: ScoreMetadata                                   │
├─────────────────────────────────────────────────────────────┤
│ + isStrongMatch: bool                                       │
│ + isModerateMatch: bool                                     │
│ + isWeakMatch: bool                                         │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                   CandidateData                             │
├─────────────────────────────────────────────────────────────┤
│ + skills: List<String>                                      │
│ + gpa: double?                                              │
│ + location: String?                                         │
│ + willingToRelocate: bool                                   │
│ + jobType: String                                           │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                   JobRequirements                           │
├─────────────────────────────────────────────────────────────┤
│ + requiredSkills: List<String>                              │
│ + minimumGpa: double?                                       │
│ + location: String?                                         │
│ + remoteAllowed: bool                                       │
│ + jobType: String                                           │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                   ScoringWeights                            │
├─────────────────────────────────────────────────────────────┤
│ + skillWeight: double                                       │
│ + gpaWeight: double                                         │
│ + locationWeight: double                                    │
│ + jobTypeWeight: double                                     │
├─────────────────────────────────────────────────────────────┤
│ + balanced: ScoringWeights <<static const>>                 │
│ + skillFocused: ScoringWeights <<static const>>             │
│ + academicFocused: ScoringWeights <<static const>>          │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│              SwipeProcessRepository                         │
├─────────────────────────────────────────────────────────────┤
│ + recordSwipeAction(swipe: SwipeProcess) → void             │
└─────────────────────────────────────────────────────────────┘
----

== Method Refactoring Summary

=== Profile Module

[cols="2,2,3"]
|===
|Old Name |New Name |Rationale

|`saveRecruiterProfile()`
|`persistRecruiterProfileLocally()`
|Clarifies local storage persistence

|`getRecruiterProfile()`
|`retrieveRecruiterProfileFromLocalStorage()`
|Explicit about retrieval source

|`saveJobSeekerProfile()`
|`persistJobSeekerProfileLocally()`
|Clarifies local storage persistence

|`getJobSeekerProfile()`
|`retrieveJobSeekerProfileFromLocalStorage()`
|Explicit about retrieval source

|`getById()`
|`retrieveStudentProfileById()`
|Domain-specific retrieval by identifier

|`updateAddress()`
|`updateStudentContactAddress()`
|Clarifies type of address being updated

|`loadProfile()`
|`retrieveRecruiterProfileByUserId()`
|Clarifies lookup by user ID

|`saveProfile()`
|`persistRecruiterProfile()`
|Emphasizes persistence action

|`insertSwipe()`
|`recordSwipeAction()`
|Captures user swipe event
|===

=== Matching Module

[cols="2,2,3"]
|===
|Old Name |New Name |Rationale

|`calculateMatchScore()`
|`evaluateCandidateCompatibility()`
|Reveals domain intent: evaluation vs calculation
|===
