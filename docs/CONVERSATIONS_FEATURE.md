# Conversations Feature

## Overview

The Conversations feature enables real-time messaging between users in the UPRM Professional Portfolio application. It provides a complete chat system with support for message history, editing, deleting, and attachments, backed by Supabase for persistence and real-time updates.

## Architecture

### Database Tables

The feature relies on four primary database tables:

1. **`conversations`** - Stores conversation metadata
   - `id` (uuid, PK)
   - `created_at` (timestamp)
   - `updated_at` (timestamp)
   - `match_id` (uuid, nullable) - Links to matches table if conversation originated from a match

2. **`conversation_participants`** - Tracks who is in each conversation
   - `id` (uuid, PK)
   - `conversation_id` (uuid, FK → conversations.id)
   - `user_id` (uuid, FK → users.id)
   - `role` (text) - Typically 'member'
   - `joined_at` (timestamp)

3. **`messages`** - Contains all chat messages
   - `id` (uuid, PK)
   - `conversation_id` (uuid, FK → conversations.id)
   - `sender_id` (uuid, FK → users.id)
   - `body` (text) - Message content
   - `created_at` (timestamp)
   - `updated_at` (timestamp, nullable)
   - `deleted_at` (timestamp, nullable)
   - `attachment_url` (text, nullable)
   - `attachment_type` (text, nullable)
   - `is_edited` (boolean, default false)
   - `is_deleted` (boolean, default false)

4. **`users`** - User information
   - `id` (uuid, PK)
   - `full_name` (text)
   - `email` (text)
   - `avatar_url` (text, nullable)

### Core Services

#### `ConversationService`
Location: `lib/core/services/conversation_service.dart`

Handles conversation-level operations:
- `fetchUserConversations()` - Retrieves all conversations for the logged-in user with participant details and last message
- `createConversation(String otherUserId)` - Creates a new 1-on-1 conversation or returns existing one
- `getConversationForMatch(String matchId)` - Finds conversation linked to a specific match

**Implementation Notes:**
- Uses Supabase RLS (Row Level Security) for data access control
- Falls back to direct queries if RPC functions are unavailable
- Processes conversations individually to handle RLS restrictions
- Filters out the current user from participant lists

#### `ChatServiceSupabase`
Location: `lib/core/services/chat_service_supabase.dart`

Handles message-level operations:
- `fetchMessages(String conversationId, {int limit, DateTime? before})` - Retrieves paginated messages
- `sendMessage(String conversationId, String body, {String? attachmentUrl, String? attachmentType})` - Sends a new message
- `editMessage(String messageId, String newBody)` - Edits an existing message (only by sender)
- `deleteMessage(String messageId)` - Soft-deletes a message (only by sender)

**Key Features:**
- Returns messages in descending order (most recent first)
- Supports pagination via `before` parameter
- Enforces sender-only edit/delete permissions
- Handles both text and attachment messages
- Maps database `body` field to `ChatMessage.text`

### Data Models

#### `ChatMessage`
Location: `lib/core/services/chat_service.dart`

```dart
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;              // Maps to 'body' in database
  final DateTime timeStamp;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? updatedAt;
  
  bool get hasAttachment;
  bool get isImage;
}
```

#### `ConversationListItem`
Location: `lib/models/conversation_list_item.dart`

```dart
class ConversationListItem {
  final String id;
  final String participantId;
  final String participantName;
  final String participantEmail;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;
}
```

## UI Components

### `ConversationsPage`
Location: `lib/features/chat/conversations_page.dart`

Main screen showing list of all conversations.

**Features:**
- Pull-to-refresh functionality
- Displays participant name, avatar, last message preview
- Shows formatted timestamps (e.g., "2h ago", "Yesterday")
- Unread count badges (currently always 0, placeholder for future)
- Empty state with "Explore Matches" button (shows "coming soon" snackbar)
- Error state with retry button
- Navigation to chat room on tap

**Access:**
- From main screen bottom navigation bar (middle tab)
- Route: `/main?tab=1`

### `ChatRoomPage`
Location: `lib/features/chat/chat_room_page.dart`

Individual chat screen for a conversation.

**Features:**
- Message bubbles styled differently for current user vs. other participant
- Send text messages
- Image attachment support (via `_selectedImageUrl` and `_selectedImageType`)
- Edit messages (within 15 minutes)
- Delete messages (soft delete, shows "Message deleted")
- Pull-to-refresh to reload messages
- Auto-scroll to bottom on send
- Loading states for send operations

