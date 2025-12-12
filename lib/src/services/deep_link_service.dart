import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

sealed class DeepLinkData {
  const DeepLinkData();
}

class JoinCircleDeepLink extends DeepLinkData {
  final String code;
  const JoinCircleDeepLink(this.code);
}

class UnknownDeepLink extends DeepLinkData {
  final Uri uri;
  const UnknownDeepLink(this.uri);
}

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _isDisposed = false;

  final _linkController = StreamController<DeepLinkData>.broadcast();

  Stream<DeepLinkData> get linkStream => _linkController.stream;

  Future<void> initialize() async {
    if (_isDisposed) {
      throw StateError(
        'DeepLinkService has been disposed and cannot be reinitialized. '
        'Create a new instance instead.',
      );
    }

    if (_subscription != null) {
      return;
    }

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Error getting initial link: $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (error) {
        debugPrint('[DeepLinkService] Error in link stream: $error');
      },
    );
  }

  void _handleUri(Uri uri) {
    if (_isDisposed || _linkController.isClosed) {
      return;
    }

    if (kDebugMode) {
      final redactedUri = uri.replace(
        path: uri.pathSegments.isNotEmpty
            ? '/${uri.pathSegments.map((_) => '***').join('/')}'
            : uri.path,
        queryParameters: uri.queryParameters.isNotEmpty
            ? uri.queryParameters.map((key, _) => MapEntry(key, '***'))
            : null,
      );
      debugPrint('[DeepLinkService] Received deep link: $redactedUri');
    }

    final data = parseUri(uri);
    if (data != null) {
      _linkController.add(data);
    }
  }

  @visibleForTesting
  static DeepLinkData? parseUri(Uri uri) {
    if (uri.scheme != 'kin') {
      return null;
    }

    if (uri.host == 'join' && uri.pathSegments.isNotEmpty) {
      final code = uri.pathSegments.first;
      if (code.isNotEmpty) {
        return JoinCircleDeepLink(code);
      }
    }

    if (uri.host == 'join' && uri.queryParameters.containsKey('code')) {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        return JoinCircleDeepLink(code);
      }
    }

    return UnknownDeepLink(uri);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    try {
      await _subscription?.cancel();
      _subscription = null;
    } catch (e) {
      debugPrint('[DeepLinkService] Error cancelling subscription: $e');
    }

    try {
      if (!_linkController.isClosed) {
        await _linkController.close();
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Error closing link controller: $e');
    }
  }
}
