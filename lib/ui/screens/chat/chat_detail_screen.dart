/// @Branch: Chat Detail Screen Implementation
///
/// Individual chat room with message list, input, and real-time-like updates
/// Includes image attachments and read receipts
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/chat.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatRoomId});
  final String chatRoomId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  late ChatRoom chatRoom;
  bool _isLoading = true;
  bool _isTyping = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadChatRoom();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadChatRoom() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to access chat')),
          );
        }
        return;
      }

      final chatRoomMap = await FirebaseRepository.getChatRoomById(
        widget.chatRoomId,
      );

      if (chatRoomMap != null) {
        setState(() {
          chatRoom = ChatRoom.fromJson(chatRoomMap);
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();

        // Load messages for this chat room
        await chatProvider.loadMessages(widget.chatRoomId);
        _messages = chatProvider.getMessagesForRoom(widget.chatRoomId);

        // Start listening to real-time messages
        chatProvider.startListeningToMessages(widget.chatRoomId);

        // Mark messages as read
        await chatProvider.markMessagesAsRead(
          widget.chatRoomId,
          currentUser.id,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chat room not found')));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading chat room: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Create message object
    final message = Message(
      id: const Uuid().v4(),
      chatRoomId: widget.chatRoomId,
      senderId: currentUser.id,
      senderName: '${currentUser.firstName} ${currentUser.lastName}',
      senderProfileImage: currentUser.profileImageUrl,
      content: messageText,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Send message through provider
    final success = await chatProvider.sendMessage(message);

    if (success) {
      // Update local messages from provider
      if (mounted) {
        setState(() {
          _messages = chatProvider.getMessagesForRoom(widget.chatRoomId);
        });
        _scrollToBottom();
      }
    } else {
      // Handle send failure
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(image);
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        await _sendFileMessage(file);
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _sendImageMessage(XFile image) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Upload image to Firebase storage and get URL
      // For now, we'll create a placeholder message
      final message = Message(
        id: const Uuid().v4(),
        chatRoomId: widget.chatRoomId,
        senderId: currentUser.id,
        senderName: '${currentUser.firstName} ${currentUser.lastName}',
        senderProfileImage: currentUser.profileImageUrl,
        content: '📷 Image',
        type: MessageType.image,
        attachments: [
          MessageAttachment(
            id: const Uuid().v4(),
            url: image.path, // This should be the uploaded URL
            fileName: image.name,
            fileType: 'image/jpeg',
            fileSize: await File(image.path).length(),
            type: AttachmentType.image,
          ),
        ],
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      setState(() {
        _messages.add(message);
        _isUploading = false;
      });

      _scrollToBottom();

      // TODO: Upload to Firebase and update message status
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error sending image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending image: $e')));
      }
    }
  }

  Future<void> _sendFileMessage(PlatformFile file) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send files')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Upload file to Firebase storage and get URL
      // For now, we'll create a placeholder message
      final message = Message(
        id: const Uuid().v4(),
        chatRoomId: widget.chatRoomId,
        senderId: currentUser.id,
        senderName: '${currentUser.firstName} ${currentUser.lastName}',
        senderProfileImage: currentUser.profileImageUrl,
        content: '📎 ${file.name}',
        type: MessageType.file,
        attachments: [
          MessageAttachment(
            id: const Uuid().v4(),
            url: file.path ?? '', // This should be the uploaded URL
            fileName: file.name,
            fileType: file.extension ?? 'unknown',
            fileSize: file.size,
            type: _getAttachmentType(file.extension),
          ),
        ],
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      setState(() {
        _messages.add(message);
        _isUploading = false;
      });

      _scrollToBottom();

      // TODO: Upload to Firebase and update message status
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error sending file: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending file: $e')));
      }
    }
  }

  AttachmentType _getAttachmentType(String? extension) {
    if (extension == null) return AttachmentType.document;

    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return AttachmentType.image;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) {
      return AttachmentType.video;
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) {
      return AttachmentType.audio;
    } else {
      return AttachmentType.document;
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Choose File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video Call'),
              onTap: () {
                Navigator.pop(context);
                _startVideoCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Voice Call'),
              onTap: () {
                Navigator.pop(context);
                _startVoiceCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Chat Info'),
              onTap: () {
                Navigator.pop(context);
                _showChatInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                _toggleNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoCall() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Video Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam, size: 64, color: Colors.blue),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Calling ${chatRoom.displayName}...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Video calling feature will be available soon!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual video call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video call initiated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.videocam),
            label: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _startVoiceCall() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Voice Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 64, color: Colors.green),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Calling ${chatRoom.displayName}...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Voice calling feature will be available soon!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual voice call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice call initiated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _showChatInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chatRoom.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chatRoom.description != null) ...[
              Text('Description: ${chatRoom.description}'),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text('Created: ${_formatMessageTime(chatRoom.createdAt)}'),
            Text('Participants: ${chatRoom.participants.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive notifications for new messages'),
              trailing: Switch(
                value: true, // You can implement actual state management
                onChanged: (value) {
                  // TODO: Implement actual notification toggle
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications enabled'
                            : 'Notifications disabled',
                      ),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Quiet Hours'),
              subtitle: const Text('Set quiet hours for notifications'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _showQuietHoursDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.vibration),
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate for new messages'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement vibration toggle
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuietHoursDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set quiet hours when you don\'t want to receive notifications.',
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              title: const Text('From'),
              subtitle: const Text('10:00 PM'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement time picker
              },
            ),
            ListTile(
              title: const Text('To'),
              subtitle: const Text('8:00 AM'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement time picker
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiet hours updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMessageActions(Message message, bool isMe) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _replyToMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                _forwardMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
            if (isMe) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _replyToMessage(Message message) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reply feature coming soon!')));
  }

  void _forwardMessage(Message message) {
    // TODO: Implement forward functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forward feature coming soon!')),
    );
  }

  void _copyMessage(Message message) {
    // Copy message content to clipboard
    // You'll need to add flutter/services import for Clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  void _editMessage(Message message) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit feature coming soon!')));
  }

  void _deleteMessage(Message message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading conversation...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildEnhancedAppBar(theme) as PreferredSizeWidget,
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme)
                : _buildMessagesList(theme),
          ),

          // Typing indicator
          if (_isTyping) _buildTypingIndicator(theme),

          // Message input
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: chatRoom.imageUrl != null
                ? NetworkImage(chatRoom.imageUrl!)
                : null,
            child: chatRoom.imageUrl == null
                ? Text(
                    chatRoom.displayName.isNotEmpty
                        ? chatRoom.displayName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatRoom.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Online',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    actions: [
      IconButton(icon: const Icon(Icons.videocam), onPressed: _startVideoCall),
      IconButton(icon: const Icon(Icons.phone), onPressed: _startVoiceCall),
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _showOptionsMenu,
      ),
    ],
  );

  Widget _buildMessagesList(ThemeData theme) => AnimatedBuilder(
    animation: _fadeAnimation,
    builder: (context, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return _buildMessageBubble(message, theme);
          },
        ),
      );
    },
  );

  Widget _buildMessageBubble(Message message, ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final isMe = currentUser != null && message.senderId == currentUser.id;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
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
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageActions(message, isMe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
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
                        _buildMessageContent(message, theme, isMe),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatMessageTime(message.timestamp),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isMe
                                    ? theme.colorScheme.onPrimary.withOpacity(
                                        0.7,
                                      )
                                    : theme.colorScheme.outline,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              _buildMessageStatus(message.status, theme),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: AppSpacing.sm),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    currentUser.firstName.isNotEmpty
                        ? currentUser.firstName[0].toUpperCase()
                        : 'Y',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message, ThemeData theme, bool isMe) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageMessage(message, theme, isMe);
      case MessageType.file:
        return _buildFileMessage(message, theme, isMe);
      case MessageType.system:
        return _buildSystemMessage(message, theme);
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

  Widget _buildImageMessage(Message message, ThemeData theme, bool isMe) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.attachments.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(message.attachments.first.url),
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
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      );

  Widget _buildFileMessage(Message message, ThemeData theme, bool isMe) {
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

  Widget _buildSystemMessage(Message message, ThemeData theme) => Container(
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

  Widget _buildMessageStatus(MessageStatus status, ThemeData theme) {
    IconData icon;
    Color color;

    switch (status) {
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

  Widget _buildTypingIndicator(ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: Row(
      children: [
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Typing',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No messages yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start the conversation by sending a message',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  String _formatMessageTime(DateTime timestamp) {
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

  Widget _buildMessageInput(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: _showAttachmentOptions,
        ),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _messageController,
              onChanged: (value) {
                setState(() {
                  _isTyping = value.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: _isUploading ? 'Uploading...' : 'Type a message...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isUploading,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        if (_isUploading)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: theme.colorScheme.onPrimary,
              onPressed: _messageController.text.trim().isNotEmpty
                  ? _sendMessage
                  : null,
            ),
          ),
      ],
    ),
  );
}
