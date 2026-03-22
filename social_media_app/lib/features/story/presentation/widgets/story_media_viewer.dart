import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';

class StoryMediaViewer extends StatelessWidget {
  final String url;
  final bool isVideo;
  final VideoPlayerController? videoController;

  const StoryMediaViewer({
    super.key,
    required this.url,
    required this.isVideo,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.background.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                child: _buildMainMedia(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (isVideo && videoController != null && videoController!.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoController!.value.size.width,
              height: videoController!.value.size.height,
              child: VideoPlayer(videoController!),
            ),
          )
        else
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppColors.background),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMedia() {
    if (isVideo) {
      if (videoController != null && videoController!.value.isInitialized) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: videoController!.value.size.width,
            height: videoController!.value.size.height,
            child: VideoPlayer(videoController!),
          ),
        );
      } else {
        return const Center(
          child: LoadingView(),
        );
      }
    } else {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: LoadingView(),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error, color: AppColors.textPrimary),
        ),
      );
    }
  }
}
