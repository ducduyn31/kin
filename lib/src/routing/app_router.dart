import 'package:flutter/material.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../common_widgets/bottom_nav_scaffold.dart';

class AppRouter {
  static const String conversations = '/';
  static const String chat = '/chat';
  static const String contacts = '/contacts';
  static const String profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case conversations:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 0),
        );
      case contacts:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 1),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 2),
        );
      case chat:
        final args = settings.arguments as ChatScreenArgs?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: args?.conversationId ?? '',
            contactName: args?.contactName ?? 'Chat',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 0),
        );
    }
  }
}

class ChatScreenArgs {
  final String conversationId;
  final String contactName;

  const ChatScreenArgs({
    required this.conversationId,
    required this.contactName,
  });
}
