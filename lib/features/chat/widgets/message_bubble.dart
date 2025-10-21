import 'package:flutter/material.dart';

/// UX: Reusable message bubble supporting light/dark themes, timestamps,
/// shadows, and alignment for sent/received states.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.timestamp,
    required this.isCurrentUser,
    this.status,
    this.maxWidthFactor = 0.75,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.showStatus = true,
  });

  final String text;
  final DateTime timestamp;
  final bool isCurrentUser;
  final MessageStatus? status;
  final double maxWidthFactor;
  final EdgeInsetsGeometry padding;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color background = isCurrentUser
        ? scheme.primary
        : scheme.surfaceVariant;
    final Color foreground = isCurrentUser
        ? scheme.onPrimary
        : scheme.onSurface;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isCurrentUser ? const Radius.circular(18) : const Radius.circular(6),
      bottomRight: isCurrentUser ? const Radius.circular(6) : const Radius.circular(18),
    );

    final boxShadow = isDark
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: padding,
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            boxShadow: boxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: isCurrentUser
                          ? foreground.withOpacity(0.7)
                          : scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (showStatus && isCurrentUser && status != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _statusIcon(status!),
                      size: 14,
                      color: status == MessageStatus.read
                          ? scheme.secondary
                          : foreground.withOpacity(0.7),
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

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final difference = now.difference(ts);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  IconData _statusIcon(MessageStatus s) {
    switch (s) {
      case MessageStatus.sending:
        return Icons.access_time_filled_rounded;
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.read:
        return Icons.done_all_rounded;
    }
  }
}

enum MessageStatus { sending, sent, delivered, read }
