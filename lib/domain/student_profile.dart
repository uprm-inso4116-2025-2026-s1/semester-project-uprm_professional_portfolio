import 'address.dart';

/// StudentProfile aggregate root with enforced invariants
/// 
/// Business Rules (Invariants):
/// 1. A student cannot have more than 10 active matches
/// 2. A profile must contain at least one skill before it can become "active"
/// 3. Profile status must be one of: draft, active, archived
class StudentProfile {
  final String id;            // UUID (pk)
  final String userId;        // FK -> users.id
  final DateTime? createdAt;
  final Address? address;
  final List<String> skills;
  final int activeMatchesCount;
  final ProfileStatus status;

  // Maximum allowed active matches
  static const int maxActiveMatches = 10;
  
  // Minimum skills required for active profile
  static const int minSkillsForActive = 1;

  const StudentProfile({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.address,
    required this.skills,
    required this.activeMatchesCount,
    required this.status,
  }) : assert(activeMatchesCount >= 0, 'Active matches count cannot be negative'),
       assert(activeMatchesCount <= maxActiveMatches, 
              'Cannot have more than $maxActiveMatches active matches');

  /// Factory constructor with invariant enforcement
  factory StudentProfile.create({
    required String id,
    required String userId,
    DateTime? createdAt,
    Address? address,
    List<String> skills = const [],
    int activeMatchesCount = 0,
    ProfileStatus status = ProfileStatus.draft,
  }) {
    // Invariant 1: Validate active matches constraint
    if (activeMatchesCount < 0) {
      throw ProfileInvariantViolation(
        'Active matches count cannot be negative',
      );
    }
    
    if (activeMatchesCount > maxActiveMatches) {
      throw ProfileInvariantViolation(
        'Cannot have more than $maxActiveMatches active matches. '
        'Current: $activeMatchesCount',
      );
    }

    // Invariant 2: Validate skills requirement for active status
    if (status == ProfileStatus.active && skills.isEmpty) {
      throw ProfileInvariantViolation(
        'Profile must have at least $minSkillsForActive skill to be active',
      );
    }

    return StudentProfile(
      id: id,
      userId: userId,
      createdAt: createdAt ?? DateTime.now(),
      address: address,
      skills: List.unmodifiable(skills),
      activeMatchesCount: activeMatchesCount,
      status: status,
    );
  }

  /// Activate profile - enforces skill requirement
  StudentProfile activate() {
    if (skills.length < minSkillsForActive) {
      throw ProfileInvariantViolation(
        'Cannot activate profile: must have at least $minSkillsForActive skill. '
        'Current skills: ${skills.length}',
      );
    }

    if (status == ProfileStatus.active) {
      return this; // Already active
    }

    return copyWith(status: ProfileStatus.active);
  }

  /// Add a skill to the profile
  StudentProfile addSkill(String skill) {
    if (skill.trim().isEmpty) {
      throw ProfileInvariantViolation('Skill cannot be empty');
    }

    if (skills.contains(skill)) {
      return this; // Skill already exists
    }

    final updatedSkills = [...skills, skill];
    return copyWith(skills: updatedSkills);
  }

  /// Remove a skill from the profile
  StudentProfile removeSkill(String skill) {
    if (!skills.contains(skill)) {
      return this; // Skill doesn't exist
    }

    final updatedSkills = skills.where((s) => s != skill).toList();

    // Check if removing skill would violate active profile constraint
    if (status == ProfileStatus.active && updatedSkills.isEmpty) {
      throw ProfileInvariantViolation(
        'Cannot remove last skill from active profile. '
        'Deactivate profile first or add another skill.',
      );
    }

    return copyWith(skills: updatedSkills);
  }

  /// Increment active matches count
  StudentProfile incrementActiveMatches() {
    if (activeMatchesCount >= maxActiveMatches) {
      throw ProfileInvariantViolation(
        'Cannot add match: maximum of $maxActiveMatches active matches reached',
      );
    }

    return copyWith(activeMatchesCount: activeMatchesCount + 1);
  }

  /// Decrement active matches count
  StudentProfile decrementActiveMatches() {
    if (activeMatchesCount <= 0) {
      throw ProfileInvariantViolation(
        'Cannot decrement: no active matches to remove',
      );
    }

    return copyWith(activeMatchesCount: activeMatchesCount - 1);
  }

  /// Archive the profile
  StudentProfile archive() {
    if (status == ProfileStatus.archived) {
      return this; // Already archived
    }

    return copyWith(status: ProfileStatus.archived);
  }

  /// Check if profile can accept new matches
  bool canAcceptNewMatch() {
    return status == ProfileStatus.active && 
           activeMatchesCount < maxActiveMatches;
  }

  /// Check if profile is active and complete
  bool get isActiveAndComplete {
    return status == ProfileStatus.active && skills.isNotEmpty;
  }

  /// Copy with method for immutability
  StudentProfile copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    Address? address,
    List<String>? skills,
    int? activeMatchesCount,
    ProfileStatus? status,
  }) {
    return StudentProfile.create(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      skills: skills ?? this.skills,
      activeMatchesCount: activeMatchesCount ?? this.activeMatchesCount,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;

  @override
  String toString() {
    return 'StudentProfile('
        'id: $id, '
        'userId: $userId, '
        'status: $status, '
        'skills: ${skills.length}, '
        'activeMatches: $activeMatchesCount'
        ')';
  }
}

/// Profile status enumeration
enum ProfileStatus {
  draft,
  active,
  archived;

  @override
  String toString() => name;
}

/// Custom exception for invariant violations
class ProfileInvariantViolation implements Exception {
  final String message;

  ProfileInvariantViolation(this.message);

  @override
  String toString() => 'ProfileInvariantViolation: $message';
}
