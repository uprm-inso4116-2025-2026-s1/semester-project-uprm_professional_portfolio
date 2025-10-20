// Mock data for testing chat functionality without backend dependency


/// Represents a chat message
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromCurrentUser,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isFromCurrentUser,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_from_current_user': isFromCurrentUser,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromCurrentUser: json['is_from_current_user'] as bool,
    );
  }
}

/// Represents a conversation between users
class Conversation {
  final String id;
  final String title;
  final List<String> participantIds;
  final List<String> participantNames;
  final String? lastMessageContent;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.participantNames,
    this.lastMessageContent,
    this.lastMessageTimestamp,
    this.unreadCount = 0,
    required this.createdAt,
  });

  Conversation copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    List<String>? participantNames,
    String? lastMessageContent,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'last_message_content': lastMessageContent,
      'last_message_timestamp': lastMessageTimestamp?.toIso8601String(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      participantIds: List<String>.from(json['participant_ids'] as List),
      participantNames: List<String>.from(json['participant_names'] as List),
      lastMessageContent: json['last_message_content'] as String?,
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'] as String)
          : null,
      unreadCount: (json['unread_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Mock data for testing purposes
class MockData {
  static const String currentUserId = 'user_001';
  static const String currentUserName = 'John Doe';

  /// Mock messages for testing
  static final List<Message> mockMessages = [
    Message(
      id: 'msg_001',
      conversationId: 'conv_001',
      senderId: 'user_002',
      senderName: 'Sarah Johnson',
      content: 'Hi! I saw your profile and I think you\'d be a great fit for our Software Engineer position at TechCorp.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isFromCurrentUser: false,
    ),
    Message(
      id: 'msg_002',
      conversationId: 'conv_001',
      senderId: currentUserId,
      senderName: currentUserName,
      content: 'Thank you for reaching out! I\'d love to learn more about the position. Could you tell me more about the tech stack?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isFromCurrentUser: true,
    ),
    Message(
      id: 'msg_003',
      conversationId: 'conv_001',
      senderId: 'user_002',
      senderName: 'Sarah Johnson',
      content: 'Of course! We primarily work with Flutter, Node.js, and PostgreSQL. The role involves building mobile applications and APIs.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isFromCurrentUser: false,
    ),
    Message(
      id: 'msg_004',
      conversationId: 'conv_001',
      senderId: currentUserId,
      senderName: currentUserName,
      content: 'That sounds perfect! I have extensive experience with Flutter and have worked with Node.js on several projects.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      isFromCurrentUser: true,
    ),
    Message(
      id: 'msg_005',
      conversationId: 'conv_002',
      senderId: 'user_003',
      senderName: 'Mike Chen',
      content: 'Hello! We have an exciting Full-Stack Developer opportunity at StartupXYZ. Are you open to new opportunities?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isFromCurrentUser: false,
    ),
    Message(
      id: 'msg_006',
      conversationId: 'conv_002',
      senderId: currentUserId,
      senderName: currentUserName,
      content: 'Hi Mike! Yes, I\'m definitely interested in exploring new opportunities. What can you tell me about the role?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isFromCurrentUser: true,
    ),
    Message(
      id: 'msg_007',
      conversationId: 'conv_003',
      senderId: currentUserId,
      senderName: currentUserName,
      content: 'Hi Emily! I noticed your company is hiring for a Senior Developer position. I\'d love to discuss my qualifications.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isFromCurrentUser: true,
    ),
    Message(
      id: 'msg_008',
      conversationId: 'conv_003',
      senderId: 'user_004',
      senderName: 'Emily Rodriguez',
      content: 'Thank you for your interest! I\'d be happy to discuss the position with you. When would be a good time for a call?',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isFromCurrentUser: false,
    ),
  ];

  /// Mock conversations for testing
  static final List<Conversation> mockConversations = [
    Conversation(
      id: 'conv_001',
      title: 'TechCorp - Software Engineer',
      participantIds: [currentUserId, 'user_002'],
      participantNames: [currentUserName, 'Sarah Johnson'],
      lastMessageContent: 'That sounds perfect! I have extensive experience with Flutter and have worked with Node.js on several projects.',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      unreadCount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Conversation(
      id: 'conv_002',
      title: 'StartupXYZ - Full-Stack Developer',
      participantIds: [currentUserId, 'user_003'],
      participantNames: [currentUserName, 'Mike Chen'],
      lastMessageContent: 'Hi Mike! Yes, I\'m definitely interested in exploring new opportunities. What can you tell me about the role?',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      unreadCount: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Conversation(
      id: 'conv_003',
      title: 'InnovateLabs - Senior Developer',
      participantIds: [currentUserId, 'user_004'],
      participantNames: [currentUserName, 'Emily Rodriguez'],
      lastMessageContent: 'Thank you for your interest! I\'d be happy to discuss the position with you. When would be a good time for a call?',
      lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      unreadCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Get messages for a specific conversation
  static List<Message> getMessagesForConversation(String conversationId) {
    return mockMessages.where((message) => message.conversationId == conversationId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get a conversation by ID
  static Conversation? getConversationById(String conversationId) {
    try {
      return mockConversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  /// Get all conversations sorted by last message timestamp
  static List<Conversation> getAllConversations() {
    final conversations = List<Conversation>.from(mockConversations);
    conversations.sort((a, b) {
      final aTime = a.lastMessageTimestamp ?? a.createdAt;
      final bTime = b.lastMessageTimestamp ?? b.createdAt;
      return bTime.compareTo(aTime); // Most recent first
    });
    return conversations;
  }

  /// Add a new message to mock data (for testing purposes)
  static void addMessage(Message message) {
    mockMessages.add(message);
    
    // Update conversation's last message
    final conversationIndex = mockConversations.indexWhere(
      (conv) => conv.id == message.conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = mockConversations[conversationIndex];
      mockConversations[conversationIndex] = conversation.copyWith(
        lastMessageContent: message.content,
        lastMessageTimestamp: message.timestamp,
        unreadCount: message.isFromCurrentUser ? conversation.unreadCount : conversation.unreadCount + 1,
      );
    }
  }

  /// Mark conversation as read (reset unread count)
  static void markConversationAsRead(String conversationId) {
    final conversationIndex = mockConversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = mockConversations[conversationIndex];
      mockConversations[conversationIndex] = conversation.copyWith(unreadCount: 0);
    }
  }

  // Clear all mock data (useful for testing)
  static void clearMockData() {
    mockMessages.clear();
    mockConversations.clear();
  }

  // Reset mock data to initial state
  static void resetMockData() {
    clearMockData();
    
    // Restore all initial messages
    mockMessages.addAll([
      Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_002',
        senderName: 'Sarah Johnson',
        content: 'Hi! I saw your profile and I think you\'d be a great fit for our Software Engineer position at TechCorp.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFromCurrentUser: false,
      ),
      Message(
        id: 'msg_002',
        conversationId: 'conv_001',
        senderId: currentUserId,
        senderName: currentUserName,
        content: 'Thank you for reaching out! I\'d love to learn more about the position. Could you tell me more about the tech stack?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isFromCurrentUser: true,
      ),
      Message(
        id: 'msg_003',
        conversationId: 'conv_001',
        senderId: 'user_002',
        senderName: 'Sarah Johnson',
        content: 'Of course! We primarily work with Flutter, Node.js, and PostgreSQL. The role involves building mobile applications and APIs.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isFromCurrentUser: false,
      ),
      Message(
        id: 'msg_004',
        conversationId: 'conv_001',
        senderId: currentUserId,
        senderName: currentUserName,
        content: 'That sounds perfect! I have extensive experience with Flutter and have worked with Node.js on several projects.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        isFromCurrentUser: true,
      ),
      Message(
        id: 'msg_005',
        conversationId: 'conv_002',
        senderId: 'user_003',
        senderName: 'Mike Chen',
        content: 'Hello! We have an exciting Full-Stack Developer opportunity at StartupXYZ. Are you open to new opportunities?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isFromCurrentUser: false,
      ),
      Message(
        id: 'msg_006',
        conversationId: 'conv_002',
        senderId: currentUserId,
        senderName: currentUserName,
        content: 'Hi Mike! Yes, I\'m definitely interested in exploring new opportunities. What can you tell me about the role?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isFromCurrentUser: true,
      ),
      Message(
        id: 'msg_007',
        conversationId: 'conv_003',
        senderId: currentUserId,
        senderName: currentUserName,
        content: 'Hi Emily! I noticed your company is hiring for a Senior Developer position. I\'d love to discuss my qualifications.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        isFromCurrentUser: true,
      ),
      Message(
        id: 'msg_008',
        conversationId: 'conv_003',
        senderId: 'user_004',
        senderName: 'Emily Rodriguez',
        content: 'Thank you for your interest! I\'d be happy to discuss the position with you. When would be a good time for a call?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isFromCurrentUser: false,
      ),
    ]);
    
    // Restore all initial conversations
    mockConversations.addAll([
      Conversation(
        id: 'conv_001',
        title: 'TechCorp - Software Engineer',
        participantIds: [currentUserId, 'user_002'],
        participantNames: [currentUserName, 'Sarah Johnson'],
        lastMessageContent: 'That sounds perfect! I have extensive experience with Flutter and have worked with Node.js on several projects.',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Conversation(
        id: 'conv_002',
        title: 'StartupXYZ - Full-Stack Developer',
        participantIds: [currentUserId, 'user_003'],
        participantNames: [currentUserName, 'Mike Chen'],
        lastMessageContent: 'Hi Mike! Yes, I\'m definitely interested in exploring new opportunities. What can you tell me about the role?',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Conversation(
        id: 'conv_003',
        title: 'InnovateLabs - Senior Developer',
        participantIds: [currentUserId, 'user_004'],
        participantNames: [currentUserName, 'Emily Rodriguez'],
        lastMessageContent: 'Thank you for your interest! I\'d be happy to discuss the position with you. When would be a good time for a call?',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }
}