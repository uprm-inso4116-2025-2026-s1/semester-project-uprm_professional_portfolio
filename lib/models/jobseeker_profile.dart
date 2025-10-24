// JobSeeker Profile model
class JobSeekerProfile {
  final String id;
  final String userId;
  final String? major;
  final int? graduationYear;
  final String? bio;
  final String? location;
  final String? phoneNumber;
  final List<String> skills;
  final List<String> interests;
  final String? resumeUrl;
  final String? portfolioUrl;
  final String? linkedInUrl;
  final String? githubUrl;
  final bool isStudent;
  final String jobType; // 'internship', 'full-time', 'part-time'
  final bool willingToRelocate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobSeekerProfile({
    required this.id,
    required this.userId,
    this.major,
    this.graduationYear,
    this.bio,
    this.location,
    this.phoneNumber,
    this.skills = const [],
    this.interests = const [],
    this.resumeUrl,
    this.portfolioUrl,
    this.linkedInUrl,
    this.githubUrl,
    this.isStudent = true,
    this.jobType = 'internship',
    this.willingToRelocate = false,
    required this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    return JobSeekerProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      major: json['major'] as String?,
      graduationYear: json['graduation_year'] as int?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phone_number'] as String?,
      skills: List<String>.from((json['skills'] as List<dynamic>?) ?? []),
      interests: List<String>.from((json['interests'] as List<dynamic>?) ?? []),
      resumeUrl: json['resume_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      linkedInUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      isStudent: (json['is_student'] as bool?) ?? true,
      jobType: (json['job_type'] as String?) ?? 'internship',
      willingToRelocate: (json['willing_to_relocate'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  } // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'major': major,
      'graduation_year': graduationYear,
      'bio': bio,
      'location': location,
      'phone_number': phoneNumber,
      'skills': skills,
      'interests': interests,
      'resume_url': resumeUrl,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedInUrl,
      'github_url': githubUrl,
      'is_student': isStudent,
      'job_type': jobType,
      'willing_to_relocate': willingToRelocate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with
  JobSeekerProfile copyWith({
    String? id,
    String? userId,
    String? major,
    int? graduationYear,
    String? bio,
    String? location,
    String? phoneNumber,
    List<String>? skills,
    List<String>? interests,
    String? resumeUrl,
    String? portfolioUrl,
    String? linkedInUrl,
    String? githubUrl,
    bool? isStudent,
    String? jobType,
    bool? willingToRelocate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobSeekerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      isStudent: isStudent ?? this.isStudent,
      jobType: jobType ?? this.jobType,
      willingToRelocate: willingToRelocate ?? this.willingToRelocate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
