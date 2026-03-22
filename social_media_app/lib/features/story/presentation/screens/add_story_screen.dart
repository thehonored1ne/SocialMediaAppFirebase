import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/story/application/story_controller.dart';

class AddStoryScreen extends ConsumerStatefulWidget {
  const AddStoryScreen({super.key});

  @override
  ConsumerState<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends ConsumerState<AddStoryScreen> {
  final List<SelectedMedia> _selectedMedia = [];

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      withData: true,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final isVideo = file.name.toLowerCase().endsWith('.mp4') ||
              file.name.toLowerCase().endsWith('.mov');
          _selectedMedia.add(SelectedMedia(
            bytes: file.bytes!,
            name: file.name,
            isVideo: isVideo,
          ));
        }
      });
    }
  }

  Future<void> _createStory() async {
    if (_selectedMedia.isEmpty) return;

    await ref.read(storyControllerProvider.notifier).uploadStories(_selectedMedia);
    
    final state = ref.read(storyControllerProvider);
    if (!state.hasError && mounted) {
      SnackBarUtils.showSuccess(context, 'Stories shared successfully!');
      context.pop();
    } else if (state.hasError && mounted) {
      SnackBarUtils.showError(context, state.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyControllerProvider);
    final isUploading = storyState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Add to Story', 
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          if (_selectedMedia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: isUploading ? null : _createStory,
                child: isUploading
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Text('Share', 
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedMedia.isEmpty
                ? _buildEmptyState()
                : _buildMediaGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, 
            size: 80, color: AppColors.textPrimary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickMedia,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
            ),
            child: const Text('Select Media'),
          )
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedMedia.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedMedia.length) {
          return GestureDetector(
            onTap: _pickMedia,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.add, color: AppColors.textSecondary),
            ),
          );
        }
        
        final media = _selectedMedia[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: media.isVideo
                  ? Container(
                      color: AppColors.surface, 
                      child: const Icon(Icons.videocam, color: AppColors.textSecondary))
                  : Image.memory(media.bytes, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _selectedMedia.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5), 
                    shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
