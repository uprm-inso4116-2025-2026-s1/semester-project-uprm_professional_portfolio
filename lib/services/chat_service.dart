import 'package:flutter/foundation.dart';

//This is the Class for the chat message along with a method for the chat message.
class ChatMessage {
  ChatMessage(
      {required this.id,
      required this.conversationId,
      required this.senderId,
      required this.text,
      required this.timeStamp});

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timeStamp;
}

//This is the class for chat conversation. This represents a local chat conversation.
class ChatConversation {
  ChatConversation({
    required this.id,
    List<ChatMessage>?
        messages, // This part is so the message chat can be null=empty or with messages on it.
  }) : messages = messages ??
            []; // This part initialize the list of messages to empty if its not filled with anything.

  final String id;
  final List<ChatMessage> messages;
}

//The chat is used in memory (no persistence)
class ChatService extends ChangeNotifier {
  final Map<String, ChatConversation> _conversations =
      {}; //_conversations is the internal storage/the in-memory.

  ChatMessage sendMessage({
    //This allows to send a message in a conversation, if theres no conversation it will be created automatically.
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

  List<ChatMessage> getMessages(String conversationId) {
    //This allows to get the messages as in for history.
    return _conversations[conversationId]?.messages ?? [];
  }

  List<ChatConversation> getConversations() {
    //This allows to get all conversations as in for history.
    return _conversations.values.toList();
  }

  void reset() {
    //This allows to reset the conversation
    _conversations.clear();
    notifyListeners();
  }
}