**Access:**
- From conversations list by tapping a conversation
- Route: `/chat/:conversationId`

**Edit/Delete Constraints:**
- Only message sender can edit/delete
- Edit time limit: 15 minutes from creation
- Edits show "(edited)" indicator
- Deletes replace message with "Message deleted" text

## Routing

Routes are defined in `lib/routes/app_router.dart`:

```dart
// Conversations list (accessed via main screen with tab param)
GoRoute(
  path: '/main',
  builder: (context, state) {
    final index = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
    return MainScreen(initialIndex: index);
  },
)

// Individual chat room
GoRoute(
  path: '/chat/:conversationId',
  builder: (context, state) {
    final conversationId = state.pathParameters['conversationId']!;
    return ChatRoomPage(conversationId: conversationId);
  },
)
```

Navigate to conversations: `context.go('/main?tab=1')`
Navigate to chat room: `context.go('/chat/$conversationId')`

## What Works

### Messaging
- Send text messages
- View message history in chronological order
- Real-time updates (via Supabase)
- Pagination support for large conversations
- Message timestamps

### Conversation Management
- List all user conversations
- Display participant information
- Show last message preview
- Sort by most recent activity
- Create new conversations programmatically

### Message Actions
- Edit messages (within time limit)
- Delete messages (soft delete)
- Sender-only permissions enforced
- Edit/delete state tracking

### Attachments
- Database schema supports attachments
- Frontend has image attachment fields
- `ChatMessage` model includes `attachmentUrl`, `attachmentType`
- Type checking via `isImage` getter

## What Doesn't Work / Limitations

### Unimplemented Features
1. **Matches Integration** - "Explore Matches" button shows "coming soon" snackbar
2. **Unread Count** - Always displays 0, no read tracking implemented
3. **Typing Indicators** - No real-time typing status
4. **Message Reactions** - No emoji reactions or likes
5. **Push Notifications** - No notifications for new messages
6. **Group Conversations** - Only 1-on-1 conversations supported
7. **Message Search** - No search within conversations
8. **File Attachments** - No UI for uploading images/files (schema exists but no picker implementation)
9. **Voice Messages** - No audio recording/playback
10. **Read Receipts** - No "seen by" indicators
11. **Message Delivery Status** - No sent/delivered/read status

### Known Issues
- RLS policies may require RPC functions `get_conversation_participants` and `get_user_details` for optimal performance
- Conversation list refresh on new message requires manual pull-to-refresh
- No optimistic UI updates (waits for server response)
- Image attachment selection exists in state but no UI to trigger it

## How to Extend/Modify

### Adding a New Message Type

1. Update database schema if needed (add columns to `messages` table)
2. Modify `ChatMessage` model in `lib/core/services/chat_service.dart`
3. Update `ChatServiceSupabase._rowToChatMessage()` to parse new fields
4. Update `ChatServiceSupabase.sendMessage()` to accept new parameters
5. Modify `ChatRoomPage._buildMessageBubble()` to render new type

### Implementing Unread Count

1. Add `last_read_at` timestamp to `conversation_participants` table
2. Create database function to count unread messages:
   ```sql
   SELECT COUNT(*) FROM messages 
   WHERE conversation_id = ? 
     AND created_at > (SELECT last_read_at FROM conversation_participants WHERE conversation_id = ? AND user_id = ?)
   ```
3. Update `ConversationService.fetchUserConversations()` to include unread count
4. Call update function when user opens a conversation:
   ```sql
   UPDATE conversation_participants 
   SET last_read_at = NOW() 
   WHERE conversation_id = ? AND user_id = ?
   ```

### Adding File Upload

1. Install `file_picker` or `image_picker` package
2. Add upload button to `ChatRoomPage` UI
3. Upload file to Supabase Storage:
   ```dart
   final path = await _supabase.storage
     .from('attachments')
     .upload('conversation/$conversationId/${DateTime.now().millisecondsSinceEpoch}', file);
   final url = _supabase.storage.from('attachments').getPublicUrl(path);
   ```
4. Pass `url` and MIME type to `ChatServiceSupabase.sendMessage()`
5. Update `_buildMessageBubble()` to display images/files based on `attachmentType`

### Implementing Group Chats

