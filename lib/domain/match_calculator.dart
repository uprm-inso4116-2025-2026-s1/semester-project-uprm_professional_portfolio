import 'match_score.dart';

/// Input data for candidate matching calculation
class CandidateData {
  final List<String> skills;
  final double? gpa;
  final String? location;
  final bool willingToRelocate;
  final String jobType; // 'internship', 'full-time', 'part-time'

  const CandidateData({
    required this.skills,
    this.gpa,
    this.location,
    this.willingToRelocate = false,
    this.jobType = 'internship',
  });
}

/// Input data for job opening requirements
class JobRequirements {
  final List<String> requiredSkills;
  final double? minimumGpa;
  final String? location;
  final bool remoteAllowed;
  final String jobType; // 'internship', 'full-time', 'part-time'

  const JobRequirements({
    required this.requiredSkills,
    this.minimumGpa,
    this.location,
    this.remoteAllowed = false,
    this.jobType = 'internship',
  });
}

/// Configuration for score calculation weights
class ScoringWeights {
  final double skillWeight;
  final double gpaWeight;
  final double locationWeight;
  final double jobTypeWeight;

  const ScoringWeights({
    this.skillWeight = 0.50, // 50% weight
    this.gpaWeight = 0.20, // 20% weight
    this.locationWeight = 0.15, // 15% weight
    this.jobTypeWeight = 0.15, // 15% weight
  });

  /// Default balanced weights
  static const ScoringWeights balanced = ScoringWeights();

  /// Skill-focused weights
  static const ScoringWeights skillFocused = ScoringWeights(
    skillWeight: 0.70,
    gpaWeight: 0.15,
    locationWeight: 0.10,
    jobTypeWeight: 0.05,
  );

  /// Academic-focused weights
  static const ScoringWeights academicFocused = ScoringWeights(
    skillWeight: 0.40,
    gpaWeight: 0.40,
    locationWeight: 0.10,
    jobTypeWeight: 0.10,
  );
}

/// Pure, side-effect-free match score calculator.
///
/// This function:
/// - Takes immutable input data
/// - Produces consistent output for the same inputs
/// - Has no side effects (no mutations, no I/O, no state changes)
/// - Is deterministic and testable
class MatchCalculator {
  /// Current algorithm version for tracking
  static const String algorithmVersion = '1.0.0';

  /// Evaluate candidate compatibility with job opening requirements.
  ///
  /// This is a pure function - same inputs always produce same output.
  /// No side effects or mutations occur.
  static MatchScore evaluateCandidateCompatibility({
    required CandidateData candidate,
    required JobRequirements requirements,
    ScoringWeights weights = ScoringWeights.balanced,
  }) {
    final notes = <String>[];

    // 1. Calculate skill score (most important)
    final skillResult = _calculateSkillScore(
      candidateSkills: candidate.skills,
      requiredSkills: requirements.requiredSkills,
    );
    final skillScore = skillResult.$1;
    final matchingCount = skillResult.$2;

    if (matchingCount == 0) {
      notes.add('No matching skills found');
    } else if (matchingCount == requirements.requiredSkills.length) {
      notes.add('All required skills matched');
    }

    // 2. Calculate GPA score
    final gpaScore = _calculateGpaScore(
      candidateGpa: candidate.gpa,
      minimumGpa: requirements.minimumGpa,
    );

    if (candidate.gpa == null) {
      notes.add('No GPA provided');
    } else if (requirements.minimumGpa != null &&
        candidate.gpa! < requirements.minimumGpa!) {
      notes.add('GPA below minimum requirement');
    }

    // 3. Calculate location score
    final locationScore = _calculateLocationScore(
      candidateLocation: candidate.location,
      candidateWillingToRelocate: candidate.willingToRelocate,
      jobLocation: requirements.location,
      remoteAllowed: requirements.remoteAllowed,
    );

    if (requirements.remoteAllowed) {
      notes.add('Remote work available');
    }

    // 4. Calculate job type score
    final jobTypeScore = _calculateJobTypeScore(
      candidateJobType: candidate.jobType,
      requiredJobType: requirements.jobType,
    );

    // 5. Calculate weighted overall score
    final overallScore = (skillScore * weights.skillWeight) +
        (gpaScore * weights.gpaWeight) +
        (locationScore * weights.locationWeight) +
        (jobTypeScore * weights.jobTypeWeight);

    // 6. Build immutable result
    return MatchScore(
      overallScore: _clamp(overallScore, 0.0, 100.0),
      breakdown: ScoreBreakdown(
        skillScore: skillScore,
        gpaScore: gpaScore,
        locationScore: locationScore,
        jobTypeScore: jobTypeScore,
        matchingSkillsCount: matchingCount,
        totalRequiredSkills: requirements.requiredSkills.length,
      ),
      metadata: ScoreMetadata(
        calculatedAt: DateTime.now().toUtc(),
        algorithmVersion: algorithmVersion,
        notes: notes,
      ),
    );
  }

