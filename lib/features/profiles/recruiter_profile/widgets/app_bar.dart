import 'package:flutter/material.dart';

class BrandedAppBar extends AppBar {
  BrandedAppBar({
    super.key,
    required BuildContext context,
    required String titleText,
    VoidCallback? onBack,
  }) : super(
    leadingWidth: 56,
    backgroundColor: const Color(0xFF2B7D61),
    foregroundColor: Colors.white,
    leading: IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: onBack,
    ),
    centerTitle: true,
    title: Text(
      titleText,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 25,
        letterSpacing: 0.2,
      ),
    ),
  );
}
