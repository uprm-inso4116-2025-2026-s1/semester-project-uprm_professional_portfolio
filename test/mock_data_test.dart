import 'package:flutter_test/flutter_test.dart';
import '../lib/mock/mock_data.dart';

void main() {
  group('MockData Tests', () {
    setUp(() {
      // Reset mock data before each test to ensure clean state
      MockData.resetMockData();
    });

    test('should have 3 mock conversations', () {
      final conversations = MockData.getAllConversations();
      expect(conversations.length, equals(3));
    });

    test('should have 8 mock messages', () {
      expect(MockData.mockMessages.length, equals(8));
    });

    test('conversations should be sorted by most recent timestamp', () {
      final conversations = MockData.getAllConversations();
      
      // First conversation should be the most recent one
      expect(conversations.first.title, contains('StartupXYZ'));
      expect(conversations.last.title, contains('InnovateLabs'));
    });

    test('should get messages for specific conversation', () {
      final messagesConv1 = MockData.getMessagesForConversation('conv_001');
      final messagesConv2 = MockData.getMessagesForConversation('conv_002');
      
      expect(messagesConv1.length, equals(4));
      expect(messagesConv2.length, equals(2));
      
      // Messages should be sorted by timestamp (oldest first)
      expect(messagesConv1.first.timestamp.isBefore(messagesConv1.last.timestamp), isTrue);
    });

    test('should get conversation by ID', () {
      final conversation = MockData.getConversationById('conv_001');
      
      expect(conversation, isNotNull);
      expect(conversation!.title, equals('TechCorp - Software Engineer'));
      expect(conversation.participantNames, contains('Sarah Johnson'));
    });

    test('should return null for non-existent conversation ID', () {
      final conversation = MockData.getConversationById('non_existent');
      expect(conversation, isNull);
    });

    test('should add new message and update conversation', () {
      final initialMessageCount = MockData.mockMessages.length;
      final conversation = MockData.getConversationById('conv_001')!;
      final initialUnreadCount = conversation.unreadCount;
      
      final newMessage = Message(
        id: 'test_msg',
        conversationId: 'conv_001',
        senderId: 'user_002',
        senderName: 'Sarah Johnson',
        content: 'Test message content',
        timestamp: DateTime.now(),
        isFromCurrentUser: false,
      );
      
      MockData.addMessage(newMessage);
      
      // Should increase message count
      expect(MockData.mockMessages.length, equals(initialMessageCount + 1));
      
      // Should update conversation's last message
      final updatedConversation = MockData.getConversationById('conv_001')!;
      expect(updatedConversation.lastMessageContent, equals('Test message content'));
      expect(updatedConversation.unreadCount, equals(initialUnreadCount + 1));
    });

    test('should mark conversation as read', () {
      final conversation = MockData.getConversationById('conv_002')!;
      expect(conversation.unreadCount, greaterThan(0));
      
      MockData.markConversationAsRead('conv_002');
      
      final updatedConversation = MockData.getConversationById('conv_002')!;
      expect(updatedConversation.unreadCount, equals(0));
    });

    test('Message should have proper JSON serialization', () {
      final message = MockData.mockMessages.first;
      final json = message.toJson();
      final reconstructed = Message.fromJson(json);
      
      expect(reconstructed.id, equals(message.id));
      expect(reconstructed.content, equals(message.content));
      expect(reconstructed.senderName, equals(message.senderName));
      expect(reconstructed.isFromCurrentUser, equals(message.isFromCurrentUser));
    });

    test('Conversation should have proper JSON serialization', () {
      final conversation = MockData.mockConversations.first;
      final json = conversation.toJson();
      final reconstructed = Conversation.fromJson(json);
      
      expect(reconstructed.id, equals(conversation.id));
      expect(reconstructed.title, equals(conversation.title));
      expect(reconstructed.participantIds, equals(conversation.participantIds));
      expect(reconstructed.unreadCount, equals(conversation.unreadCount));
    });

    test('should clear all mock data', () {
      expect(MockData.mockMessages.isNotEmpty, isTrue);
      expect(MockData.mockConversations.isNotEmpty, isTrue);
      
      MockData.clearMockData();
      
      expect(MockData.mockMessages.isEmpty, isTrue);
      expect(MockData.mockConversations.isEmpty, isTrue);
    });

    test('should have correct current user info', () {
      expect(MockData.currentUserId, equals('user_001'));
      expect(MockData.currentUserName, equals('John Doe'));
    });

    test('messages should have realistic timestamps', () {
      final messages = MockData.mockMessages;
      final now = DateTime.now();
      
      for (final message in messages) {
        // All messages should be in the past
        expect(message.timestamp.isBefore(now), isTrue);
        
        // Messages should be within the last few days
        final daysDiff = now.difference(message.timestamp).inDays;
        expect(daysDiff, lessThanOrEqualTo(2));
      }
    });
  });
}