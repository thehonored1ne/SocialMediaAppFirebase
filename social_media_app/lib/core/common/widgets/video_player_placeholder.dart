import 'package:flutter/material.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';

class VideoPlayerPlaceholder extends StatefulWidget {
  const VideoPlayerPlaceholder({super.key});

  @override
  State<VideoPlayerPlaceholder> createState() => _VideoPlayerPlaceholderState();
}

class _VideoPlayerPlaceholderState extends State<VideoPlayerPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            'https://picsum.photos/500/500?grayscale',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: AppColors.background.withValues(alpha: 0.5),
            colorBlendMode: BlendMode.darken,
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.textPrimary, size: 40),
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: const Text(
                'Video',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}
