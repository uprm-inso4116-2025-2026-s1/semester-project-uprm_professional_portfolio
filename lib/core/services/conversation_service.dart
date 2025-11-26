import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/conversation_list_item.dart';

/// Service for fetching conversations with RLS enforcement
class ConversationService {
  ConversationService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetch all conversations for the logged-in user
  /// Returns list of conversations with participant info and last message
  Future<List<ConversationListItem>> fetchUserConversations() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      // First, get all conversation IDs where the current user is a participant
      final userConversationsResponse = await _client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', user.id);

      final userConvIds = (userConversationsResponse as List<dynamic>)
          .map((item) => item['conversation_id'] as String)
          .toList();

      if (userConvIds.isEmpty) {
        return [];
      }

      final List<ConversationListItem> items = [];

      // Process each conversation individually
      for (final convId in userConvIds) {
        try {
          // Get conversation details
          final convResponse = await _client
              .from('conversations')
              .select('id, created_at, updated_at')
              .eq('id', convId)
              .single();

          // Get ALL participants for this conversation (RLS will only show user's own record)
          // So we need to query without the user filter to get the other participant
          final allParticipantsResponse = await _client.rpc(
            'get_conversation_participants',
            params: {'conv_id': convId},
          );

          // If RPC doesn't exist, fall back to direct query
          List<String> participantIds = [];
          if (allParticipantsResponse == null) {
            // Fallback: query conversation_participants table directly
            final participantsResponse = await _client
                .from('conversation_participants')
                .select('user_id')
                .eq('conversation_id', convId);
            
            participantIds = (participantsResponse as List<dynamic>)
                .map((p) => p['user_id'] as String)
                .toList();
          } else {
            participantIds = (allParticipantsResponse as List<dynamic>)
                .map((p) => p['user_id'] as String)
                .toList();
          }

          // Find the other user
          final otherUserId = participantIds.firstWhere(
            (id) => id != user.id,
            orElse: () => '',
          );

          if (otherUserId.isEmpty) {
            continue;
          }

          // Get other user details using RPC to bypass RLS
          final otherUserResponse = await _client.rpc(
            'get_user_details',
            params: {'user_ids': [otherUserId]},
          );

          if (otherUserResponse == null || (otherUserResponse as List).isEmpty) {
            // Fallback to direct query
            final fallbackResponse = await _client
                .from('users')
                .select('id, full_name, email, avatar_url')
                .eq('id', otherUserId)
                .maybeSingle();
            
            if (fallbackResponse == null) {
              continue;
            }

            final participantName = fallbackResponse['full_name'] as String? ?? 'Unknown User';
            final participantEmail = fallbackResponse['email'] as String? ?? '';

            // Get last message
            final messagesResponse = await _client
                .from('messages')
                .select('id, body, created_at')
                .eq('conversation_id', convId)
                .order('created_at', ascending: false)
                .limit(1);

            String? lastMessage;
            DateTime? lastMessageTimestamp;

            if (messagesResponse is List && messagesResponse.isNotEmpty) {
              final lastMsg = messagesResponse.first;
              lastMessage = lastMsg['body'] as String?;
              lastMessageTimestamp = DateTime.parse(lastMsg['created_at'] as String);
            }

            items.add(ConversationListItem(
              id: convId,
              participantId: otherUserId,
              participantName: participantName,
              participantEmail: participantEmail,
              lastMessage: lastMessage,
              lastMessageTimestamp: lastMessageTimestamp,
              unreadCount: 0,
            ));
            continue;
          }

          final userDetails = (otherUserResponse as List).first;
          final participantName = userDetails['full_name'] as String? ?? 'Unknown User';
          final participantEmail = userDetails['email'] as String? ?? '';

          // Get last message
          final messagesResponse = await _client
              .from('messages')
              .select('id, body, created_at')
              .eq('conversation_id', convId)
              .order('created_at', ascending: false)
              .limit(1);

          String? lastMessage;
          DateTime? lastMessageTimestamp;

          if (messagesResponse is List && messagesResponse.isNotEmpty) {
            final lastMsg = messagesResponse.first;
            lastMessage = lastMsg['body'] as String?;
            lastMessageTimestamp = DateTime.parse(lastMsg['created_at'] as String);
          }

          items.add(ConversationListItem(
            id: convId,
            participantId: otherUserId,
            participantName: participantName,
            participantEmail: participantEmail,
            lastMessage: lastMessage,
            lastMessageTimestamp: lastMessageTimestamp,
            unreadCount: 0,
          ));
        } catch (e) {
          continue;
        }
      }

      return items;
    } on PostgrestException catch (e, st) {
      return [];
    } on Exception catch (e, st) {
      return [];
    }
  }

  /// Create a new conversation between current user and another user
  /// Returns the conversation ID
  Future<String?> createConversation(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    if (otherUserId.trim().isEmpty) {
      return null;
    }

    try {
      // Check if conversation already exists between these two users
      final existing = await _client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', user.id);

      final List<dynamic> userConversations = existing as List<dynamic>;
      
      for (final conv in userConversations) {
        final convId = conv['conversation_id'] as String;
        
        // Check if other user is also in this conversation
        final otherParticipant = await _client
            .from('conversation_participants')
            .select('user_id')
            .eq('conversation_id', convId)
            .eq('user_id', otherUserId)
            .maybeSingle();

        if (otherParticipant != null) {
          return convId;
        }
      }

      // Create new conversation
      final convResponse = await _client
          .from('conversations')
          .insert({})
          .select('id')
          .single();

      final conversationId = convResponse['id'] as String;

      // Add both participants
      await _client.from('conversation_participants').insert([
        {
          'conversation_id': conversationId,
          'user_id': user.id,
          'role': 'member',
        },
        {
          'conversation_id': conversationId,
          'user_id': otherUserId,
          'role': 'member',
        },
      ]);

      return conversationId;
    } on PostgrestException catch (e, st) {
      return null;
    } on Exception catch (e, st) {
      return null;
    }
  }

  /// Get conversation ID for a match (if exists)
  Future<String?> getConversationForMatch(String matchId) async {
    try {
      final response = await _client
          .from('conversations')
          .select('id')
          .eq('match_id', matchId)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      return null;
    }
  }
}
