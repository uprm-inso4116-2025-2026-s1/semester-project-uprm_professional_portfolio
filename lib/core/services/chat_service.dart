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
    this.isEdited = false,
    this.isDeleted = false,
    this.updatedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timeStamp;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? updatedAt;

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

  /// Edits a message's text.
  bool editMessage(String messageId, String newBody) {
    for (final conversation in _conversations.values) {
      final message = conversation.messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => ChatMessage(
          id: '',
          conversationId: '',
          senderId: '',
          text: '',
          timeStamp: DateTime.now(),
        ),
      );
      if (message.id == messageId) {
        final index = conversation.messages.indexOf(message);
        conversation.messages[index] = ChatMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          text: newBody,
          timeStamp: message.timeStamp,
          attachmentUrl: message.attachmentUrl,
          attachmentType: message.attachmentType,
          isEdited: true,
          isDeleted: message.isDeleted,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Soft-deletes a message.
  bool deleteMessage(String messageId) {
    for (final conversation in _conversations.values) {
      final message = conversation.messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => ChatMessage(
          id: '',
          conversationId: '',
          senderId: '',
          text: '',
          timeStamp: DateTime.now(),
        ),
      );
      if (message.id == messageId) {
        final index = conversation.messages.indexOf(message);
        conversation.messages[index] = ChatMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          text: 'Message deleted',
          timeStamp: message.timeStamp,
          attachmentUrl: message.attachmentUrl,
          attachmentType: message.attachmentType,
          isEdited: message.isEdited,
          isDeleted: true,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Clears all conversations.
  void reset() {
    _conversations.clear();
    notifyListeners();
  }
}

/// Represents a reaction to a message
class MessageReaction {
  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  factory MessageReaction.fromRow(Map<String, dynamic> r) => MessageReaction(
        id: r['id'] as String,
        messageId: r['message_id'] as String,
        userId: r['user_id'] as String,
        emoji: r['emoji'] as String,
        createdAt: DateTime.parse(r['created_at'] as String).toUtc(),
      );
}
