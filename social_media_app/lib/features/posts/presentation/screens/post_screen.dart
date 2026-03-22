import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/features/community/application/community_controller.dart';

class PostScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String? communityId;

  const PostScreen({super.key, required this.onClose, this.communityId});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _captionController = TextEditingController();
  final _codeController = TextEditingController();
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isVideo = false;
  bool _showCodeInput = false;
  String _selectedLanguage = 'dart';

  final List<String> _languages = ['dart', 'javascript', 'python', 'php', 'cpp', 'java', 'html', 'css'];

  @override
  void dispose() {
    _captionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      final isVideo = file.name.toLowerCase().endsWith('.mp4') || 
                      file.name.toLowerCase().endsWith('.mov') || 
                      file.name.toLowerCase().endsWith('.avi');

      setState(() {
        _fileBytes = file.bytes;
        _fileName = file.name;
        _isVideo = isVideo;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _fileBytes = null;
      _fileName = null;
      _isVideo = false;
    });
  }

  Future<void> _uploadPost() async {
    if (_fileBytes == null && _captionController.text.trim().isEmpty && _codeController.text.trim().isEmpty) {
      SnackBarUtils.showError(context, 'Please add some content');
      return;
    }

    final user = ref.read(authStateChangesProvider).value;
    final profile = user != null ? ref.read(profileProvider(user.uid)).valueOrNull : null;
    final username = profile?.username ?? 'User';

    final res = await ref.read(postControllerProvider.notifier).uploadPost(
          fileBytes: _fileBytes,
          fileName: _fileName,
          isVideo: _isVideo,
          caption: _captionController.text.trim(),
          username: username,
          communityId: widget.communityId,
          codeSnippet: _codeController.text.trim(),
          codeLanguage: _selectedLanguage,
        );

    if (res == "success" && mounted) {
      SnackBarUtils.showSuccess(context, 'Post shared successfully!');
      widget.onClose();
    } else if (mounted) {
      SnackBarUtils.showError(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postControllerState = ref.watch(postControllerProvider);
    final isLoading = postControllerState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: widget.onClose,
        ),
        title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          _ShareButton(
            isLoading: isLoading,
            onPressed: _uploadPost,
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.communityId != null) _buildCommunityIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _PostInputArea(captionController: _captionController),
                  if (_showCodeInput) _buildCodeInputSection(),
                  if (_fileBytes != null) _MediaPreview(fileBytes: _fileBytes!, isVideo: _isVideo, onClear: _clearMedia),
                ],
              ),
            ),
          ),
          _BottomActions(
            showCodeInput: _showCodeInput,
            onToggleCode: () => setState(() => _showCodeInput = !_showCodeInput),
            onPickMedia: _pickMedia,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("CODE SNIPPET", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
                underline: const SizedBox(),
                items: _languages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                )).toList(),
                onChanged: (val) => setState(() => _selectedLanguage = val!),
              ),
            ],
          ),
          const Divider(color: AppColors.textTertiary),
          TextField(
            controller: _codeController,
            maxLines: 8,
            style: GoogleFonts.firaCode(fontSize: 13, color: Colors.greenAccent),
            decoration: const InputDecoration(
              hintText: 'Paste your code here...',
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityIndicator() {
    final communityAsync = ref.watch(communityProvider(widget.communityId!));
    return communityAsync.when(
      data: (community) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          border: const Border(bottom: BorderSide(color: AppColors.primary, width: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Posting to ${community.name}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ShareButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16, top: 10, bottom: 10),
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(20),
          ),
          child: isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
            : const Text('Share', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}

class _PostInputArea extends ConsumerWidget {
  final TextEditingController captionController;

  const _PostInputArea({required this.captionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final profile = user != null ? ref.watch(profileProvider(user.uid)).valueOrNull : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          username: profile?.username ?? 'User', 
          imageUrl: profile?.profileImage ?? '', 
          radius: 20
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100),
            child: TextField(
              controller: captionController,
              maxLines: null,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final Uint8List fileBytes;
  final bool isVideo;
  final VoidCallback onClear;

  const _MediaPreview({required this.fileBytes, required this.isVideo, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: isVideo
              ? Container(
                  height: 250,
                  width: double.infinity,
                  color: AppColors.textTertiary,
                  child: const Icon(Icons.videocam, size: 50, color: AppColors.textSecondary)
                )
              : Image.memory(fileBytes, fit: BoxFit.cover, width: double.infinity),
          ),
          PositionedDirectional(
            top: 10,
            end: 10,
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

class _BottomActions extends StatelessWidget {
  final bool showCodeInput;
  final VoidCallback onToggleCode;
  final VoidCallback onPickMedia;

  const _BottomActions({
    required this.showCodeInput,
    required this.onToggleCode,
    required this.onPickMedia,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 85, start: 16, end: 16),
        child: Column(
          children: [
            _ActionButton(
              icon: Icons.code_rounded,
              text: showCodeInput ? 'Remove code snippet' : 'Attach code snippet',
              active: showCodeInput,
              onTap: onToggleCode,
            ),
            const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.image_outlined,
              text: 'Add media to your post',
              active: false,
              onTap: onPickMedia,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.5) : AppColors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