1. Remove 1-on-1 assumption in `ConversationService.createConversation()`
2. Allow multiple participants in `conversation_participants`
3. Update `ConversationListItem` to handle multiple participant names
4. Modify `ConversationsPage` UI to show "Group: Name1, Name2, Name3"
5. Add group name field to `conversations` table
6. Update `ChatRoomPage` to show all participant names in AppBar

### Adding Real-Time Updates

1. Use Supabase Realtime subscriptions:
   ```dart
   final subscription = _supabase
     .from('messages:conversation_id=eq.$conversationId')
     .stream(primaryKey: ['id'])
     .listen((List<Map<String, dynamic>> data) {
       // Update _messages list
       setState(() { ... });
     });
   ```
2. Subscribe in `ChatRoomPage.initState()`
3. Cancel subscription in `dispose()`
4. For conversation list, subscribe to all user conversations
5. Update UI when new messages arrive

### Customizing Message Appearance

Edit `ChatRoomPage._buildMessageBubble()`:
- Change colors: Modify `backgroundColor` based on `isCurrentUser`
- Add borders: Wrap in `Container` with `BoxDecoration`
- Custom shapes: Use `CustomPainter` or `ClipPath`
- Add avatars: Fetch user details and display `CircleAvatar`
- Timestamp position: Rearrange `Column` children

## Testing

### Manual Testing

1. **Create Test Data:**
   ```sql
   -- Run in Supabase SQL Editor
   INSERT INTO conversations (id) VALUES 
     ('11111111-1111-1111-1111-111111111111'),
     ('22222222-2222-2222-2222-222222222222');
   
   INSERT INTO conversation_participants (conversation_id, user_id, role) VALUES
     ('11111111-1111-1111-1111-111111111111', 'carlos-uuid', 'member'),
     ('11111111-1111-1111-1111-111111111111', 'alexa-uuid', 'member'),
     ('22222222-2222-2222-2222-222222222222', 'carlos-uuid', 'member'),
     ('22222222-2222-2222-2222-222222222222', 'samarys-uuid', 'member');
   
   INSERT INTO messages (conversation_id, sender_id, body) VALUES
     ('11111111-1111-1111-1111-111111111111', 'alexa-uuid', 'Hey Carlos!'),
     ('22222222-2222-2222-2222-222222222222', 'samarys-uuid', 'Hi there!');
   ```

2. **Run App:**
   ```bash
   flutter run -d emulator-5554
   ```

3. **Test Scenarios:**
   - Login as Carlos
   - Navigate to Conversations tab (bottom nav middle icon)
   - Verify 2 conversations appear
   - Tap first conversation, verify chat room opens
   - Send a message, verify it appears
   - Long-press message, tap Edit, modify text, verify "(edited)" appears
   - Long-press message, tap Delete, verify "Message deleted" appears
   - Pull down to refresh, verify messages reload
   - Return to conversations list, verify last message updated

### Unit Tests

Location: `test/chat_service_supabase_test.dart`

**Existing Tests:**
- `sendMessage and fetchMessages`
- `fetchMessages returns most recent first and respects limit`
- `fetchMessages with before includes messages older than cutoff`

**Run Tests:**
```bash
flutter test test/chat_service_supabase_test.dart
```

**Test Requirements:**
- Valid Supabase credentials in environment
- Test conversation ID exists in database
- Authenticated user with access to conversation

## Dependencies

Required packages in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.7      # Database and auth
  go_router: ^14.2.7            # Navigation
  intl: ^0.19.0                 # Date formatting
