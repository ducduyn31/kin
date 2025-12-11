import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../config/env.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  bool _initialized = false;

  bool get isEnabled =>
      _initialized && Env.isProduction && Env.posthogApiKey.isNotEmpty;

  /// Initialize the analytics service.
  /// Must be called before any tracking methods.
  Future<void> initialize() async {
    if (_initialized) return;

    if (Env.isDevelopment || Env.posthogApiKey.isEmpty) {
      debugPrint(
        '[Analytics] Disabled - ${Env.isDevelopment ? 'development mode' : 'no API key'}',
      );
      _initialized = true;
      return;
    }

    try {
      final config = PostHogConfig(Env.posthogApiKey)
        ..host = Env.posthogHost
        ..captureApplicationLifecycleEvents = true
        ..debug = kDebugMode;

      await Posthog().setup(config);
      _initialized = true;
      debugPrint('[Analytics] Initialized successfully');
    } catch (e) {
      debugPrint('[Analytics] Failed to initialize: $e');
      _initialized = true;
    }
  }

  /// Track a custom event.
  void capture(String eventName, [Map<String, Object>? properties]) {
    if (!isEnabled) {
      debugPrint('[Analytics] (dev) capture: $eventName ${properties ?? ''}');
      return;
    }

    Posthog().capture(eventName: eventName, properties: properties);
  }

  /// Track a screen view.
  void screen(String screenName, [Map<String, Object>? properties]) {
    if (!isEnabled) {
      debugPrint('[Analytics] (dev) screen: $screenName');
      return;
    }

    Posthog().screen(screenName: screenName, properties: properties);
  }

  /// Identify a user after authentication.
  void identify(String userId, [Map<String, Object>? userProperties]) {
    if (!isEnabled) {
      debugPrint('[Analytics] (dev) identify: $userId');
      return;
    }

    Posthog().identify(userId: userId, userProperties: userProperties);
  }

  void reset() {
    if (!isEnabled) {
      debugPrint('[Analytics] (dev) reset');
      return;
    }

    Posthog().reset();
  }

  Future<void> setEnabled(bool enabled) async {
    if (!_initialized || Env.isDevelopment) return;

    if (enabled) {
      await Posthog().enable();
    } else {
      await Posthog().disable();
    }
  }
}

AnalyticsService get analytics => AnalyticsService.instance;
