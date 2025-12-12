import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/src/l10n/app_localizations.dart';
import 'src/config/env.dart';
import 'src/constants/app_theme.dart';
import 'src/features/authentication/presentation/auth_wrapper.dart';
import 'src/routing/app_router.dart';
import 'src/services/analytics_service.dart';
import 'src/services/deep_link_service.dart';

final deepLinkService = DeepLinkService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && Env.enableDebugLogging) {
    debugPrint('Environment: ${Env.environment}');
  }

  await analytics.initialize();

  try {
    await deepLinkService.initialize();
  } catch (e, stackTrace) {
    debugPrint('[main] Deep link initialization failed: $e\n$stackTrace');
    analytics.capture('deep_link_init_failed', {
      'error': e.toString(),
      'stack_trace': stackTrace.toString(),
    });
  }

  runApp(const ProviderScope(child: KinApp()));
}

class KinApp extends StatefulWidget {
  const KinApp({super.key});

  @override
  State<KinApp> createState() => _KinAppState();
}

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class _KinAppState extends State<KinApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<DeepLinkData>? _deepLinkSubscription;
  final _pendingDeepLinks = ListQueue<DeepLinkData>();
  bool _postFrameCallbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _deepLinkSubscription = deepLinkService.linkStream.listen(
      _handleDeepLink,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[KinApp] Deep link stream error: $error\n$stackTrace');
        analytics.capture('deep_link_stream_error', {
          'error': error.toString(),
          'stack_trace': stackTrace.toString(),
        });
      },
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    deepLinkService.dispose();
    super.dispose();
  }

  void _handleDeepLink(DeepLinkData data) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      if (kDebugMode) {
        debugPrint('[KinApp] Navigator not ready, queuing deep link: $data');
      }
      _pendingDeepLinks.add(data);
      _scheduleDeepLinkProcessing();
      return;
    }

    switch (data) {
      case JoinCircleDeepLink(:final code):
        navigator.pushNamed(AppRouter.joinCircle, arguments: code);
      case UnknownDeepLink(:final uri):
        if (kDebugMode) {
          debugPrint('[KinApp] Unknown deep link: $uri');
        }
    }
  }

  void _scheduleDeepLinkProcessing() {
    if (_postFrameCallbackScheduled) return;
    _postFrameCallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postFrameCallbackScheduled = false;
      _processPendingDeepLinks();
    });
  }

  void _processPendingDeepLinks() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // Navigator still not ready, schedule another attempt
      if (_pendingDeepLinks.isNotEmpty) {
        _scheduleDeepLinkProcessing();
      }
      return;
    }

    while (_pendingDeepLinks.isNotEmpty) {
      final pending = _pendingDeepLinks.removeFirst();
      _handleDeepLink(pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi'), Locale('zh')],
      builder: (context, child) => AuthWrapper(child: child!),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
