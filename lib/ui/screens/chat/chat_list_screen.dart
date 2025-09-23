/// @Branch: Chat List Screen Implementation
///
/// Chat rooms listing with real-time-like updates
/// Displays conversations with unread counts and last messages
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/chat.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  List<ChatRoom> _chatRooms = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _searchAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadChatRooms();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _searchAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      setState(() {
        _chatRooms = <ChatRoom>[];
        _isLoading = false;
      });
      return;
    }

    await chatProvider.loadChatRooms(currentUser.id);

    setState(() {
      _chatRooms = chatProvider.chatRooms;
      _isLoading = chatProvider.isLoading;
    });

    if (!_isLoading) {
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with search
          _buildEnhancedAppBar(theme),

          // Search Bar
          _buildSearchBar(theme),

          // Chat rooms list
          _buildChatRoomsList(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/chat/new');
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('New Chat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEnhancedAppBar(ThemeData theme) => SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: theme.colorScheme.onPrimary,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Messages',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          _searchAnimationController.forward();
        },
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // TODO: Show options menu
        },
      ),
    ],
  );

  Widget _buildSearchBar(ThemeData theme) => SliverToBoxAdapter(
    child: AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _searchAnimation,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterChatRooms();
              },
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterChatRooms();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildChatRoomsList(ThemeData theme) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_chatRooms.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(theme));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final chatRoom = _chatRooms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildChatRoomCard(chatRoom, theme),
          );
        }, childCount: _chatRooms.length),
      ),
    );
  }

  Widget _buildChatRoomCard(
    ChatRoom chatRoom,
    ThemeData theme,
  ) => AnimatedBuilder(
    animation: _fadeAnimation,
    builder: (context, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/chat/${chatRoom.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Avatar
                    _buildAvatar(chatRoom, theme),
                    const SizedBox(width: AppSpacing.md),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  chatRoom.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTime(chatRoom.lastMessage?.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          // Last message
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chatRoom.lastMessage?.content ??
                                      'No messages yet',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (chatRoom.unreadCount > 0) ...[
                                const SizedBox(width: AppSpacing.sm),
                                _buildUnreadBadge(chatRoom.unreadCount, theme),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _buildAvatar(ChatRoom chatRoom, ThemeData theme) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.7),
        ],
      ),
    ),
    child: chatRoom.participants.isNotEmpty
        ? CircleAvatar(
            backgroundImage: chatRoom.participants.first.profileImageUrl != null
                ? NetworkImage(chatRoom.participants.first.profileImageUrl!)
                : null,
            child: chatRoom.participants.first.profileImageUrl == null
                ? Text(
                    chatRoom.participants.first.name.isNotEmpty
                        ? chatRoom.participants.first.name[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          )
        : Icon(Icons.group, color: theme.colorScheme.onPrimary),
  );

  Widget _buildUnreadBadge(int count, ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      count > 99 ? '99+' : count.toString(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _filterChatRooms() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final filteredRooms = chatProvider.searchChatRooms(_searchQuery);

    setState(() {
      _chatRooms = filteredRooms;
    });
  }

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
            'No conversations yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a conversation by contacting a seller or host',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/chat/new');
            },
            icon: const Icon(Icons.add_comment),
            label: const Text('Start New Chat'),
          ),
        ],
      ),
    ),
  );
}
