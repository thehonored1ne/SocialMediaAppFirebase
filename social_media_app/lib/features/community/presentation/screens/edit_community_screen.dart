import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/community/domain/models/community_model.dart';
import 'package:social_media_app/features/community/application/community_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final CommunityModel community;
  const EditCommunityScreen({super.key, required this.community});

  @override
  ConsumerState<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  Uint8List? _imageBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _descController = TextEditingController(text: widget.community.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _updateCommunity() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarUtils.showError(context, 'Please enter a name');
      return;
    }

    String? imageUrl = widget.community.communityImage;
    if (_imageBytes != null && _fileName != null) {
      final uploadRes = await ref.read(profileControllerProvider.notifier).uploadImage(
            fileBytes: _imageBytes!,
            fileName: _fileName!,
          );
      imageUrl = uploadRes;
    }

    if (imageUrl == null) {
      SnackBarUtils.showError(context, 'Image upload failed');
      return;
    }

    // Since we don't have a direct "update" method in controller yet,
    // I'll call the repository directly or we can add it to the controller.
    // For now, I'll add the update method to CommunityController first.
    await ref.read(communityControllerProvider.notifier).updateCommunityInfo(
          communityId: widget.community.id,
          name: name,
          description: _descController.text.trim(),
          imageUrl: imageUrl,
        );

    if (mounted) {
      SnackBarUtils.showSuccess(context, 'Community updated!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Edit Community', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check, color: AppColors.primary),
            onPressed: isLoading ? null : _updateCommunity,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppConstants.defaultPadding * 1.5),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.textPrimary.withValues(alpha: 0.05),
                backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : (widget.community.communityImage.isNotEmpty
                      ? NetworkImage(widget.community.communityImage)
                      : null) as ImageProvider?,
                child: _imageBytes == null && widget.community.communityImage.isEmpty
                  ? const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSecondary)
                  : null,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Community Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.textPrimary.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.textPrimary.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
