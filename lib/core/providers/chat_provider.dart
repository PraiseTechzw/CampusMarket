/// @Branch: Chat Provider Implementation
///
/// State management for chat functionality
/// Handles chat rooms, messages, and real-time updates
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../repositories/firebase_repository.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  Map<String, List<Message>> _messages = {};
  Map<String, StreamSubscription<QuerySnapshot>> _messageSubscriptions = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  Map<String, List<Message>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Message> getMessagesForRoom(String chatRoomId) {
    return _messages[chatRoomId] ?? [];
  }

  int getUnreadCount() {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }

  // Load chat rooms for a user
  Future<void> loadChatRooms(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final chatRoomData = await FirebaseRepository.getChatRooms(userId);
      _chatRooms = chatRoomData.map((data) => ChatRoom.fromJson(data)).toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat rooms: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for a specific chat room
  Future<void> loadMessages(String chatRoomId) async {
    try {
      final messageData = await FirebaseRepository.getMessages(chatRoomId);
      _messages[chatRoomId] = messageData
          .map((data) => Message.fromJson(data))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load messages: $e');
    }
  }

  // Start listening to real-time messages for a chat room
  void startListeningToMessages(String chatRoomId) {
    if (_messageSubscriptions.containsKey(chatRoomId)) {
      return; // Already listening
    }

    final subscription = FirebaseFirestore.instance
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            final messages = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Message.fromJson(data);
            }).toList();

            _messages[chatRoomId] = messages;
            notifyListeners();
          },
          onError: (Object error) {
            _setError('Failed to listen to messages: $error');
          },
        );

    _messageSubscriptions[chatRoomId] = subscription;
  }

  // Stop listening to messages for a chat room
  void stopListeningToMessages(String chatRoomId) {
    _messageSubscriptions[chatRoomId]?.cancel();
    _messageSubscriptions.remove(chatRoomId);
  }

  // Send a message
  Future<bool> sendMessage(Message message) async {
    try {
      final messageData = message.toJson();
      final sentMessage = await FirebaseRepository.sendMessage(messageData);

      if (sentMessage != null) {
        // Add to local messages immediately for better UX
        _messages[message.chatRoomId] ??= [];
        _messages[message.chatRoomId]!.add(message);
        notifyListeners();

        // Update the message with the actual data from server
        final index = _messages[message.chatRoomId]!.indexWhere(
          (m) => m.id == message.id,
        );
        if (index != -1) {
          _messages[message.chatRoomId]![index] = Message.fromJson(sentMessage);
          notifyListeners();
        }

        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to send message: $e');
      return false;
    }
  }

  // Create a new chat room
  Future<ChatRoom?> createChatRoom(Map<String, dynamic> chatRoomData) async {
    try {
      final createdRoom = await FirebaseRepository.createChatRoom(chatRoomData);
      if (createdRoom != null) {
        final chatRoom = ChatRoom.fromJson(createdRoom);
        _chatRooms.insert(0, chatRoom);
        notifyListeners();
        return chatRoom;
      }
      return null;
    } catch (e) {
      _setError('Failed to create chat room: $e');
      return null;
    }
  }

  // Create a direct chat room
  Future<ChatRoom?> createDirectChatRoom(String userId1, String userId2) async {
    try {
      final createdRoom = await FirebaseRepository.createDirectChatRoom(
        userId1,
        userId2,
      );
      if (createdRoom != null) {
        final chatRoom = ChatRoom.fromJson(createdRoom);

        // Check if chat room already exists in the list
        final existingIndex = _chatRooms.indexWhere(
          (room) => room.id == chatRoom.id,
        );
        if (existingIndex != -1) {
          _chatRooms[existingIndex] = chatRoom;
        } else {
          _chatRooms.insert(0, chatRoom);
        }

        notifyListeners();
        return chatRoom;
      }
      return null;
    } catch (e) {
      _setError('Failed to create direct chat room: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      await FirebaseRepository.markChatRoomAsRead(chatRoomId, userId);

      // Update local unread counts
      final roomIndex = _chatRooms.indexWhere((room) => room.id == chatRoomId);
      if (roomIndex != -1) {
        final room = _chatRooms[roomIndex];
        final updatedUnreadCounts = Map<String, int>.from(room.unreadCounts);
        updatedUnreadCounts[userId] = 0;

        _chatRooms[roomIndex] = ChatRoom(
          id: room.id,
          name: room.name,
          description: room.description,
          imageUrl: room.imageUrl,
          type: room.type,
          participantIds: room.participantIds,
          participants: room.participants,
          lastMessage: room.lastMessage,
          createdAt: room.createdAt,
          updatedAt: room.updatedAt,
          isActive: room.isActive,
          unreadCounts: updatedUnreadCounts,
        );

        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark messages as read: $e');
    }
  }

  // Add reaction to a message
  Future<void> addReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    try {
      await FirebaseRepository.addReaction(messageId, userId, emoji);
      // The real-time listener will update the UI
    } catch (e) {
      _setError('Failed to add reaction: $e');
    }
  }

  // Remove reaction from a message
  Future<void> removeReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    try {
      await FirebaseRepository.removeReaction(messageId, userId, emoji);
      // The real-time listener will update the UI
    } catch (e) {
      _setError('Failed to remove reaction: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId, String chatRoomId) async {
    try {
      await FirebaseRepository.deleteMessage(messageId);

      // Remove from local messages
      _messages[chatRoomId]?.removeWhere((message) => message.id == messageId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete message: $e');
    }
  }

  // Search chat rooms
  List<ChatRoom> searchChatRooms(String query) {
    if (query.isEmpty) return _chatRooms;

    return _chatRooms.where((room) {
      return room.name.toLowerCase().contains(query.toLowerCase()) ||
          room.participants.any(
            (participant) =>
                participant.name.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();
  }

  // Clear all data
  void clearData() {
    _chatRooms.clear();
    _messages.clear();
    _messageSubscriptions.values.forEach(
      (subscription) => subscription.cancel(),
    );
    _messageSubscriptions.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _messageSubscriptions.values.forEach(
      (subscription) => subscription.cancel(),
    );
    super.dispose();
  }
}
