import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../features/conversations/presentation/conversations_screen.dart';
import '../features/contacts/presentation/contacts_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class BottomNavScaffold extends StatefulWidget {
  final int initialIndex;

  const BottomNavScaffold({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    ConversationsScreen(),
    ContactsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l10n.chats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.contacts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
