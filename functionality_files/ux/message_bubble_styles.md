# UX: Message Bubble Styles

This document defines the visual system for message bubbles used in chat screens.

Objective
- Consistent, readable bubbles for sent (right) and received (left) messages.
- Work across light and dark themes using existing AppTheme color scheme.

Design tokens
- Corner radius: 18px (outer corners), 6px (inner tail corner)
- Max width: 75% of viewport width
- Padding: 10px vertical, 16px horizontal
- Shadow (light mode): rgba(0,0,0,0.05) blur 4, y 2
- Shadow (dark mode): none (rely on contrast)
- Spacing between bubbles: 8px

Colors (derived from ThemeData)
- Sent bg: colorScheme.primary; text: colorScheme.onPrimary
- Received bg: colorScheme.surfaceVariant; text: colorScheme.onSurface
- Timestamp: 11sp; sent: onPrimary at 70% opacity; received: onSurface at 60% opacity
- Status icon (optional):
  - sent/delivered: onPrimary at 70% opacity
  - read: secondary color (if available) or onPrimary at 90%

States
- Long text wraps; bubble grows to max width then line-breaks.
- Short text centers vertically with timestamp on next line.
- Attachments (future): reserve space above caption; bubble uses same radius and padding; caption styled like text.

Accessibility
- Respect system text scaling.
- Maintain 4.5:1 contrast (checked against default themes).

Implementation notes
- Reusable widget: MessageBubble in lib/features/chat/widgets/message_bubble.dart
- Uses Theme.of(context).colorScheme for dynamic theming.
- Integrate in ChatDetailScreen._buildMessageBubble.
