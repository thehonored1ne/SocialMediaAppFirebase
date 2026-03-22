import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/features/reels/application/reel_controller.dart';

class AddReelScreen extends ConsumerStatefulWidget {
  const AddReelScreen({super.key});

  @override
  ConsumerState<AddReelScreen> createState() => _AddReelScreenState();
}

class _AddReelScreenState extends ConsumerState<AddReelScreen> {
  final TextEditingController _captionController = TextEditingController();
  Uint8List? _videoBytes;
  String? _videoName;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _videoBytes = file.bytes;
        _videoName = file.name;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _videoBytes = null;
      _videoName = null;
    });
  }

  Future<void> _uploadReel() async {
    if (_videoBytes == null) {
      SnackBarUtils.showError(context, 'Please select a video first');
      return;
    }

    final res = await ref.read(reelControllerProvider.notifier).uploadReel(
          caption: _captionController.text.trim(),
          fileBytes: _videoBytes!,
          fileName: _videoName ?? 'reel.mp4',
        );

    if (res == 'success' && mounted) {
      SnackBarUtils.showSuccess(context, 'Reel shared successfully!');
      context.pop();
    } else if (mounted) {
      SnackBarUtils.showError(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final profile = user != null ? ref.watch(profileProvider(user.uid)).valueOrNull : null;
    final reelState = ref.watch(reelControllerProvider);
    final isUploading = reelState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Create Reel', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          if (_videoBytes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: isUploading ? null : _uploadReel,
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Text('Share',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(
                        username: profile?.username ?? 'User',
                        imageUrl: profile?.profileImage ?? '',
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _captionController,
                          maxLines: null,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: "Write a caption for your reel...",
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_videoBytes != null)
                    _VideoPreview(onClear: _clearSelection),
                ],
              ),
            ),
          ),
          _BottomSelector(onTap: _pickVideo),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final VoidCallback onClear;
  const _VideoPreview({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 60, color: Colors.greenAccent),
                SizedBox(height: 12),
                Text('Video Selected', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSelector extends StatelessWidget {
  final VoidCallback onTap;
  const _BottomSelector({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
            ),
            child: const Row(
              children: [
                Icon(Icons.video_library_outlined, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Select a video for your reel', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
