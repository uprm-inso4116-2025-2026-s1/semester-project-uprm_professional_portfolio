// Recruiter Profile model
class RecruiterProfile {
  final String id;
  final String userId;
  final String companyName;
  final String? companyWebsite;
  final String jobTitle;
  final String? bio;
  final String? location;
  final String? phoneNumber;
  final List<String> industries;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecruiterProfile({
    required this.id,
    required this.userId,
    required this.companyName,
    this.companyWebsite,
    required this.jobTitle,
    this.bio,
    this.location,
    this.phoneNumber,
    this.industries = const [],
    required this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String,
      companyWebsite: json['company_website'] as String?,
      jobTitle: json['job_title'] as String,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phone_number'] as String?,
      industries:
          List<String>.from((json['industries'] as List<dynamic>?) ?? []),
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
      'company_name': companyName,
      'company_website': companyWebsite,
      'job_title': jobTitle,
      'bio': bio,
      'location': location,
      'phone_number': phoneNumber,
      'industries': industries,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with
  RecruiterProfile copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? companyWebsite,
    String? jobTitle,
    String? bio,
    String? location,
    String? phoneNumber,
    List<String>? industries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecruiterProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      jobTitle: jobTitle ?? this.jobTitle,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      industries: industries ?? this.industries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
