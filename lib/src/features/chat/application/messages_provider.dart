import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/message.dart';

@immutable
class MessagesState {
  final List<Message> messages;

  const MessagesState(this.messages);
}

class MessagesNotifier extends Notifier<MessagesState> {
  @override
  MessagesState build() {
    return MessagesState(_getMockMessages());
  }

  List<Message> _getMockMessages() {
    final now = DateTime.now();
    return [
      Message(
        id: '1',
        content: 'Hey! How are you doing?',
        timestamp: now.subtract(const Duration(hours: 2)),
        isMe: false,
        status: MessageStatus.read,
      ),
      Message(
        id: '2',
        content: 'I\'m doing great, thanks! Just finished work.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        isMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '3',
        content: 'Nice! Want to grab coffee later?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        isMe: false,
        status: MessageStatus.read,
      ),
      Message(
        id: '4',
        content: 'Sure, that sounds great! Where do you want to meet?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '5',
        content: 'How about the new café downtown?',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isMe: false,
        status: MessageStatus.read,
      ),
      Message(
        id: '6',
        content: 'Perfect! See you at 5pm? ☕',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isMe: true,
        status: MessageStatus.delivered,
      ),
    ];
  }

  void sendMessage(String content) {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sending,
    );
    state = MessagesState([...state.messages, newMessage]);

    // Simulate message sent after delay
    Future.delayed(const Duration(seconds: 1), () {
      state = MessagesState(state.messages.map((m) {
        if (m.id == newMessage.id) {
          return Message(
            id: m.id,
            content: m.content,
            timestamp: m.timestamp,
            isMe: m.isMe,
            status: MessageStatus.sent,
          );
        }
        return m;
      }).toList());
    });
  }
}

final messagesNotifierProvider = NotifierProvider<MessagesNotifier, MessagesState>(
  MessagesNotifier.new,
);

// Simple provider to get messages list
final messagesProvider = Provider.family<List<Message>, String>((ref, conversationId) {
  final messagesState = ref.watch(messagesNotifierProvider);
  return messagesState.messages;
});
