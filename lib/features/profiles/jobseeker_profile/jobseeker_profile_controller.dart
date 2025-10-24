import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '/../models/jobseeker_profile.dart';



class JobSeekerProfileController extends ChangeNotifier {
  // ---------- Form ----------
  final formKey = GlobalKey<FormState>();

  // ---------- Text Controllers ----------
  final majorCtrl = TextEditingController();
  final gradYearCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final skillsCtrl = TextEditingController();
  final interestsCtrl = TextEditingController();
  final portfolioUrlCtrl = TextEditingController();
  final linkedinUrlCtrl = TextEditingController();
  final githubUrlCtrl = TextEditingController();

  bool isStudent = true;
  String jobType = 'internship';
  bool willingToRelocate = false;

  // ---------- Resume selection ----------
  PlatformFile? _resumeFile;
  Uint8List? resumeBytes;
  String? resumePath;
  String? resumeName;
  String? resumeUrl; // public URL after upload
  bool uploading = false;


  // Expose a pretty size string for the UI
  String? get resumePrettySize {
    final size = _resumeFile?.size;
    if (size == null) {
      return null;
    }
    final mb = size / (1024 * 1024);
    if (mb >= 1) {
      return '${mb.toStringAsFixed(2)} MB';
    }
    final kb = size / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  // ---------- Validators ----------
  String? requiredField(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? optionalInt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? 'Enter a valid number' : null;
  }

  String? optionalUrl(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final u = Uri.tryParse(v.trim());
    final ok = u != null && (u.scheme == 'http' || u.scheme == 'https') && u.host.isNotEmpty;
    return ok ? null : 'Enter a valid URL (http/https)';
  }

  void setIsStudent(bool v) { isStudent = v; notifyListeners(); }
  void setJobType(String v) { jobType = v; notifyListeners(); }
  void setWillingToRelocate(bool v) { willingToRelocate = v; notifyListeners(); }

  Future<String?> pickResume() async {
    try {
      uploading = true; notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: kIsWeb, // get bytes on web
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        dialogTitle: 'Select your resume',
      );

      uploading = false;

      if (result == null || result.files.isEmpty) {
        notifyListeners();
        return null; // user cancelled
      }

      final file = result.files.single;

      // Enforce ≤ 5 MB
      const maxBytes = 5 * 1024 * 1024;
      if (file.size > maxBytes) {
        notifyListeners();
        return 'Please select a file that is 5 MB or smaller.';
      }

      _resumeFile = file;
      resumeName = file.name;
      resumeBytes = file.bytes;
      resumePath  = file.path;

      notifyListeners();
      return null;
    } catch (e) {
      uploading = false; notifyListeners();
      return 'Could not open the file picker.';
    }
  }

  // ---------- Draft builders ----------
  Map<String, dynamic> toDraftMap() {
    List<String> split(String raw) => raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

    return {
      'major': nullIfEmpty(majorCtrl.text),
      'graduation_year': int.tryParse(gradYearCtrl.text.trim()),
      'bio': nullIfEmpty(bioCtrl.text),
      'location': nullIfEmpty(locationCtrl.text),
      'phone_number': nullIfEmpty(phoneCtrl.text),
      'skills': split(skillsCtrl.text),
      'interests': split(interestsCtrl.text),
      'portfolio_url': nullIfEmpty(portfolioUrlCtrl.text),
      'linkedin_url': nullIfEmpty(linkedinUrlCtrl.text),
      'github_url': nullIfEmpty(githubUrlCtrl.text),
      'is_student': isStudent,
      'job_type': jobType,
      'willing_to_relocate': willingToRelocate,
      'resume_url': resumeUrl
    };
  }

  JobSeekerProfile toModel({required String id, required String userId}) {
    List<String> split(String raw) => raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

    return JobSeekerProfile(
      id: id,
      userId: userId,
      major: nullIfEmpty(majorCtrl.text),
      graduationYear: int.tryParse(gradYearCtrl.text.trim()),
      bio: nullIfEmpty(bioCtrl.text),
      location: nullIfEmpty(locationCtrl.text),
      phoneNumber: nullIfEmpty(phoneCtrl.text),
      skills: split(skillsCtrl.text),
      interests: split(interestsCtrl.text),
      // store the URL you get after uploading in your data layer
      resumeUrl: resumeUrl,
      portfolioUrl: nullIfEmpty(portfolioUrlCtrl.text),
      linkedInUrl: nullIfEmpty(linkedinUrlCtrl.text),
      githubUrl: nullIfEmpty(githubUrlCtrl.text),
      isStudent: isStudent,
      jobType: jobType,
      willingToRelocate: willingToRelocate,
      createdAt: DateTime.now(),
    );
  }

  void loadFromModel(JobSeekerProfile m) {
    majorCtrl.text = m.major ?? '';
    gradYearCtrl.text = m.graduationYear?.toString() ?? '';
    bioCtrl.text = m.bio ?? '';
    locationCtrl.text = m.location ?? '';
    phoneCtrl.text = m.phoneNumber ?? '';
    skillsCtrl.text = m.skills.join(', ');
    interestsCtrl.text = m.interests.join(', ');
    portfolioUrlCtrl.text = m.portfolioUrl ?? '';
    linkedinUrlCtrl.text = m.linkedInUrl ?? '';
    githubUrlCtrl.text = m.githubUrl ?? '';
    isStudent = m.isStudent;
    jobType = m.jobType;
    willingToRelocate = m.willingToRelocate;

    resumeUrl = m.resumeUrl;
    resumeName = null; 
  }
  /// Upload resume to Supabase Storage bucket `resumes` and set public URL.
  Future<String?> uploadResume(SupabaseClient supabase, {required String userId}) async {
  if (_resumeFile == null) return null; // nothing to upload

  try {
    final bucket = supabase.storage.from('resumes');

    final ext = p.extension(_resumeFile!.name);
    final objectPath = 'users/$userId/${DateTime.now().millisecondsSinceEpoch}$ext';

    if (kIsWeb) {
      if (resumeBytes == null) return 'No bytes on web upload.';
      await bucket.uploadBinary(objectPath, resumeBytes!,
          fileOptions: const FileOptions(contentType: 'application/octet-stream', upsert: true));
    } else {
      if (resumePath == null) return 'No file path on device.';
      await bucket.upload(objectPath, resumePath!,
          fileOptions: const FileOptions(contentType: 'application/octet-stream', upsert: true));
    }

    // Make public URL (or use signedUrl if you want private access)
    final publicUrl = bucket.getPublicUrl(objectPath);
    resumeUrl = publicUrl;
    notifyListeners();
    return null;
  } catch (e) {
    return 'Resume upload failed.';
  }
}

/// Upsert profile row into table `jobseeker_profiles`.
Future<String?> saveToSupabase(SupabaseClient supabase, {required String userId}) async {
  try {
    final data = toDraftMap()
      ..addAll({
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      });

    // Upsert on user_id (unique)
    await supabase.from('jobseeker_profiles').upsert(data, onConflict: 'user_id');
    return null;
  } catch (e) {
    return 'Saving profile failed.';
  }
}


  @override
  void dispose() {
    majorCtrl.dispose();
    gradYearCtrl.dispose();
    bioCtrl.dispose();
    locationCtrl.dispose();
    phoneCtrl.dispose();
    skillsCtrl.dispose();
    interestsCtrl.dispose();
    portfolioUrlCtrl.dispose();
    linkedinUrlCtrl.dispose();
    githubUrlCtrl.dispose();
    super.dispose();
  }
}
