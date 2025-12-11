import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/src/l10n/app_localizations.dart';
import '../application/contacts_provider.dart';
import '../domain/contact.dart';
import '../../chat/presentation/chat_screen.dart';
import 'widgets/contact_tile.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(filteredContactsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Group contacts by online status
    final onlineContacts = contacts
        .where((c) => c.status != AvailabilityStatus.offline)
        .toList();
    final offlineContacts = contacts
        .where((c) => c.status == AvailabilityStatus.offline)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchContacts,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).setQuery(value);
                },
              )
            : Text(l10n.contacts),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).setQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {
              // TODO: Add new contact
            },
          ),
        ],
      ),
      body: contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? l10n.noContactsFound : l10n.noContactsYet,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                if (onlineContacts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.onlineCount(onlineContacts.length),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...onlineContacts.map(
                    (contact) => ContactTile(
                      contact: contact,
                      onTap: () => _openChat(context, contact),
                      onCall: () => _startCall(contact),
                    ),
                  ),
                ],
                if (offlineContacts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      l10n.offlineCount(offlineContacts.length),
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...offlineContacts.map(
                    (contact) => ContactTile(
                      contact: contact,
                      onTap: () => _openChat(context, contact),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _openChat(BuildContext context, Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(conversationId: contact.id, contactName: contact.name),
      ),
    );
  }

  void _startCall(Contact contact) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement calling
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.callingContact(contact.name))));
  }
}
