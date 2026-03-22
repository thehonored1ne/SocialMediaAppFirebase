import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/features/auth/domain/models/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _portfolioController;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _githubController = TextEditingController(text: widget.user.githubUsername ?? '');
    _portfolioController = TextEditingController(text: widget.user.portfolioUrl ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageName = result.files.single.name;
      });
    }
  }

  Future<void> _updateProfile() async {
    String? imageUrl;
    if (_imageBytes != null) {
      imageUrl = await ref.read(profileControllerProvider.notifier).uploadImage(
        fileBytes: _imageBytes!,
        fileName: _imageName ?? 'profile.jpg',
      );
    }

    await ref.read(profileControllerProvider.notifier).updateProfile(
      uid: widget.user.uid,
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      profileImageUrl: imageUrl ?? widget.user.profileImage,
      githubUsername: _githubController.text.trim(),
      portfolioUrl: _portfolioController.text.trim(),
    );

    final state = ref.read(profileControllerProvider);
    if (!state.hasError && mounted) {
      SnackBarUtils.showSuccess(context, 'Profile updated successfully!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check, color: AppColors.primary),
            onPressed: isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body: isLoading 
        ? const LoadingView()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                _ProfileImagePicker(
                  imageBytes: _imageBytes,
                  currentImageUrl: widget.user.profileImage,
                  username: widget.user.username,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 24),
                _EditField(controller: _usernameController, label: 'Username'),
                const SizedBox(height: 20),
                _EditField(controller: _bioController, label: 'Bio', maxLines: 3),
                const SizedBox(height: 30),
                _SectionDivider(title: 'DEVELOPER LINKS'),
                _EditField(controller: _githubController, label: 'GitHub Username', hint: 'e.g. flutter', icon: Icons.code),
                const SizedBox(height: 20),
                _EditField(controller: _portfolioController, label: 'Portfolio / LinkedIn URL', hint: 'https://...', icon: Icons.link),
              ],
            ),
          ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String currentImageUrl;
  final String username;
  final VoidCallback onTap;

  const _ProfileImagePicker({required this.imageBytes, required this.currentImageUrl, required this.username, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            backgroundImage: imageBytes != null 
              ? MemoryImage(imageBytes!) as ImageProvider
              : (currentImageUrl.isNotEmpty ? NetworkImage(currentImageUrl) : null),
            child: imageBytes == null && currentImageUrl.isEmpty ? UserAvatar(username: username, radius: 50) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final IconData? icon;

  const _EditField({required this.controller, required this.label, this.hint, this.maxLines = 1, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary, size: 20) : null,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textTertiary)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