```

## Configuration

### Environment Setup

1. **Supabase Project:**
   - Create tables: `conversations`, `conversation_participants`, `messages`
   - Configure RLS policies:
     ```sql
     -- Users can only see their own conversation participants
     CREATE POLICY "Users can view own participation"
       ON conversation_participants FOR SELECT
       USING (auth.uid() = user_id);
     
     -- Users can view messages in conversations they're part of
     CREATE POLICY "Users can view conversation messages"
       ON messages FOR SELECT
       USING (
         EXISTS (
           SELECT 1 FROM conversation_participants
           WHERE conversation_id = messages.conversation_id
             AND user_id = auth.uid()
         )
       );
     
     -- Users can send messages in their conversations
     CREATE POLICY "Users can send messages"
       ON messages FOR INSERT
       WITH CHECK (
         EXISTS (
           SELECT 1 FROM conversation_participants
           WHERE conversation_id = messages.conversation_id
             AND user_id = auth.uid()
         )
         AND sender_id = auth.uid()
       );
     
     -- Users can edit/delete own messages
     CREATE POLICY "Users can modify own messages"
       ON messages FOR UPDATE
       USING (sender_id = auth.uid());
     ```

2. **Optional RPC Functions:**
   ```sql
   -- Get all participants in a conversation (bypasses RLS)
   CREATE OR REPLACE FUNCTION get_conversation_participants(conv_id uuid)
   RETURNS TABLE(user_id uuid) AS $$
   BEGIN
     RETURN QUERY
     SELECT cp.user_id
     FROM conversation_participants cp
     WHERE cp.conversation_id = conv_id;
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   
   -- Get user details (bypasses RLS)
   CREATE OR REPLACE FUNCTION get_user_details(user_ids uuid[])
   RETURNS TABLE(id uuid, full_name text, email text, avatar_url text) AS $$
   BEGIN
     RETURN QUERY
     SELECT u.id, u.full_name, u.email, u.avatar_url
     FROM users u
     WHERE u.id = ANY(user_ids);
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   ```

### App Configuration

Update `lib/core/constants/app_constants.dart` if needed:
```dart
class AppConstants {
  static const String mainRoute = '/main';
  // Add conversation-specific constants here
  static const int maxMessageLength = 1000;
  static const int messageEditTimeLimit = 15; // minutes
}
```

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── chat_service.dart              # ChatMessage model
│   │   ├── chat_service_supabase.dart     # Message operations
│   │   └── conversation_service.dart      # Conversation operations
│   └── constants/
│       └── ui_constants.dart               # Spacing, sizing
├── features/
│   ├── chat/
│   │   ├── conversations_page.dart        # Conversations list UI
│   │   └── chat_room_page.dart            # Chat room UI
│   └── main/
│       └── main_screen.dart               # Bottom nav host
├── models/
│   └── conversation_list_item.dart        # Conversation list model
└── routes/
    └── app_router.dart                     # Navigation config
```

## Common Issues & Solutions

### Issue: Conversations not loading
**Solution:** Check Supabase RLS policies. User must have SELECT permission on `conversation_participants` for their own records.

### Issue: Can't send messages
**Solution:** Verify user is in `conversation_participants` table for the conversation. Check INSERT policy on `messages` table.

### Issue: Other participant name shows "Unknown User"
**Solution:** Ensure `users` table has RLS policy allowing conversation participants to read each other's basic info, or implement `get_user_details` RPC function.

### Issue: Edit/delete not working
**Solution:** Check that `sender_id` matches `auth.uid()`. Ensure UPDATE policy on `messages` table allows sender to modify own messages.

### Issue: Messages appear out of order
**Solution:** Verify `created_at` timestamps are UTC. Check `fetchMessages` sorts by `created_at DESC`.

### Issue: Empty conversations list but data exists in database
**Solution:** Check that logged-in user ID matches `user_id` in `conversation_participants`. Verify RLS policies are active.

## Future Enhancements

Planned features for future versions:

1. **Voice/Video Calls** - Integration with WebRTC or third-party service
2. **Message Forwarding** - Share messages between conversations
3. **Starred Messages** - Bookmark important messages
4. **Conversation Archiving** - Hide old conversations without deleting
5. **Custom Themes** - Per-conversation color schemes
6. **Mentions** - Tag other participants with @
7. **Rich Text** - Markdown or basic formatting support
8. **Link Previews** - Unfurl URLs with title/image
9. **Location Sharing** - Send map pins
10. **Conversation Settings** - Mute notifications, block users

## Support

For questions or issues:
1. Check this documentation first
2. Review Supabase logs in dashboard
3. Use Flutter DevTools for debugging UI issues
4. Check terminal output for service errors (prefixed with `[chat_service_supabase]` or `[conversation_service]`)
5. Consult `test/chat_service_supabase_test.dart` for usage examples

## Changelog

### Current Version
- ✅ Send/receive text messages
- ✅ Edit messages (15-minute limit)
- ✅ Delete messages (soft delete)
- ✅ Conversation list with last message
- ✅ 1-on-1 conversations
- ✅ Pull-to-refresh
- ✅ Pagination support
- ✅ Supabase integration with RLS
- ⚠️ Attachment schema (UI not implemented)
- ❌ Unread count (always 0)
- ❌ Real-time updates (manual refresh required)
- ❌ Matches integration (coming soon)

---

**Last Updated:** November 25, 2025
**Author:** Development Team
**Version:** 1.0
