/// Immutable value object representing a match score between a candidate and a job opening.
///
/// This is a pure domain concept with no side effects. All data is final and
/// the score calculation is deterministic based on input parameters.
class MatchScore {
  /// Overall compatibility score (0-100)
  final double overallScore;

  /// Breakdown of score components
  final ScoreBreakdown breakdown;

  /// Metadata about the calculation
  final ScoreMetadata metadata;

  const MatchScore({
    required this.overallScore,
    required this.breakdown,
    required this.metadata,
  });

  /// Check if this is a strong match (score >= 70)
  bool get isStrongMatch => overallScore >= 70.0;

  /// Check if this is a moderate match (50 <= score < 70)
  bool get isModerateMatch => overallScore >= 50.0 && overallScore < 70.0;

  /// Check if this is a weak match (score < 50)
  bool get isWeakMatch => overallScore < 50.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchScore &&
          runtimeType == other.runtimeType &&
          overallScore == other.overallScore &&
          breakdown == other.breakdown &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      overallScore.hashCode ^ breakdown.hashCode ^ metadata.hashCode;

  @override
  String toString() => 'MatchScore('
      'overall: ${overallScore.toStringAsFixed(1)}, '
      'skills: ${breakdown.skillScore.toStringAsFixed(1)}, '
      'match: ${isStrongMatch ? "Strong" : isModerateMatch ? "Moderate" : "Weak"}'
      ')';

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() => {
        'overall_score': overallScore,
        'breakdown': breakdown.toJson(),
        'metadata': metadata.toJson(),
      };

  /// Create from JSON
  factory MatchScore.fromJson(Map<String, dynamic> json) => MatchScore(
        overallScore: (json['overall_score'] as num).toDouble(),
        breakdown:
            ScoreBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
        metadata:
            ScoreMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      );
}

/// Detailed breakdown of score components
class ScoreBreakdown {
  /// Score from skill matching (0-100)
  final double skillScore;

  /// Score from GPA consideration (0-100)
  final double gpaScore;

  /// Score from location/relocation preferences (0-100)
  final double locationScore;

  /// Score from job type matching (0-100)
  final double jobTypeScore;

  /// Number of matching skills
  final int matchingSkillsCount;

  /// Number of required skills
  final int totalRequiredSkills;

  const ScoreBreakdown({
    required this.skillScore,
    required this.gpaScore,
    required this.locationScore,
    required this.jobTypeScore,
    required this.matchingSkillsCount,
    required this.totalRequiredSkills,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreBreakdown &&
          runtimeType == other.runtimeType &&
          skillScore == other.skillScore &&
          gpaScore == other.gpaScore &&
          locationScore == other.locationScore &&
          jobTypeScore == other.jobTypeScore &&
          matchingSkillsCount == other.matchingSkillsCount &&
          totalRequiredSkills == other.totalRequiredSkills;

  @override
  int get hashCode =>
      skillScore.hashCode ^
      gpaScore.hashCode ^
      locationScore.hashCode ^
      jobTypeScore.hashCode ^
      matchingSkillsCount.hashCode ^
      totalRequiredSkills.hashCode;

  Map<String, dynamic> toJson() => {
        'skill_score': skillScore,
        'gpa_score': gpaScore,
        'location_score': locationScore,
        'job_type_score': jobTypeScore,
        'matching_skills_count': matchingSkillsCount,
        'total_required_skills': totalRequiredSkills,
      };

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) => ScoreBreakdown(
        skillScore: (json['skill_score'] as num).toDouble(),
        gpaScore: (json['gpa_score'] as num).toDouble(),
        locationScore: (json['location_score'] as num).toDouble(),
        jobTypeScore: (json['job_type_score'] as num).toDouble(),
        matchingSkillsCount: json['matching_skills_count'] as int,
        totalRequiredSkills: json['total_required_skills'] as int,
      );
}

/// Metadata about the score calculation
class ScoreMetadata {
  /// When this score was calculated
  final DateTime calculatedAt;

  /// Algorithm version used
  final String algorithmVersion;

  /// Any warnings or notes about the calculation
  final List<String> notes;

  const ScoreMetadata({
    required this.calculatedAt,
    required this.algorithmVersion,
    this.notes = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreMetadata &&
          runtimeType == other.runtimeType &&
          calculatedAt == other.calculatedAt &&
          algorithmVersion == other.algorithmVersion &&
          _listEquals(notes, other.notes);

  @override
  int get hashCode =>
      calculatedAt.hashCode ^ algorithmVersion.hashCode ^ notes.hashCode;

  Map<String, dynamic> toJson() => {
        'calculated_at': calculatedAt.toIso8601String(),
        'algorithm_version': algorithmVersion,
        'notes': notes,
      };

  factory ScoreMetadata.fromJson(Map<String, dynamic> json) => ScoreMetadata(
        calculatedAt: DateTime.parse(json['calculated_at'] as String),
        algorithmVersion: json['algorithm_version'] as String,
        notes: List<String>.from(json['notes'] as List),
      );

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
