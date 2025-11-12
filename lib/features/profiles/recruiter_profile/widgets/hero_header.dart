import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 48,
    this.spacing = 16,
    this.center = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final double spacing;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final align = center ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment:
      center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize * 1.5, color: theme.colorScheme.primary),
        SizedBox(height: spacing),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: align,
        ),
        SizedBox(height: spacing / 2),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: align,
        ),
      ],
    );
  }
}
