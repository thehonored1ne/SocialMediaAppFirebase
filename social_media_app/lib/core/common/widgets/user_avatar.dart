import 'package:flutter/material.dart';
import 'package:social_media_app/core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double radius;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.username,
    this.radius = 20,
  });

  Color _getAvatarColor(String name) {
    // Replaced hardcoded Colors with a logic-based selection from existing palette or similar shades
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      const Color(0xFF4A90E2),
      const Color(0xFF50E3C2),
      const Color(0xFFF5A623),
      const Color(0xFFB8E986),
      const Color(0xFFBD10E0),
    ];
    return colors[name.length % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getAvatarColor(username),
      child: Text(
        _getInitials(username),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
