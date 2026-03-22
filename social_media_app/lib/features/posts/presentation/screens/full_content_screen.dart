import 'package:flutter/material.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/core/common/widgets/real_video_player.dart';
import 'package:social_media_app/core/common/widgets/dev_features.dart';
import 'package:google_fonts/google_fonts.dart';

class FullContentScreen extends StatelessWidget {
  final PostModel post;

  const FullContentScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isTextOnly = post.imageUrl.isEmpty && !post.isVideo && post.codeSnippet.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          Center(
            child: _buildContent(context, isTextOnly),
          ),
          
          // Close Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isTextOnly) {
    if (isTextOnly) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Text(
          post.caption,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
      );
    }

    if (post.isVideo) {
      return RealVideoPlayer(videoUrl: post.imageUrl);
    }

    if (post.imageUrl.isNotEmpty) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (post.codeSnippet.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DevCodeSnippet(code: post.codeSnippet, language: post.codeLanguage),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
