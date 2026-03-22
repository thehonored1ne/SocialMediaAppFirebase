import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/features/reels/application/reel_controller.dart';
import '../widgets/reel_item.dart';

class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelsAsync = ref.watch(reelsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: reelsAsync.when(
        data: (reels) {
          if (reels.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, size: 80, color: AppColors.textTertiary),
                  SizedBox(height: 16),
                  Text('No reels yet', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: reels.length,
            itemBuilder: (context, index) {
              return ReelItem(reel: reels[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.primary))),
      ),
    );
  }
}
