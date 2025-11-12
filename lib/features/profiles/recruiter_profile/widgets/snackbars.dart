import 'package:flutter/material.dart';

class AppSnackbars {
  AppSnackbars._();

  static void error(BuildContext context, String message) {
    _show(context, message, background: Colors.red);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, background: const Color(0xFF2B7D61));
  }

  static void _show(BuildContext context, String message,
      {required Color background}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: background,
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
