import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController passwordController = TextEditingController();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This action is permanent. All your posts, reels, stories, and profile data will be deleted forever.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary))),
          TextButton(onPressed: () => context.pop(true), child: const Text('Continue', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      final bool? authenticated = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Confirm Password', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to confirm deletion.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textTertiary)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => context.pop(false), child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary))),
            TextButton(
              onPressed: () async {
                final result = await ref.read(authControllerProvider.notifier).reauthenticate(passwordController.text.trim());
                if (result == "success") {
                  if (context.mounted) context.pop(true);
                } else {
                  if (context.mounted) {
                    SnackBarUtils.showError(context, result);
                  }
                }
              },
              child: const Text('Verify & Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );

      if (authenticated == true && context.mounted) {
        ref.read(authControllerProvider.notifier).deleteAccount();
        context.pop(); // Close settings screen
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingItem(Icons.person_outline, 'Personal Information'),
          _buildSettingItem(Icons.bookmark_border, 'Saved'),
          const Divider(color: AppColors.textTertiary, height: 32),

          _buildSectionHeader('Settings'),
          _buildSettingItem(Icons.notifications_none, 'Notifications'),
          _buildSettingItem(Icons.lock_outline, 'Privacy'),
          _buildSettingItem(Icons.security, 'Security'),
          _buildSettingItem(Icons.palette_outlined, 'Theme'),
          const Divider(color: AppColors.textTertiary, height: 32),

          _buildSectionHeader('Danger Zone'),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.textSecondary, size: 28),
            title: const Text('Log Out', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () async {
              bool? logout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Log Out', style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text('Are you sure you want to log out?', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => context.pop(false), child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary))),
                    TextButton(onPressed: () => context.pop(true), child: const Text('Log Out', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );

              if (logout == true) {
                ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.pop();
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 28),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: const Text('Permanent cleanup of all your data', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            onTap: () => _showDeleteAccountDialog(context, ref),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10, top: 10),
      child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 28),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
