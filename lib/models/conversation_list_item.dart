/// Model representing a conversation item in the conversations list
class ConversationListItem {
  const ConversationListItem({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantEmail,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.unreadCount = 0,
  });

  final String id;
  final String participantId;
  final String participantName;
  final String participantEmail;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;

  factory ConversationListItem.fromJson(Map<String, dynamic> json) {
    return ConversationListItem(
      id: json['id'] as String,
      participantId: json['participant_id'] as String,
      participantName: json['participant_name'] as String? ?? 'Unknown User',
      participantEmail: json['participant_email'] as String? ?? '',
      lastMessage: json['last_message'] as String?,
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant_id': participantId,
        'participant_name': participantName,
        'participant_email': participantEmail,
        'last_message': lastMessage,
        'last_message_timestamp': lastMessageTimestamp?.toIso8601String(),
        'unread_count': unreadCount,
      };

  @override
  String toString() =>
      'ConversationListItem(id: $id, participant: $participantName, lastMsg: $lastMessage)';
}
