import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/core/common/widgets/real_video_player.dart';
import 'package:social_media_app/features/posts/domain/models/post_model.dart';
import 'package:social_media_app/features/reels/application/reel_controller.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'reel_comments_sheet.dart';

class ReelItem extends ConsumerWidget {
  final PostModel reel;
  const ReelItem({super.key, required this.reel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";
    final isLiked = reel.likes.contains(currentUserId);

    return Stack(
      fit: StackFit.expand,
      children: [
        RealVideoPlayer(videoUrl: reel.imageUrl, isReel: true),
        
        _buildGradientOverlay(),

        _buildSideActions(context, ref, isLiked),

        _buildBottomInfo(context, ref),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildSideActions(BuildContext context, WidgetRef ref, bool isLiked) {
    return PositionedDirectional(
      end: 16,
      bottom: 110,
      child: Column(
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: reel.likes.length.toString(),
            color: isLiked ? Colors.redAccent : AppColors.textPrimary,
            onTap: () => ref.read(reelControllerProvider.notifier).likeReel(reel.postId, reel.likes),
          ),
          const SizedBox(height: 24),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Comments',
            onTap: () => _showComments(context),
          ),
          const SizedBox(height: 24),
          const _ActionButton(icon: Icons.send_rounded, label: 'Share'),
          const SizedBox(height: 24),
          const _ActionButton(icon: Icons.more_horiz, label: ''),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context, WidgetRef ref) {
    return PositionedDirectional(
      start: 16,
      bottom: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pushNamed(AppRoutes.profile, pathParameters: {'uid': reel.uid}),
                child: UserAvatar(username: reel.username, imageUrl: '', radius: 18),
              ),
              const SizedBox(width: 10),
              Text(
                reel.username,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reel.caption.isNotEmpty)
            Text(
              reel.caption,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelCommentsSheet(reelId: reel.postId),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = AppColors.textPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
