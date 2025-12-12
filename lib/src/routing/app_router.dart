import 'package:flutter/material.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/circles/presentation/circle_detail_screen.dart';
import '../common_widgets/bottom_nav_scaffold.dart';

class AppRouter {
  // Main tab routes
  static const String home = '/';
  static const String chats = '/chats';
  static const String circles = '/circles';
  static const String profile = '/profile';

  // Detail routes
  static const String chat = '/chat';
  static const String circle = '/circle';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 0),
        );
      case chats:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 1),
        );
      case circles:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 2),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: 3),
        );
      case chat:
        final args = settings.arguments as ChatScreenArgs?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: args?.conversationId ?? '',
            contactName: args?.contactName ?? 'Chat',
          ),
        );
      case circle:
        final circleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CircleDetailScreen(circleId: circleId ?? ''),
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
