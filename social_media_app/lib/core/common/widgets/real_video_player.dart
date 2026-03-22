import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:social_media_app/core/constants/app_colors.dart';

class RealVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isReel;
  const RealVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isReel = false,
  });

  @override
  State<RealVideoPlayer> createState() => _RealVideoPlayerState();
}

class _RealVideoPlayerState extends State<RealVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0); 
          _controller.play();
        }
      });
    
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return;
    
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.setVolume(1.0);
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isReel ? double.infinity : 350,
      width: double.infinity,
      color: AppColors.background,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            const CircularProgressIndicator(color: AppColors.textTertiary),
          
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePlay,
                splashColor: AppColors.textPrimary.withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
              ),
            ),
          ),
          
          if (_isInitialized && _controller.value.volume == 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_off, color: AppColors.textPrimary, size: 16),
              ),
            ),

          if (_isInitialized && !_controller.value.isPlaying)
            IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.textPrimary, size: 60),
              ),
            ),
        ],
      ),
    );
  }
}
