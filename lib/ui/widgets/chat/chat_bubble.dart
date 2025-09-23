/// @Branch: Chat Bubble Widget
///
/// Reusable chat message bubble component
/// Handles different message types and styling
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/chat.dart';
import '../../../core/providers/auth_provider.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onLongPress,
    this.showAvatar = true,
  });

  final Message message;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final isMe = currentUser != null && message.senderId == currentUser.id;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar) ...[
              _buildAvatar(theme),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(child: _buildMessageBubble(theme, isMe)),
            if (isMe && showAvatar) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildAvatar(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundImage: message.senderProfileImage != null
          ? NetworkImage(message.senderProfileImage!)
          : null,
      child: message.senderProfileImage == null
          ? Text(
              message.senderName.isNotEmpty
                  ? message.senderName[0].toUpperCase()
                  : '?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(ThemeData theme, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: isMe
              ? const Radius.circular(20)
              : const Radius.circular(4),
          bottomRight: isMe
              ? const Radius.circular(4)
              : const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(theme, isMe),
          const SizedBox(height: 4),
          _buildMessageFooter(theme, isMe),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, bool isMe) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageContent(theme, isMe);
      case MessageType.file:
        return _buildFileContent(theme, isMe);
      case MessageType.system:
        return _buildSystemContent(theme);
      default:
        return Text(
          message.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isMe
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        );
    }
  }

  Widget _buildImageContent(ThemeData theme, bool isMe) {
    if (message.attachments.isEmpty) {
      return Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isMe
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      );
    }

    final attachment = message.attachments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            attachment.url,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.broken_image,
                  color: theme.colorScheme.outline,
                  size: 48,
                ),
              );
            },
          ),
        ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileContent(ThemeData theme, bool isMe) {
    if (message.attachments.isEmpty) {
      return Text(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isMe
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      );
    }

    final attachment = message.attachments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.onPrimary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMe
                  ? theme.colorScheme.onPrimary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getFileIcon(attachment.type),
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      attachment.formattedFileSize,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isMe
                            ? theme.colorScheme.onPrimary.withOpacity(0.7)
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSystemContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Text(
        message.content,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageFooter(ThemeData theme, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isMe
                ? theme.colorScheme.onPrimary.withOpacity(0.7)
                : theme.colorScheme.outline,
          ),
        ),
        if (isMe) ...[const SizedBox(width: 4), _buildMessageStatus(theme)],
      ],
    );
  }

  Widget _buildMessageStatus(ThemeData theme) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = theme.colorScheme.outline;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = theme.colorScheme.outline;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = theme.colorScheme.outline;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = theme.colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = theme.colorScheme.error;
        break;
    }

    return Icon(icon, size: 12, color: color);
  }

  IconData _getFileIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image;
      case AttachmentType.video:
        return Icons.videocam;
      case AttachmentType.audio:
        return Icons.audiotrack;
      case AttachmentType.document:
        return Icons.description;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}





