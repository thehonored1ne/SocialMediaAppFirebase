import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/router/app_routes.dart';
import 'package:social_media_app/core/providers/scroll_notifier.dart';

class RootScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  // We can still use the key to scroll to top, but we need to manage it differently
  // if FeedScreen is inside the shell. For simplicity in this refactor, 
  // we'll focus on the GoRouter integration first.

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Create',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                ),
                const Divider(color: AppColors.textTertiary),
                _buildMenuTile(
                  icon: Icons.grid_on_rounded,
                  title: 'Post',
                  onTap: () {
                    context.pop();
                    context.pushNamed(AppRoutes.createPost);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Story',
                  onTap: () {
                    context.pop();
                    context.pushNamed(AppRoutes.createStory);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.video_library_outlined,
                  title: 'Reel',
                  onTap: () {
                    context.pop();
                    context.pushNamed(AppRoutes.createReel);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.groups_outlined,
                  title: 'Community',
                  onTap: () {
                    context.pop();
                    context.pushNamed(AppRoutes.createCommunity);
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile _buildMenuTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
          height: 65,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home_filled, Icons.home_outlined, 0),
                  _buildNavItem(Icons.search, Icons.search_outlined, 1),
                  _buildAddButton(),
                  _buildNavItem(
                      Icons.video_library, Icons.video_library_outlined, 2),
                  _buildNavItem(Icons.person, Icons.person_outline, 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isSelected = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }

  void _onTap(int index) {
    if (index == 0 && widget.navigationShell.currentIndex == 0) {
      ref.read(homeScrollNotifierProvider.notifier).trigger();
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showCreateMenu,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
