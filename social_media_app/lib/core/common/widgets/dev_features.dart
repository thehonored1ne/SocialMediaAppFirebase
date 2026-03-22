import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/utils/snackbar_utils.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DevCodeSnippet extends StatelessWidget {
  final String code;
  final String language;

  const DevCodeSnippet({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        color: AppColors.codeBackground,
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Divider(height: 1, color: AppColors.textPrimary.withValues(alpha: 0.1)),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: HighlightView(
                    code,
                    language: language,
                    theme: atomOneDarkTheme,
                    textStyle: GoogleFonts.firaCode(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language.toUpperCase(),
            style: GoogleFonts.firaCode(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              SnackBarUtils.showInfo(context, 'Copied to clipboard');
            },
          ),
        ],
      ),
    );
  }
}

class GithubRepoList extends ConsumerWidget {
  final String username;
  const GithubRepoList({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final reposAsync = ref.watch(githubTopReposProvider(username));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "TOP REPOSITORIES",
            style: GoogleFonts.firaCode(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: reposAsync.when(
            data: (repos) {
              if (repos.isEmpty) return const Center(child: Text("No repos found", style: TextStyle(color: AppColors.textSecondary)));

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                  scrollbars: false,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: repos.length,
                  itemBuilder: (context, index) {
                    final repo = repos[index];
                    return _buildRepoCard(context, repo);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: AppColors.error))),
          ),
        ),
      ],
    );
  }

  Widget _buildRepoCard(BuildContext context, dynamic repo) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repo['name'] ?? '',
            style: GoogleFonts.firaCode(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            repo['description'] ?? "No description provided",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_border, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "${repo['stargazers_count']}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                repo['language'] ?? 'Unknown',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DevProfileButton extends StatelessWidget {
  final String label;
  final String url;
  final IconData icon;

  const DevProfileButton({
    super.key,
    required this.label,
    required this.url,
    required this.icon,
  });

  Future<void> _launch() async {
    String formattedUrl = url;
    if (!url.startsWith('http')) {
      formattedUrl = 'https://$url';
    }
    
    final Uri uri = Uri.parse(formattedUrl);
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Could not launch $formattedUrl: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _launch,
      icon: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(
        label.toUpperCase(),
        style: GoogleFonts.firaCode(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}
