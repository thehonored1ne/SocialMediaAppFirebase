import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';
import 'package:social_media_app/features/reels/application/reel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/posts/domain/models/comment_model.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';

class ReelCommentsSheet extends ConsumerStatefulWidget {
  final String reelId;
  const ReelCommentsSheet({super.key, required this.reelId});

  @override
  ConsumerState<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends ConsumerState<ReelCommentsSheet> {
  final _commentController = TextEditingController();
  CommentModel? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final effectiveParentId = _replyingTo?.parentId ?? _replyingTo?.commentId;
    final prefix = (_replyingTo?.parentId != null) ? '@${_replyingTo!.username} ' : '';

    ref.read(reelControllerProvider.notifier).postComment(
          reelId: widget.reelId,
          text: '$prefix$text',
          parentId: effectiveParentId,
        );
    _commentController.clear();
    setState(() => _replyingTo = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(reelCommentsProvider(widget.reelId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(color: Colors.white10),
          Expanded(
            child: commentsAsync.when(
              data: (allComments) {
                final mainComments = allComments.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: mainComments.length,
                  itemBuilder: (context, index) {
                    final comment = mainComments[index];
                    final replies = allComments
                        .where((c) => c.parentId == comment.commentId)
                        .toList()
                      ..sort((a, b) => (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CommentTile(
                          comment: comment,
                          reelId: widget.reelId,
                          onReply: () => setState(() => _replyingTo = comment),
                        ),
                        if (replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 44),
                            child: Column(
                              children: replies.map((reply) => _CommentTile(
                                comment: reply,
                                reelId: widget.reelId,
                                isReply: true,
                                onReply: () => setState(() => _replyingTo = reply),
                              )).toList(),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Comments',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.username}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              left: 16,
              right: 16,
              top: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    autofocus: _replyingTo != null,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  final CommentModel comment;
  final String reelId;
  final bool isReply;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.reelId,
    this.isReply = false,
    required this.onReply,
  });

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    final DateTime date;
    if (ts is Timestamp) {
      date = ts.toDate();
    } else if (ts is DateTime) {
      date = ts;
    } else {
      return '';
    }
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";
    final isLiked = comment.likes.contains(currentUserId);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isReply ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            username: comment.username,
            imageUrl: comment.profileImage,
            radius: isReply ? 14 : 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.timestamp),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isReply ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(reelControllerProvider.notifier).likeComment(
                            reelId: reelId,
                            commentId: comment.commentId,
                            likes: comment.likes,
                          ),
                      child: Text(
                        'Like',
                        style: TextStyle(
                          color: isLiked ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: const Text(
                        'Reply',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                    if (comment.likes.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likes.length}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
