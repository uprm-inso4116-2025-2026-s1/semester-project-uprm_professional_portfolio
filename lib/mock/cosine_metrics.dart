import 'dart:math';
import 'matches_local_repository.dart';

//Skill vocabulary
final List<String> _skillVocabulary = _buildSkillVocabulary();

List<String> _buildSkillVocabulary() {
  final vocab = <String>{...technical_skills};

  for (final job in jobs) {
    vocab.addAll(List<String>.from(job['skills'] as List));
  }

  for (final js in jobseekers) {
    vocab.addAll(List<String>.from(js['skills'] as List));
  }

  final list = vocab.toList()..sort();
  return list;
}

//Calculate cosine similarity
List<int> _skillsToVector(List<String> skills) {
  return _skillVocabulary
      .map((skill) => skills.contains(skill) ? 1 : 0)
      .toList();
}

double _cosineSimilarity(List<String> skillsA, List<String> skillsB) {
  final vA = _skillsToVector(skillsA);
  final vB = _skillsToVector(skillsB);

  int dot = 0;
  int normA = 0;
  int normB = 0;

  for (var i = 0; i < vA.length; i++) {
    dot += vA[i] * vB[i];
    normA += vA[i] * vA[i];
    normB += vB[i] * vB[i];
  }

  if (normA == 0 || normB == 0) return 0.0;

  return dot / (sqrt(normA) * sqrt(normB));
}

//Generate job matches for job seeker
List<Map<String, dynamic>> getJobMatchesList(String jobseekerId) {
  final js = jobseekers.firstWhere(
        (j) => j['id'] == jobseekerId,
    orElse: () => throw ArgumentError('Jobseeker $jobseekerId not found'),
  );

  final jsSkills = List<String>.from(js['skills'] as List);
  final List<Map<String, dynamic>> results = [];

  for (final job in jobs) {
    final jobSkills = List<String>.from(job['skills'] as List);
    final score = _cosineSimilarity(jsSkills, jobSkills);
    final percent = score * 100.0;

    final entry = Map<String, dynamic>.from(job);
    entry['similarity'] = percent; // percentage 0–100
    results.add(entry);
  }

  // Order by similarity percentage descending
  results.sort((a, b) {
    final sa = (a['similarity'] as double);
    final sb = (b['similarity'] as double);
    return sb.compareTo(sa);
  });

  return results;
}

//Generate job seekers for recruiters
List<Map<String, dynamic>> getCandidateMatchesList(String recruiterId) {
  final recruiter = recruiters.firstWhere(
        (r) => r['id'] == recruiterId,
    orElse: () => throw ArgumentError('Recruiter $recruiterId not found'),
  );

  final jobId = recruiter['job_id'] as String;

  final job = jobs.firstWhere(
        (j) => j['id'] == jobId,
    orElse: () => throw ArgumentError('Job $jobId not found'),
  );

  final jobSkills = List<String>.from(job['skills'] as List);
  final List<Map<String, dynamic>> results = [];

  for (final js in jobseekers) {
    final jsSkills = List<String>.from(js['skills'] as List);
    final score = _cosineSimilarity(jobSkills, jsSkills);
    final percent = score * 100.0;

    final entry = Map<String, dynamic>.from(js);
    entry['similarity'] = percent;
    results.add(entry);
  }

  // Order by similarity percentage descending
  results.sort((a, b) {
    final sa = (a['similarity'] as double);
    final sb = (b['similarity'] as double);
    return sb.compareTo(sa);
  });

  return results;
}


void PrintJobMatches(String jobseekerId) {
  final matches = getJobMatchesList(jobseekerId);
  final js = jobseekers.firstWhere((j) => j['id'] == jobseekerId);
  final jsName = js['name'];

  print("\n--- Job matches for $jsName ($jobseekerId) ---");
  print("[");

  for (final job in matches) {
    final similarityPercent =
    (job['similarity'] as double).toStringAsFixed(2);
    print(
      "  { 'id': '${job['id']}', 'title': '${job['title']}', 'similarity': ${similarityPercent}% },",
    );
  }

  print("]");
}

void PrintCandidateMatches(String recruiterId) {
  final matches = getCandidateMatchesList(recruiterId);
  final recruiter = recruiters.firstWhere((r) => r['id'] == recruiterId);
  final recruiterName = recruiter['name'];

  print("\n--- Candidate matches for $recruiterName ($recruiterId) ---");
  print("[");
  for (final js in matches) {
    final similarityPercent =
    (js['similarity'] as double).toStringAsFixed(2);
    print(
      "  { 'id': '${js['id']}', 'name': '${js['name']}', 'similarity': ${similarityPercent}% },",
    );
  }
  print("]");
}


void PrintAllJobseekerMatches() {
  print("\n========= JOB MATCHES FOR ALL JOBSEEKERS =========\n");

  for (final js in jobseekers) {
    final jsId = js['id'] as String;
    PrintJobMatches(jsId);
  }
}

void PrintAllRecruiterMatches() {
  print("\n========= CANDIDATE MATCHES FOR ALL RECRUITERS =========\n");

  for (final r in recruiters) {
    final recruiterId = r['id'] as String;
    PrintCandidateMatches(recruiterId);
  }
}

//Local testing
void main() {
  PrintAllJobseekerMatches();
  PrintAllRecruiterMatches();
}
