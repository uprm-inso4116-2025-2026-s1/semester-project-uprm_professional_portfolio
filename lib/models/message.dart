// lib/models/message.dart
import 'dart:convert';

/// Simple Message class + quick self-test in main()
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  @override
  String toString() =>
      'Message(id: $id, from: $senderId, to: $receiverId, text: "$text", ts: $timestamp)';
}

/// --- Program test ---
void main() {
  final msg = Message(
    id: 'msg001',
    senderId: 'user123',
    receiverId: 'user999',
    text: 'Hello from the communications team 🚀',
    timestamp: DateTime.now().toUtc(),
  );

  print('Original Message: $msg');

  final jsonString = jsonEncode(msg.toJson());
  print('\nJSON: $jsonString');

  final recreated =
      Message.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  print('\nRecreated: $recreated');

  print('\nIs data consistent? ${msg.text == recreated.text}');
}
