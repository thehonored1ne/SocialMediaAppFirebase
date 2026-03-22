import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/features/story/domain/models/story_model.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import '../widgets/story_media_viewer.dart';

class StoryViewScreen extends ConsumerStatefulWidget {
  final List<StoryModel> stories;
  final String username;
  final String profileImage;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.username,
    required this.profileImage,
  });

  @override
  ConsumerState<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends ConsumerState<StoryViewScreen> {
  late List<StoryModel> _activeStories;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  Timer? _timer;
  double _percent = 0.0;

  @override
  void initState() {
    super.initState();
    _activeStories = List.from(widget.stories);
    _loadStory(story: _activeStories[_currentIndex]);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return '';
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 7) return '${date.day}/${date.month}';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'now';
  }

  void _loadStory({required StoryModel story}) {
    _timer?.cancel();
    setState(() => _percent = 0.0);

    if (story.isVideo) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(Uri.parse(story.url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.play();
            _startTimer(duration: _videoController!.value.duration);
          }
        });
    } else {
      _startTimer();
    }
  }

  void _startTimer({Duration duration = const Duration(seconds: 5)}) {
    const frameRate = Duration(milliseconds: 50);
    final totalTicks = duration.inMilliseconds / frameRate.inMilliseconds;
    final tickPercent = 1.0 / totalTicks;

    _timer = Timer.periodic(frameRate, (timer) {
      if (!mounted) return;
      setState(() {
        if (_percent + tickPercent < 1.0) {
          _percent += tickPercent;
        } else {
          _percent = 1.0;
          timer.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    setState(() {
      if (_currentIndex + 1 < _activeStories.length) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _loadStory(story: _activeStories[_currentIndex]);
    });
  }

  void _previousStory() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = 0;
      }
      _loadStory(story: _activeStories[_currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeStories.isEmpty) return const SizedBox.shrink();
    final story = _activeStories[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previousStory();
          } else if (details.globalPosition.dx > 2 * width / 3) {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: StoryMediaViewer(
                url: story.url,
                isVideo: story.isVideo,
                videoController: _videoController,
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.background.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 60,
              left: 10,
              right: 10,
              child: Row(
                children: _activeStories.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        value: entry.key == _currentIndex ? _percent : (entry.key < _currentIndex ? 1.0 : 0.0),
                        backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                        minHeight: 2,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  UserAvatar(username: story.username, imageUrl: story.profileImage, radius: 18),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        story.username,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getTimeAgo(story.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
