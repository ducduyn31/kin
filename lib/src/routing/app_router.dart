import 'package:flutter/material.dart';
import '../common_widgets/bottom_nav_scaffold.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/circles/presentation/circle_detail_screen.dart';
import '../features/circles/presentation/join_circle_screen.dart';
import '../l10n/app_localizations.dart';

class AppRouter {
  // Main tab routes
  static const String home = '/';
  static const String chats = '/chats';
  static const String circles = '/circles';
  static const String profile = '/profile';

  // Detail routes
  static const String chat = '/chat';
  static const String circle = '/circle';
  static const String joinCircle = '/join-circle';

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
        final circleId = settings.arguments;
        if (circleId is! String || circleId.isEmpty) {
          return MaterialPageRoute(
            builder: (context) => _RouteErrorScreen(
              errorMessageBuilder: (l10n) => l10n.routeErrorMissingCircleId,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CircleDetailScreen(circleId: circleId),
        );
      case joinCircle:
        final code = settings.arguments;
        if (code is! String || code.isEmpty) {
          return MaterialPageRoute(
            builder: (context) => _RouteErrorScreen(
              errorMessageBuilder: (l10n) =>
                  l10n.routeErrorMissingInvitationCode,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => JoinCircleScreen(invitationCode: code),
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

class _RouteErrorScreen extends StatelessWidget {
  final String Function(AppLocalizations l10n) errorMessageBuilder;

  const _RouteErrorScreen({required this.errorMessageBuilder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeErrorTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.routeErrorTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessageBuilder(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
