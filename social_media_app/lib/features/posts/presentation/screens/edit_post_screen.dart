import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  late TextEditingController _captionController;
  late TextEditingController _codeController;
  late String _selectedLanguage;

  final List<String> _languages = ['dart', 'javascript', 'python', 'php', 'cpp', 'java', 'html', 'css'];

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _codeController = TextEditingController(text: widget.post.codeSnippet);
    _selectedLanguage = widget.post.codeLanguage.isEmpty ? 'dart' : widget.post.codeLanguage;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    await ref.read(postControllerProvider.notifier).updatePost(
          postId: widget.post.postId,
          caption: _captionController.text.trim(),
          codeSnippet: _codeController.text.trim(),
          codeLanguage: _selectedLanguage,
        );

    final state = ref.read(postControllerProvider);
    if (!state.hasError && mounted) {
      SnackBarUtils.showSuccess(context, 'Post updated successfully!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);
    final isSaving = postState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Post', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: isSaving ? null : _updatePost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          )
        ],
      ),
      body: isSaving 
        ? const LoadingView()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Caption', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: null,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CODE SNIPPET', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  maxLines: 10,
                  style: GoogleFonts.firaCode(fontSize: 13, color: Colors.greenAccent),
                  decoration: InputDecoration(
                    hintText: 'Paste your code here...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.codeBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
