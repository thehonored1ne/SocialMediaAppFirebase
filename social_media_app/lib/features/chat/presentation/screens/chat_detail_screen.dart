import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/core/common/widgets/loading_view.dart';
import 'package:social_media_app/core/constants/app_colors.dart';
import 'package:social_media_app/features/auth/application/auth_controller.dart';
import 'package:social_media_app/features/chat/application/chat_controller.dart';
import 'package:social_media_app/features/profile/application/profile_controller.dart';
import 'package:social_media_app/core/common/widgets/user_avatar.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserImage;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage = '',
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).markAsSeen(_getChatId());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getChatId() {
    final currentUserId = ref.read(authStateChangesProvider).value?.uid ?? "";
    List<String> ids = [currentUserId, widget.otherUserId];
    ids.sort();
    return ids.join("_");
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = ref.read(authStateChangesProvider).value?.uid ?? "";
    
    ref.read(chatControllerProvider.notifier).sendMessage(
      chatId: _getChatId(),
      receiverId: widget.otherUserId,
      text: text,
      usersInfo: {
        currentUserId: {'name': 'User', 'image': ''}, 
        widget.otherUserId: {'name': widget.otherUserName, 'image': widget.otherUserImage},
      },
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _getChatId();
    final messagesAsync = ref.watch(messagesStreamProvider(chatId));
    final profileAsync = ref.watch(profileProvider(widget.otherUserId));
    final currentUserId = ref.watch(authStateChangesProvider).value?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: profileAsync.when(
          data: (user) => Row(
            children: [
              UserAvatar(username: user.username, imageUrl: user.profileImage, radius: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.username, 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text('Active now', 
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => Text(widget.otherUserName, style: const TextStyle(fontSize: 16)),
          error: (_, _) => Text(widget.otherUserName),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet', style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == currentUserId;
                    return _MessageBubble(isMe: isMe, text: msg.text, timestamp: msg.timestamp);
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            ),
          ),
          _InputArea(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final DateTime? timestamp;

  const _MessageBubble({required this.isMe, required this.text, required this.timestamp});

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe ? const LinearGradient(colors: AppColors.primaryGradient) : null,
              color: isMe ? null : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
            ),
            child: Text(text, 
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary, 
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4, end: 4),
            child: Text(_formatTime(timestamp), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputArea({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: AppColors.primaryGradient),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