  /// Calculate skill matching score (0-100)
  /// Returns (score, matching_count)
  static (double, int) _calculateSkillScore({
    required List<String> candidateSkills,
    required List<String> requiredSkills,
  }) {
    if (requiredSkills.isEmpty) {
      return (100.0, 0); // No requirements = perfect match
    }

    if (candidateSkills.isEmpty) {
      return (0.0, 0); // No skills = no match
    }

    // Normalize skills to lowercase for case-insensitive comparison
    final normalizedCandidateSkills =
        candidateSkills.map((s) => s.toLowerCase().trim()).toSet();
    final normalizedRequiredSkills =
        requiredSkills.map((s) => s.toLowerCase().trim()).toSet();

    // Count matching skills
    final matchingSkills =
        normalizedRequiredSkills.intersection(normalizedCandidateSkills);
    final matchingCount = matchingSkills.length;

    // Calculate percentage match
    final matchPercentage = (matchingCount / requiredSkills.length) * 100.0;

    return (matchPercentage, matchingCount);
  }

  /// Calculate GPA score (0-100)
  static double _calculateGpaScore({
    required double? candidateGpa,
    required double? minimumGpa,
  }) {
    // No GPA requirement = perfect score
    if (minimumGpa == null) {
      return 100.0;
    }

    // No GPA provided = neutral score
    if (candidateGpa == null) {
      return 50.0;
    }

    // GPA below minimum = low score (but not zero)
    if (candidateGpa < minimumGpa) {
      // Scale: 0 GPA = 0 score, minimum GPA = 40 score
      final ratio = candidateGpa / minimumGpa;
      return ratio * 40.0;
    }

    // GPA meets or exceeds minimum
    // Scale: minimum GPA = 40, 4.0 GPA = 100
    final maxGpa = 4.0;
    final excessGpa = candidateGpa - minimumGpa;
    final maxExcess = maxGpa - minimumGpa;

    if (maxExcess <= 0) return 100.0;

    final excessScore = (excessGpa / maxExcess) * 60.0; // 60 points available
    return _clamp(40.0 + excessScore, 0.0, 100.0);
  }

  /// Calculate location compatibility score (0-100)
  static double _calculateLocationScore({
    required String? candidateLocation,
    required bool candidateWillingToRelocate,
    required String? jobLocation,
    required bool remoteAllowed,
  }) {
    // Remote job = perfect match
    if (remoteAllowed) {
      return 100.0;
    }

    // No location specified = neutral
    if (jobLocation == null || candidateLocation == null) {
      return 50.0;
    }

    // Normalize locations for comparison
    final normalizedCandidateLoc = candidateLocation.toLowerCase().trim();
    final normalizedJobLoc = jobLocation.toLowerCase().trim();

    // Exact location match = perfect
    if (normalizedCandidateLoc == normalizedJobLoc) {
      return 100.0;
    }

    // Different location but willing to relocate = good
    if (candidateWillingToRelocate) {
      return 70.0;
    }

    // Different location and not willing to relocate = poor
    return 20.0;
  }

  /// Calculate job type compatibility score (0-100)
  static double _calculateJobTypeScore({
    required String candidateJobType,
    required String requiredJobType,
  }) {
    final normalizedCandidate = candidateJobType.toLowerCase().trim();
    final normalizedRequired = requiredJobType.toLowerCase().trim();

    // Exact match
    if (normalizedCandidate == normalizedRequired) {
      return 100.0;
    }

    // Partial compatibility rules
    // Full-time candidates often accept internships
    if (normalizedCandidate == 'full-time' &&
        normalizedRequired == 'internship') {
      return 80.0;
    }

    // Internship seekers may consider part-time
    if (normalizedCandidate == 'internship' &&
        normalizedRequired == 'part-time') {
      return 70.0;
    }

    // Part-time seekers may consider full-time
    if (normalizedCandidate == 'part-time' &&
        normalizedRequired == 'full-time') {
      return 60.0;
    }

    // Otherwise, moderate mismatch
    return 40.0;
  }

  /// Clamp value between min and max
  static double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
