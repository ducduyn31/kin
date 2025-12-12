import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/conversation.dart';
import '../../availability/domain/availability_status.dart';

class ConversationsNotifier extends Notifier<List<Conversation>> {
  @override
  List<Conversation> build() => List.unmodifiable(_mockConversations);
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

// Fixed timestamps for deterministic mock data (ordered most recent to oldest)
final _mockConversations = [
  Conversation(
    id: '1',
    type: ConversationType.direct,
    displayName: 'Alice',
    avatarUrl: null,
    lastMessage: 'Hey! Are you free to chat?',
    lastMessageTime: DateTime.utc(2024, 1, 15, 14, 55),
    unreadCount: 2,
    contactId: 'user-alice',
    contactStatus: AvailabilityStatus.free,
    contactStatusMessage: 'Free to chat!',
  ),
  Conversation(
    id: 'conv-family',
    type: ConversationType.circle,
    circleId: 'circle-1',
    displayName: 'Family',
    avatarUrl: null,
    lastMessage: 'Mom: Don\'t forget dinner tonight!',
    lastMessageTime: DateTime.utc(2024, 1, 15, 14, 0),
    memberCount: 4,
  ),
  Conversation(
    id: '2',
    type: ConversationType.direct,
    displayName: 'Bob',
    avatarUrl: null,
    lastMessage: 'Talk later, in a meeting',
    lastMessageTime: DateTime.utc(2024, 1, 15, 12, 0),
    contactId: 'user-bob',
    contactStatus: AvailabilityStatus.busy,
    contactStatusMessage: 'In a meeting',
  ),
  Conversation(
    id: 'conv-friends',
    type: ConversationType.circle,
    circleId: 'circle-2',
    displayName: 'Close Friends',
    avatarUrl: null,
    lastMessage: 'Diana: Weekend plans?',
    lastMessageTime: DateTime.utc(2024, 1, 14, 15, 0),
    memberCount: 5,
  ),
  Conversation(
    id: '3',
    type: ConversationType.direct,
    displayName: 'Mom',
    avatarUrl: null,
    lastMessage: 'Call me when you can',
    lastMessageTime: DateTime.utc(2024, 1, 14, 10, 0),
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
    lastMessageTime: DateTime.utc(2024, 1, 13, 22, 0),
    contactId: 'user-charlie',
    contactStatus: AvailabilityStatus.sleeping,
    contactStatusMessage: 'Sleeping',
  ),
];
