import 'address.dart';

class StudentProfile {
  final String id;            // UUID (pk)
  final String userId;        // FK -> users.id
  final DateTime? createdAt;
  final Address? address;     // <-- embeds the VO

  const StudentProfile({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.address,
  });
}
