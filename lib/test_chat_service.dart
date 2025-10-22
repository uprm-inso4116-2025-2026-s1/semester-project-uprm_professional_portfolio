import 'services/chat_service.dart';

void main() {
  final chat = ChatService();

  print('--- Testing ChatService ---');

  //Send messages in two conversations.
  chat.sendMessage(
    conversationId: 'conversation1',
    senderId: 'user1',
    text: 'Hello from user1!',
  );

  chat.sendMessage(
    conversationId: 'conversation1',
    senderId: 'user2',
    text: 'Hey user1, this is user2!',
  );

  chat.sendMessage(
    conversationId: 'conversation2',
    senderId: 'user3',
    text: 'This is a separate conversation.',
  );

  // Receive messages from first conversation.
  print('\nMessages in conversation1:');
  final conv1Messages = chat.getMessages('conversation1');
  for (var msg in conv1Messages) {
    print('[${msg.senderId}] ${msg.text}');
  }

  // Receive messages from second conversation.
  print('\nMessages in conversation2:');
  final conv2Messages = chat.getMessages('conversation2');
  for (var msg in conv2Messages) {
    print('[${msg.senderId}] ${msg.text}');
  }

  //Recieve all conversations.
  print('\nAll conversations:');
  final allConversations = chat.getConversations();
  for (var conv in allConversations) {
    print('Conversation ID: ${conv.id}, messages: ${conv.messages.length}');
  }

  // Capture total BEFORE reset
  final totalConversationsBeforeReset = chat.getConversations().length;
  print('\nTotal conversations BEFORE reset: $totalConversationsBeforeReset');

  //Reset all conversations.
  chat.reset();
  print('\nAFTER reset:');
  print(
      'Messages in conversation1: ${chat.getMessages('conversation1').length}');
  print(
      'Messages in conversation2: ${chat.getMessages('conversation2').length}');
  print('Total conversations: ${chat.getConversations().length}');
}
