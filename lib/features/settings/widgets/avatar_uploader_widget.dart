import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/cubits/auth/auth_cubit.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../models/user.dart';

class AvatarUploaderWidget extends StatefulWidget {
  final User user;

  const AvatarUploaderWidget({super.key, required this.user});

  @override
  State<AvatarUploaderWidget> createState() => _AvatarUploaderWidgetState();
}

class _AvatarUploaderWidgetState extends State<AvatarUploaderWidget> {
  final ImagePicker _picker = ImagePicker();

  /// Initialize the new dedicated service for Supabase Storage
  final SupabaseStorageService _storageService = SupabaseStorageService();

  final ProfileService _profileService = ProfileService();
  bool _isUploading = false;

  /// Use the user's current avatar URL if it exists
  String? get _currentAvatarUrl => widget.user.avatarUrl;

  Future<void> _pickAndUploadImage() async {
    final BuildContext context = this.context;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final publicUrl = await _storageService.uploadProfilePicture(image);

      await _profileService.updateAvatarUrl(publicUrl);

      final updatedUser = widget.user.copyWith(avatarUrl: publicUrl);

      context.read<AuthCubit>().updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update picture: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: _currentAvatarUrl != null
                ? NetworkImage(_currentAvatarUrl!) as ImageProvider<Object>?
                : null,
            child: _currentAvatarUrl == null && !_isUploading
                ? Text(
              widget.user.fullName.isEmpty
                  ? 'U'
                  : widget.user.fullName[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 40, color: Colors.white),
            )
                : null,
          ),

          if (_isUploading)
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),

          if (!_isUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}