/// @Branch: New Chat Screen Implementation
///
/// Start new conversations with users, search and select contacts
/// Includes user search, recent contacts, and group chat creation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/repositories/firebase_repository.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _recentContacts = [];
  final List<Map<String, dynamic>> _selectedUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUsers();
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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to start a chat')),
        );
        return;
      }

      // Load users from Firebase
      final usersData = await FirebaseRepository.getUsers();
      final recentChatRooms = await FirebaseRepository.getChatRooms(user.id);

      setState(() {
        _users = usersData
            .where((u) => u.id != user.id)
            .map(
              (user) => {
                'id': user.id,
                'name': '${user.firstName} ${user.lastName}',
                'email': user.email,
                'profileImage': user.profileImageUrl,
                'university': user.university ?? 'University',
                'isOnline': false, // You might want to implement online status
                'lastSeen': DateTime.now().toIso8601String(),
              },
            )
            .toList();

        // Extract recent contacts from chat rooms
        _recentContacts = recentChatRooms
            .where((room) => room['type'] == 'direct')
            .map((room) {
              final participants = room['participants'] as List<dynamic>? ?? [];
              final otherParticipant = participants.firstWhere(
                (p) => p['userId'] != user.id,
                orElse: () =>
                    participants.isNotEmpty ? participants.first : null,
              );

              if (otherParticipant != null) {
                return {
                  'id': otherParticipant['userId'],
                  'name': otherParticipant['name'],
                  'email': otherParticipant['email'],
                  'profileImage': otherParticipant['profileImageUrl'],
                  'university':
                      'University', // You might want to get this from user data
                  'isOnline': otherParticipant['isOnline'] ?? false,
                  'lastMessage': room['lastMessage']?['content'],
                  'lastMessageTime': room['lastMessage']?['timestamp'],
                };
              }
              return null;
            })
            .where((contact) => contact != null)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      // TODO: Implement searchUsers in SupabaseRepository
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Filter users based on search query
      final filteredUsers = _users.where((user) {
        final name = (user['name'] as String).toLowerCase();
        final email = (user['email'] as String).toLowerCase();
        final university = (user['university'] as String).toLowerCase();
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
            email.contains(searchLower) ||
            university.contains(searchLower);
      }).toList();

      setState(() {
        _users = filteredUsers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to start a chat')),
        );
        return;
      }

      // Create direct chat room
      final chatRoom = await chatProvider.createDirectChatRoom(
        currentUser.id,
        user['id'] as String,
      );

      if (chatRoom != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat started successfully')),
        );
        context.go('/chat/${chatRoom.id}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to start chat')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
      }
    }
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      final userId = user['id'] as String;
      if (_selectedUsers.any((u) => u['id'] == userId)) {
        _selectedUsers.removeWhere((u) => u['id'] == userId);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _startGroupChat() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    // TODO: Implement group chat creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group chat functionality coming soon')),
    );
  }

  List<Map<String, dynamic>> get _displayUsers {
    if (_searchQuery.isNotEmpty) {
      return _users;
    }
    return _recentContacts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.pop(),
    ),
    title: Text(
      'New Chat',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      if (_selectedUsers.isNotEmpty)
        TextButton(
          onPressed: _startGroupChat,
          child: Text(
            'Group (${_selectedUsers.length})',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    return Column(
      children: [
        _buildSearchBar(theme),
        if (_selectedUsers.isNotEmpty) _buildSelectedUsers(theme),
        Expanded(child: _buildUsersList(theme)),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Loading contacts...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchBar(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: TextField(
      controller: _searchController,
      onChanged: _searchUsers,
      decoration: InputDecoration(
        hintText: 'Search users by name, email, or university...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    ),
  );

  Widget _buildSelectedUsers(ThemeData theme) => Container(
    height: 80,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Users',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedUsers.length,
            itemBuilder: (context, index) {
              final user = _selectedUsers[index];
              return _buildSelectedUserChip(theme, user, index);
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildSelectedUserChip(
    ThemeData theme,
    Map<String, dynamic> user,
    int index,
  ) => Container(
    margin: const EdgeInsets.only(right: AppSpacing.sm),
    child: Chip(
      avatar: CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(user['profileImage'] as String),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image error
        },
      ),
      label: Text(user['name'] as String, style: theme.textTheme.bodySmall),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _toggleUserSelection(user),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      deleteIconColor: theme.colorScheme.primary,
    ),
  );

  Widget _buildUsersList(ThemeData theme) {
    final users = _displayUsers;

    if (users.isEmpty) {
      return _buildEmptyState(theme);
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildUserCard(theme, users[index], index),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _searchQuery.isNotEmpty ? 'No Users Found' : 'No Recent Contacts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching with a different term'
                : 'Start a conversation with someone new',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildUserCard(ThemeData theme, Map<String, dynamic> user, int index) {
    final isSelected = _selectedUsers.any((u) => u['id'] == user['id']);
    final isOnline = user['isOnline'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user['profileImage'] as String),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image error
              },
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user['name'] as String,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['university'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (user['lastMessage'] != null) ...[
              const SizedBox(height: 2),
              Text(
                user['lastMessage'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _searchQuery.isNotEmpty
            ? Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleUserSelection(user),
                activeColor: theme.colorScheme.primary,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user['lastMessageTime'] != null)
                    Text(
                      _formatTime(user['lastMessageTime'] as String),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (!isOnline)
                    Text(
                      'Last seen ${_formatLastSeen(user['lastSeen'] as String)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
        onTap: () {
          if (_searchQuery.isNotEmpty) {
            _toggleUserSelection(user);
          } else {
            _startChat(user);
          }
        },
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inDays == 0) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${time.day}/${time.month}';
      }
    } catch (e) {
      return timeString;
    }
  }

  String _formatLastSeen(String lastSeenString) {
    try {
      final lastSeen = DateTime.parse(lastSeenString);
      final now = DateTime.now();
      final difference = now.difference(lastSeen);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${lastSeen.day}/${lastSeen.month}';
      }
    } catch (e) {
      return lastSeenString;
    }
  }
}
