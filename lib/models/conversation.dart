// lib/models/conversation.dart
import 'dart:convert';

/// Minimal Message model (self-contained for this test file)
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
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        receiverId: json['receiverId'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  String toString() =>
      'Message(id: $id, from: $senderId, to: $receiverId, text: "$text", ts: $timestamp)';
}

/// Conversation model with participants and messages
class Conversation {
  final String id;
  final List<String> participants;
  final List<Message> _messages = [];

  Conversation({
    required this.id,
    required this.participants,
    List<Message>? messages,
  }) {
    if (messages != null) _messages.addAll(messages);
  }

  /// Read-only view of messages (in insertion order)
  List<Message> get messages => List.unmodifiable(_messages);

  /// Add a message
  void addMessage(Message message) => _messages.add(message);

  /// Remove by message id; returns true if removed
  bool removeMessage(String messageId) {
    final before = _messages.length;
    _messages.removeWhere((m) => m.id == messageId);
    return _messages.length < before;
  }

  /// Print all messages in current order
  void printMessages() {
    for (final m in _messages) {
      print(m);
    }
  }

  @override
  String toString() =>
      'Conversation(id: $id, participants: $participants, messages: ${_messages.length})';
}

/// --- Self-test: run this file directly ---
void main() {
  final participants = ['user123', 'user999'];
  final convo = Conversation(id: 'convo001', participants: participants);

  // Create sample messages (slightly out of time order is fine)
  final msg1 = Message(
    id: 'm1',
    senderId: 'user123',
    receiverId: 'user999',
    text: 'Hey! Are you available to collaborate?',
    timestamp: DateTime.parse('2025-10-19T12:00:00Z'),
  );

  final msg2 = Message(
    id: 'm2',
    senderId: 'user999',
    receiverId: 'user123',
    text: 'Yes! Let’s chat later today.',
    timestamp: DateTime.parse('2025-10-19T12:05:00Z'),
  );

  final msg3 = Message(
    id: 'm3',
    senderId: 'user123',
    receiverId: 'user999',
    text: 'Great—sending my portfolio link.',
    timestamp: DateTime.parse('2025-10-19T12:03:00Z'),
  );

  // Add messages
  convo.addMessage(msg1);
  convo.addMessage(msg2);
  convo.addMessage(msg3);

  print('Conversation summary: $convo');

  print('\n--- Messages (in insertion order) ---');
  convo.printMessages();

  // Remove one
  final removed = convo.removeMessage('m2');
  print('\nRemoved m2? $removed');

  print('\n--- After removal ---');
  convo.printMessages();

  // Quick JSON round-trip on a message
  final jsonStr = jsonEncode(msg1.toJson());
  final recreated =
      Message.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  print('\nJSON round-trip check (msg1): $recreated');
}
