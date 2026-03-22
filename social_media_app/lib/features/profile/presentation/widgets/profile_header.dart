import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/posts/application/post_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';

class ProfileHeader extends ConsumerWidget {
  final String uid;
  const ProfileHeader({super.key, required this.uid});

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(uid));
    final stats = ref.watch(profileStatsProvider(uid));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid;
    final isFollowing = ref.watch(isFollowingUserProvider(uid)).valueOrNull ?? false;
    final isMe = uid == currentUserId;
    final textTheme = Theme.of(context).textTheme;

    return profileAsync.when(
      data: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 38),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: 'Posts', value: _formatNumber(stats.posts)),
                          _StatItem(label: 'Likes', value: _formatNumber(stats.likes)),
                          _StatItem(label: 'Followers', value: _formatNumber(user.followers)),
                          _StatItem(label: 'Following', value: _formatNumber(user.following)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.username, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(user.bio, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4)),
                if (user.portfolioUrl != null || user.githubUsername != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (user.portfolioUrl != null && user.portfolioUrl!.isNotEmpty)
                        _LinkChip(
                          icon: Icons.language_rounded,
                          label: 'Portfolio',
                          onTap: () => _launchURL(user.portfolioUrl!),
                        ),
                      if (user.githubUsername != null && user.githubUsername!.isNotEmpty) ...[
                        if (user.portfolioUrl != null && user.portfolioUrl!.isNotEmpty) const SizedBox(width: 8),
                        _LinkChip(
                          icon: Icons.code_rounded,
                          label: user.githubUsername!,
                          onTap: () => _launchURL(user.githubUsername!), // Fixed: logic below handles full URL
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileActionButton(
                        text: isMe ? 'Edit Profile' : (isFollowing ? 'Unfollow' : 'Follow'),
                        isPrimary: isMe || !isFollowing,
                        onTap: () {
                          if (isMe) {
                            context.pushNamed(AppRoutes.editProfile, extra: user);
                          } else {
                            ref.read(postControllerProvider.notifier).followUser(uid);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProfileActionButton(
                        text: isMe ? 'Share Profile' : 'Message',
                        isPrimary: false,
                        onTap: () {
                          if (!isMe) {
                            context.pushNamed(AppRoutes.chat, extra: {
                              'otherUserId': uid,
                              'otherUserName': user.username,
                              'otherUserImage': user.profileImage,
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  Future<void> _launchURL(String query) async {
    String url = query;
    if (!query.startsWith('http')) {
      url = 'https://github.com/$query';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _LinkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ProfileActionButton({required this.text, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: isPrimary ? Colors.transparent : AppColors.textPrimary.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
      ),
    );
  }
}
