import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/community/application/community_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
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

  Future<void> _createCommunity() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarUtils.showError(context, 'Please enter a community name');
      return;
    }

    String? imageUrl;
    if (_imageBytes != null) {
      imageUrl = await ref.read(profileControllerProvider.notifier).uploadImage(
        fileBytes: _imageBytes!,
        fileName: _imageName ?? 'community.jpg',
      );
    }

    final res = await ref.read(communityControllerProvider.notifier).createCommunity(
      name: name,
      description: _descController.text.trim(),
      communityImage: imageUrl,
    );

    if (res.isNotEmpty && mounted) {
      SnackBarUtils.showSuccess(context, 'Community created successfully!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityControllerProvider);
    final isLoading = communityState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Create Community', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: isLoading 
        ? const LoadingView()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _ImagePickerHeader(imageBytes: _imageBytes, onPickerTap: _pickImage),
                const SizedBox(height: 32),
                _InputField(controller: _nameController, hint: 'Community Name'),
                const SizedBox(height: 16),
                _InputField(controller: _descController, hint: 'Description', maxLines: 3),
                const SizedBox(height: 32),
                _SubmitButton(onPressed: _createCommunity),
              ],
            ),
          ),
    );
  }
}

class _ImagePickerHeader extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPickerTap;

  const _ImagePickerHeader({required this.imageBytes, required this.onPickerTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickerTap,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.surface,
        backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
        child: imageBytes == null 
          ? Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textPrimary.withValues(alpha: 0.5)) 
          : null,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _InputField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
        ),
        child: const Text('Create Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
