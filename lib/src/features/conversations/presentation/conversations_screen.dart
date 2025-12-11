import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../application/conversations_provider.dart';
import '../../chat/presentation/chat_screen.dart';
import 'widgets/conversation_tile.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noConversationsYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.startChatWithFriend,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: conversation.id,
                          contactName: conversation.contactName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start new conversation
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
