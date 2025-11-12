import 'package:flutter/material.dart';
import '../core/state/app_state.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppState.role,
      builder: (context, role, _) {
        if (role == null) return const SizedBox.shrink();
        final label = role == 'recruiter' ? 'Recruiter' : 'Student';
        return Chip(
          label: Text(label),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
    );
  }
}
