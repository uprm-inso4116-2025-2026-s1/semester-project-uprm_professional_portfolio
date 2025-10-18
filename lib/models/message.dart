// lib/models/message.dart

/// Base class representing a single chat message.
/// Database independent (no Firestore/SQL yet).
class Message {
  // === Constructor(s) first (fixes dartsort_constructors_first) ===
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  /// Create a Message instance from a JSON map. (expression body)
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        receiverId: json['receiverId'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  // === Fields ===
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  // === Methods ===

  /// Convert this object into a JSON map. (expression body)
  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'Message(id: $id, from: $senderId, to: $receiverId, text: "$text", ts: $timestamp)';
}
