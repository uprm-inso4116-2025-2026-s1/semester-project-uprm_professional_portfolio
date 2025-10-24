import 'package:flutter/material.dart';

class SaveFAB extends StatelessWidget {
  const SaveFAB({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets > 0 ? viewInsets + 12 : 0),
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Done',
        backgroundColor: const Color(0xFF2B7D61),
        foregroundColor: Colors.white,
        child: const Icon(Icons.check, size: 32),
      ),
    );
  }
}
