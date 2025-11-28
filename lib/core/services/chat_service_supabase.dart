import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './chat_service.dart'; // ChatMessage, MessageReaction

class ChatServiceSupabase {
  ChatServiceSupabase({
    SupabaseClient? client,
    String tableName = 'messages',
    int maxPageSize = 200,
  })  : _client = client ?? Supabase.instance.client,
        _table = tableName,
        _maxPageSize = maxPageSize;

  final SupabaseClient _client;
  final String _table;
  final int _maxPageSize;

  static const _cols =
      'id, conversation_id, sender_id, body, created_at, deleted_at, attachment_url, attachment_type, is_edited, is_deleted, updated_at';

  /// Get current authenticated user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<ChatMessage>> fetchMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final cid = conversationId.trim();
    if (cid.isEmpty) {
      debugPrint('[chat_service_supabase] fetchMessages: empty conversationId');
      return const <ChatMessage>[];
    }
    final int pageSize = limit.clamp(1, _maxPageSize).toInt();

    try {
      var q = _baseQuery(cid);

      if (before != null) {
        q = q.lt('created_at', before.toUtc().toIso8601String());
      }

      final rowsDynamic =
          await q.order('created_at', ascending: false).limit(pageSize);
      final rows = (rowsDynamic as List).cast<Map<String, dynamic>>();
      return rows.map(_rowToChatMessage).toList();
    } on PostgrestException catch (e, st) {
      debugPrint(
          '[chat_service_supabase] fetchMessages PG error: ${e.message}\n$st');
      return const <ChatMessage>[];
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] fetchMessages error: $e\n$st');
      return const <ChatMessage>[];
    }
  }

  Future<bool> editMessage(
    String messageId,
    String newBody,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('[chat_service_supabase] editMessage: no authenticated user');
      return false;
    }
    final text = newBody.trim();
    if (text.isEmpty) {
      debugPrint('[chat_service_supabase] editMessage: empty body');
      return false;
    }

    try {
      final response = await _client
          .from(_table)
          .update({
            'body': text,
            'is_edited': true,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', user.id)
          .select();

      return response.isNotEmpty;
    } on PostgrestException catch (e, st) {
      debugPrint(
          '[chat_service_supabase] editMessage PG error: ${e.message}\n$st');
      return false;
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] editMessage error: $e\n$st');
      return false;
    }
  }

  Future<bool> deleteMessage(String messageId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint(
          '[chat_service_supabase] deleteMessage: no authenticated user');
      return false;
    }

    try {
      final response = await _client
          .from(_table)
          .update({
            'is_deleted': true,
            'body': 'Message deleted',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', user.id)
          .select();

      return response.isNotEmpty;
    } on PostgrestException catch (e, st) {
      debugPrint(
          '[chat_service_supabase] deleteMessage PG error: ${e.message}\n$st');
      return false;
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] deleteMessage error: $e\n$st');
      return false;
    }
  }

  Future<ChatMessage?> sendMessage(
    String conversationId,
    String body, {
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('[chat_service_supabase] sendMessage: no authenticated user');
      return null;
    }
    final cid = conversationId.trim();
    if (cid.isEmpty) {
      debugPrint('[chat_service_supabase] sendMessage: empty conversationId');
      return null;
    }
    final text = body.trim();
    if (text.isEmpty && attachmentUrl == null) {
      debugPrint(
          '[chat_service_supabase] sendMessage: empty body and no attachment');
      return null;
    }

    try {
      final payload = <String, dynamic>{
        'conversation_id': cid,
        'sender_id': user.id,
        'body': text,
      };
      if (attachmentUrl != null) {
        payload['attachment_url'] = attachmentUrl;
        payload['attachment_type'] = attachmentType;
      }

      final row = await _client
          .from(_table)
          .insert(payload)
          .select(_cols)
          .single(); // Map<String, dynamic>

      return _rowToChatMessage(row);
    } on PostgrestException catch (e, st) {
      debugPrint(
          '[chat_service_supabase] sendMessage PG error: ${e.message}\n$st');
      return null;
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] sendMessage error: $e\n$st');
      return null;
    }
  }

  // ---------- Helpers ----------
  PostgrestFilterBuilder<List<Map<String, dynamic>>> _baseQuery(
          String conversationId) =>
      _client
          .from(_table)
          .select(_cols)
          .eq('conversation_id', conversationId)
          .isFilter('deleted_at', null);

  ChatMessage _rowToChatMessage(Map<String, dynamic> m) {
    final createdAtRaw = m['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.parse(createdAtRaw).toUtc()
        : (createdAtRaw as DateTime).toUtc();

    DateTime? updatedAt;
    final updatedAtRaw = m['updated_at'];
    if (updatedAtRaw != null) {
      updatedAt = updatedAtRaw is String
          ? DateTime.parse(updatedAtRaw).toUtc()
          : (updatedAtRaw as DateTime).toUtc();
    }

    return ChatMessage(
      id: m['id'] as String,
      conversationId: m['conversation_id'] as String,
      senderId: m['sender_id'] as String,
      text: (m['body'] as String?) ?? '',
      timeStamp: createdAt,
      attachmentUrl: m['attachment_url'] as String?,
      attachmentType: m['attachment_type'] as String?,
      isEdited: (m['is_edited'] as bool?) ?? false,
      isDeleted: (m['is_deleted'] as bool?) ?? false,
      updatedAt: updatedAt,
    );
  }

  // ---------------- Reactions ----------------

  /// Add a reaction for the current user to a message. Idempotent due to unique index.
  Future<bool> addReaction(String messageId, String emoji) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      // Use same pattern as other queries in the project
      await _client.from('message_reactions').insert({
        'message_id': messageId,
        'user_id': user.id,
        'emoji': emoji,
      });
      return true;
    } on PostgrestException catch (e, st) {
      debugPrint('[chat_service_supabase] addReaction PG error: ${e.message}\n$st');
      return false;
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] addReaction error: $e\n$st');
      return false;
    }
  }

  /// Remove a reaction for the current user from a message.
  Future<bool> removeReaction(String messageId, String emoji) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final res = await _client
          .from('message_reactions')
          .delete()
          .match({'message_id': messageId, 'user_id': user.id, 'emoji': emoji})
          .select();
      return (res as List).isNotEmpty;
    } on PostgrestException catch (e, st) {
      debugPrint('[chat_service_supabase] removeReaction PG error: ${e.message}\n$st');
      return false;
    } on Exception catch (e, st) {
      debugPrint('[chat_service_supabase] removeReaction error: $e\n$st');
      return false;
    }
  }

  /// Fetch aggregated reaction counts for a list of message IDs.
  /// Returns a map: messageId -> { emoji -> count }
  Future<Map<String, Map<String, int>>> fetchReactionsForMessages(List<String> messageIds) async {
    if (messageIds.isEmpty) return {};

    final Map<String, Map<String, int>> result = {};
    try {
      // Fetch per-message to avoid using Postgrest 'in' helper that may not be available
      for (final mid in messageIds) {
        final rows = await _client
            .from('message_reactions')
            .select('emoji')
            .eq('message_id', mid);

        final data = (rows as List).cast<Map<String, dynamic>>();
        final map = <String, int>{};
        for (final r in data) {
          final emoji = r['emoji'] as String;
          map[emoji] = (map[emoji] ?? 0) + 1;
        }
        if (map.isNotEmpty) result[mid] = map;
      }
      return result;
    } catch (e, st) {
      debugPrint('[chat_service_supabase] fetchReactionsForMessages error: $e\n$st');
      return result;
    }
  }

  /// Fetch reactions (individual rows) for a single message
  Future<List<MessageReaction>> fetchReactionsForMessage(String messageId) async {
    try {
        final rows = await _client
          .from('message_reactions')
          .select()
          .eq('message_id', messageId);

        final data = (rows as List).cast<Map<String, dynamic>>();
      return data.map((r) => MessageReaction.fromRow(r)).toList();
    } catch (e, st) {
      debugPrint('[chat_service_supabase] fetchReactionsForMessage error: $e\n$st');
      return [];
    }
  }

  // Realtime subscriptions are platform/version sensitive. For now this method is a no-op.
  // We fetch reactions on demand and update after local changes. Implement a realtime
  // subscription if your Supabase client/runtime supports it.
  void subscribeToReactions(void Function(Map<String, dynamic> payload) onEvent) {
    // no-op
  }

  /// Subscribe to real-time message updates for a conversation
  /// Returns a RealtimeChannel that should be unsubscribed when done
  RealtimeChannel subscribeToMessages(
    String conversationId, {
    required void Function(ChatMessage message) onInsert,
    required void Function(ChatMessage message) onUpdate,
    required void Function(String messageId) onDelete,
  }) {
    final channel = _client.channel('messages:$conversationId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              if (newRecord != null) {
                final message = _rowToChatMessage(newRecord);
                onInsert(message);
              }
            } catch (e, st) {
              debugPrint('[chat_service_supabase] subscribeToMessages INSERT error: $e\n$st');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              if (newRecord != null) {
                final message = _rowToChatMessage(newRecord);
                onUpdate(message);
              }
            } catch (e, st) {
              debugPrint('[chat_service_supabase] subscribeToMessages UPDATE error: $e\n$st');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              final oldRecord = payload.oldRecord;
              if (oldRecord != null && oldRecord['id'] != null) {
                onDelete(oldRecord['id'] as String);
              }
            } catch (e, st) {
              debugPrint('[chat_service_supabase] subscribeToMessages DELETE error: $e\n$st');
            }
          },
        )
        .subscribe();

    return channel;
  }
}
