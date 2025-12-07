import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/conversation.dart';

final conversationsProvider = Provider<List<Conversation>>((ref) {
  // Mock data for now - will be replaced with actual data source
  return [
    Conversation(
      id: '1',
      contactName: 'Alice Johnson',
      contactAvatarUrl: '',
      lastMessage: 'Hey! Are you free to chat?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    Conversation(
      id: '2',
      contactName: 'Bob Smith',
      contactAvatarUrl: '',
      lastMessage: 'Thanks for the call yesterday!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isOnline: false,
    ),
    Conversation(
      id: '3',
      contactName: 'Carol Williams',
      contactAvatarUrl: '',
      lastMessage: 'See you tomorrow 👋',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isOnline: true,
    ),
    Conversation(
      id: '4',
      contactName: 'David Brown',
      contactAvatarUrl: '',
      lastMessage: 'Got it, thanks!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      isOnline: false,
    ),
    Conversation(
      id: '5',
      contactName: 'Emma Davis',
      contactAvatarUrl: '',
      lastMessage: 'Let me know when you\'re available',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 1,
      isOnline: false,
    ),
  ];
});
