import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupAvatarSelector extends StatefulWidget {
  final Function(XFile? imageFile) onImageSelected;

  const SignupAvatarSelector({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<SignupAvatarSelector> createState() => _SignupAvatarSelectorState();
}

class _SignupAvatarSelectorState extends State<SignupAvatarSelector> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      widget.onImageSelected(_pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _pickedImage != null
                ? FileImage(File(_pickedImage!.path)) as ImageProvider<Object>?
                : null,
            child: _pickedImage == null
                ? Icon(
              Icons.add_a_photo_outlined,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pickedImage == null ? 'Optional: Add Profile Picture' : 'Change Picture',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}