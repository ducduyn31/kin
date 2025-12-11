import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../application/messages_provider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';

class ChatScreen extends ConsumerWidget {
  final String conversationId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.contactName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider(conversationId));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                contactName.isNotEmpty ? contactName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contactName, style: const TextStyle(fontSize: 16)),
                Text(
                  l10n.online,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // TODO: Video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // TODO: Voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: More options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      l10n.noMessagesYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          MessageInput(
            onSend: (text) {
              ref.read(messagesNotifierProvider.notifier).sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}
