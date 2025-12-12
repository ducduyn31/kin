import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/conversation.dart';
import '../../availability/domain/availability_status.dart';

final conversationsProvider = Provider<List<Conversation>>((ref) {
  // Mock data for now - will be replaced with actual data source
  return [
    // Direct messages with availability status
    Conversation(
      id: '1',
      type: ConversationType.direct,
      displayName: 'Alice',
      avatarUrl: null,
      lastMessage: 'Hey! Are you free to chat?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      contactId: 'user-alice',
      contactStatus: AvailabilityStatus.free,
      contactStatusMessage: 'Free to chat!',
    ),
    // Circle group chat
    Conversation(
      id: 'conv-family',
      type: ConversationType.circle,
      circleId: 'circle-1',
      displayName: 'Family',
      avatarUrl: null,
      lastMessage: 'Mom: Don\'t forget dinner tonight!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      memberCount: 4,
    ),
    Conversation(
      id: '2',
      type: ConversationType.direct,
      displayName: 'Bob',
      avatarUrl: null,
      lastMessage: 'Talk later, in a meeting',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      contactId: 'user-bob',
      contactStatus: AvailabilityStatus.busy,
      contactStatusMessage: 'In a meeting',
    ),
    // Circle group chat
    Conversation(
      id: 'conv-friends',
      type: ConversationType.circle,
      circleId: 'circle-2',
      displayName: 'Close Friends',
      avatarUrl: null,
      lastMessage: 'Diana: Weekend plans?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      memberCount: 5,
    ),
    Conversation(
      id: '3',
      type: ConversationType.direct,
      displayName: 'Mom',
      avatarUrl: null,
      lastMessage: 'Call me when you can',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      contactId: 'user-mom',
      contactStatus: AvailabilityStatus.free,
      contactStatusMessage: 'At home',
    ),
    Conversation(
      id: '4',
      type: ConversationType.direct,
      displayName: 'Charlie',
      avatarUrl: null,
      lastMessage: 'Good night!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      contactId: 'user-charlie',
      contactStatus: AvailabilityStatus.sleeping,
    ),
  ];
});
