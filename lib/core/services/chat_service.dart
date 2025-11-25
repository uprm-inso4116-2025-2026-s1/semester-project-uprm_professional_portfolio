import 'package:flutter/foundation.dart';

/// Represents a single chat message.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timeStamp,
    this.attachmentUrl,
    this.attachmentType,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timeStamp;
  final String? attachmentUrl;
  final String? attachmentType;

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get isImage => attachmentType?.startsWith('image/') ?? false;
}

/// Represents a local chat conversation.
class ChatConversation {
  ChatConversation({
    required this.id,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  final String id;
  final List<ChatMessage> messages;
}

/// In-memory chat service (no persistence).
class ChatService extends ChangeNotifier {
  final Map<String, ChatConversation> _conversations = {};

  /// Sends a message in a conversation, creating the conversation if necessary.
  ChatMessage sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) {
    final conversation = _conversations.putIfAbsent(
      conversationId,
      () => ChatConversation(id: conversationId),
    );

    final message = ChatMessage(
      id: UniqueKey().toString(),
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      timeStamp: DateTime.now(),
    );

    conversation.messages.add(message);
    notifyListeners();
    return message;
  }

  /// Returns all messages for a given conversation. → expression body
  List<ChatMessage> getMessages(String conversationId) =>
      _conversations[conversationId]?.messages ?? [];

  /// Returns all existing conversations. → expression body
  List<ChatConversation> getConversations() => _conversations.values.toList();

  /// Clears all conversations.
  void reset() {
    _conversations.clear();
    notifyListeners();
  }
}
