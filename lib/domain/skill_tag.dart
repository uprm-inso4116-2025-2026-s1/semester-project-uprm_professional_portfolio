/// Standalone value object for representing skills
/// No dependencies on Profile or other aggregates
class SkillTag {
  final String name;
  final SkillCategory category;

  const SkillTag._({
    required this.name,
    required this.category,
  });

  /// Factory constructor with validation
  factory SkillTag.create({
    required String name,
    SkillCategory category = SkillCategory.other,
  }) {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw SkillTagValidationException('Skill name cannot be empty');
    }

    if (normalizedName.length < 2) {
      throw SkillTagValidationException(
        'Skill name must be at least 2 characters. Got: "$normalizedName"',
      );
    }

    if (normalizedName.length > 50) {
      throw SkillTagValidationException(
        'Skill name cannot exceed 50 characters. Got ${normalizedName.length}',
      );
    }

    // Supports skill names like C++, C#, Node.js
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\+\-\.#]+$');
    if (!validPattern.hasMatch(normalizedName)) {
      throw SkillTagValidationException(
        'Skill name contains invalid characters. Allowed: letters, numbers, spaces, +, -, ., #',
      );
    }

    return SkillTag._(
      name: normalizedName,
      category: category,
    );
  }

  factory SkillTag.fromString(String name) {
    return SkillTag.create(name: name);
  }

  /// Case-insensitive matching
  bool matches(SkillTag other) {
    return name.toLowerCase() == other.name.toLowerCase();
  }

  /// Check if skill matches a search query
  bool matchesQuery(String query) {
    return name.toLowerCase().contains(query.toLowerCase().trim());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Case-insensitive equality
    return other is SkillTag && 
           name.toLowerCase() == other.name.toLowerCase();
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;

  @override
  String toString() => 'SkillTag($name, $category)';

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.name,
      };

  factory SkillTag.fromJson(Map<String, dynamic> json) {
    return SkillTag.create(
      name: json['name'] as String,
      category: SkillCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => SkillCategory.other,
      ),
    );
  }
}

/// Categories for classifying skills
enum SkillCategory {
  technical,  // Programming languages, frameworks, tools
  soft,       // Communication, leadership, teamwork
  language,   // Spoken/written languages
  domain,     // Industry-specific knowledge
  other,
}

class SkillTagValidationException implements Exception {
  final String message;

  const SkillTagValidationException(this.message);

  @override
  String toString() => 'SkillTagValidationException: $message';
}
