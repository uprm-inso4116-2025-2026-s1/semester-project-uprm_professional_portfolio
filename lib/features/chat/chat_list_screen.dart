import 'package:flutter/material.dart';
import 'package:uprm_professional_portfolio/mock/mock_data.dart';
import 'package:uprm_professional_portfolio/features/chat/widgets/message_bubble.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final conversations = MockData.getAllConversations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  conversation.participantNames
                      .where((name) => name != MockData.currentUserName)
                      .first[0],
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                conversation.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                conversation.lastMessageContent ?? 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(conversation.lastMessageTimestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (conversation.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => ChatDetailScreen(
                      conversationId: conversation.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  
  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Message> messages;
  late Conversation? conversation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    messages = MockData.getMessagesForConversation(widget.conversationId);
    conversation = MockData.getConversationById(widget.conversationId);
    // Mark conversation as read
    MockData.markConversationAsRead(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    final otherParticipant = conversation!.participantNames
        .where((name) => name != MockData.currentUserName)
        .first;

    return Scaffold(
      appBar: AppBar(
        title: Text(otherParticipant),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = message.isFromCurrentUser;

    // For demo purposes, mark current user's messages as delivered.
    final status = isCurrentUser ? MessageStatus.delivered : null;

    return MessageBubble(
      text: message.content,
      timestamp: message.timestamp,
      isCurrentUser: isCurrentUser,
      status: status,
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: MockData.currentUserId,
      senderName: MockData.currentUserName,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
    );

    MockData.addMessage(newMessage);
    
    setState(() {
      _loadData();
    });
    
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
