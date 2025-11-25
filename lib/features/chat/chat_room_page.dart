import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/chat_service_supabase.dart';
import 'image_viewer_page.dart';

/// Chat room page for a specific conversation
class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    required this.conversationId,
    super.key,
  });

  final String conversationId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatServiceSupabase _chatService = ChatServiceSupabase();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _selectedImageUrl;
  String? _selectedImageType;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    final messages = await _chatService.fetchMessages(
      widget.conversationId,
      limit: 50,
    );

    if (mounted) {
      setState(() {
        _messages = messages.reversed.toList(); // Show oldest first
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _selectedImageUrl == null) || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();
    final attachmentUrl = _selectedImageUrl;
    final attachmentType = _selectedImageType;
    setState(() {
      _selectedImageUrl = null;
      _selectedImageType = null;
    });

    final message = await _chatService.sendMessage(
      widget.conversationId,
      text.isEmpty ? ' ' : text,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );

    if (message != null && mounted) {
      setState(() {
        _messages.add(message);
        _isSending = false;
      });
      _scrollToBottom();
    } else if (mounted) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      await _uploadFile(image, 'image/jpeg');
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to attach image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null && file.path == null) {
        throw Exception('Could not read file');
      }

      // Create XFile from picked file
      final XFile xFile = XFile(
        file.path!,
        name: file.name,
        bytes: file.bytes,
      );

      // Determine MIME type
      String mimeType = 'application/octet-stream';
      final ext = file.extension?.toLowerCase();
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (ext == 'doc') {
        mimeType = 'application/msword';
      } else if (ext == 'docx') {
        mimeType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      } else if (ext == 'txt') {
        mimeType = 'text/plain';
      }

      await _uploadFile(xFile, mimeType);
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to attach file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFile(XFile file, String mimeType) async {
    setState(() => _isSending = true);

    try {
      // Upload to Supabase Storage
      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath =
          'chat_attachments/${_chatService.currentUserId}/$fileName';

      await Supabase.instance.client.storage
          .from('chat-media')
          .uploadBinary(filePath, bytes);

      // Get public URL
      final fileUrl = Supabase.instance.client.storage
          .from('chat-media')
          .getPublicUrl(filePath);

      setState(() {
        _selectedImageUrl = fileUrl;
        _selectedImageType = mimeType;
        _isSending = false;
      });

      if (mounted) {
        final isImage = mimeType.startsWith('image/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${isImage ? 'Image' : 'File'} attached! Type a message or send as is.'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      rethrow;
    }
  }

  void _removeAttachment() {
    setState(() {
      _selectedImageUrl = null;
      _selectedImageType = null;
    });
  }

  Future<void> _openFile(String url) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Opening file...'), duration: Duration(seconds: 1)),
        );
      }

      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Copy Link',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _showMessageOptions(ChatMessage message) async {
    // Check if message is within edit time window (15 minutes)
    final canEdit = DateTime.now().difference(message.timeStamp).inMinutes < 15;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Message'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(ChatMessage message) async {
    String? result;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditMessageDialog(
        initialText: message.text,
        onSave: (String text) {
          result = text;
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );

    if (result != null && result!.isNotEmpty && result != message.text) {
      final success = await _chatService.editMessage(message.id, result!);

      if (mounted) {
        if (success) {
          await _loadMessages();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message edited')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to edit message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(ChatMessage message) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await _chatService.deleteMessage(message.id);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  await _loadMessages(); // Refresh to show deleted placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message deleted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete message'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(UIConstants.spaceMD),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isCurrentUser =
                              message.senderId == _chatService.currentUserId;
                          return _buildMessageBubble(
                            message,
                            isCurrentUser,
                            theme,
                          );
                        },
                      ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: UIConstants.spaceLG),
          Text(
            'No messages yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: UIConstants.spaceSM),
          Text(
            'Send a message to start the conversation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isCurrentUser,
    ThemeData theme,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isCurrentUser && !message.isDeleted
            ? () => _showMessageOptions(message)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: UIConstants.spaceMD),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spaceMD,
            vertical: UIConstants.spaceSM,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: message.isDeleted
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : (isCurrentUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isCurrentUser ? const Radius.circular(4) : null,
              bottomLeft: !isCurrentUser ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display attachment if present and not deleted
              if (message.hasAttachment && !message.isDeleted) ...[
                if (message.isImage)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => ImageViewerPage(
                            imageUrl: message.attachmentUrl!,
                            heroTag: 'message_image_${message.id}',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'message_image_${message.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.attachmentUrl!,
                          width: MediaQuery.of(context).size.width * 0.6,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: isCurrentUser
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Image unavailable',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isCurrentUser
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 200,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                else
                  // Non-image attachment
                  GestureDetector(
                    onTap: () => _openFile(message.attachmentUrl!),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? theme.colorScheme.onPrimary.withOpacity(0.1)
                            : theme.colorScheme.onSurface.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 20,
                            color: isCurrentUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message.attachmentUrl!.split('/').last,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isCurrentUser
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (message.text.isNotEmpty) const SizedBox(height: 8),
              ],
              // Display text if present
              if (message.text.isNotEmpty)
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: message.isDeleted
                        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6)
                        : (isCurrentUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface),
                    fontStyle: message.isDeleted ? FontStyle.italic : null,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.jm().format(message.timeStamp.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCurrentUser
                          ? theme.colorScheme.onPrimary.withOpacity(0.7)
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (message.isEdited && !message.isDeleted) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(edited)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCurrentUser
                            ? theme.colorScheme.onPrimary.withOpacity(0.6)
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: UIConstants.spaceMD,
        right: UIConstants.spaceMD,
        top: UIConstants.spaceSM,
        bottom: MediaQuery.of(context).viewInsets.bottom + UIConstants.spaceSM,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected attachment preview
          if (_selectedImageUrl != null)
            Container(
              margin: const EdgeInsets.only(bottom: UIConstants.spaceSM),
              padding: const EdgeInsets.all(UIConstants.spaceSM),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Show image preview or file icon
                  if (_selectedImageType?.startsWith('image/') ?? true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        _selectedImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.insert_drive_file,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 30,
                      ),
                    ),
                  const SizedBox(width: UIConstants.spaceSM),
                  Expanded(
                    child: Text(
                      _selectedImageType?.startsWith('image/') ?? true
                          ? 'Image attached'
                          : 'File attached',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _removeAttachment,
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
          // Input row
          Row(
            children: [
              // Attachment menu button
              PopupMenuButton<String>(
                enabled: !_isSending,
                icon: const Icon(Icons.attach_file),
                tooltip: 'Attach file',
                onSelected: (value) {
                  if (value == 'image') {
                    _pickImage();
                  } else if (value == 'file') {
                    _pickFile();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'image',
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 12),
                        Text('Image'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'file',
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file),
                        SizedBox(width: 12),
                        Text('File (PDF, DOC, TXT)'),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spaceMD,
                      vertical: UIConstants.spaceSM,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: UIConstants.spaceSM),
              IconButton.filled(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                tooltip: 'Send',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({
    required this.initialText,
    required this.onSave,
    required this.onCancel,
  });

  final String initialText;
  final void Function(String text) onSave;
  final VoidCallback onCancel;

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter new message',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text.trim();
            widget.onSave(text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
