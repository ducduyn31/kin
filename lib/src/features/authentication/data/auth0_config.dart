import '../../../config/env.dart';

class Auth0Config {
  static String get domain => Env.auth0Domain;

  static String get clientId => Env.auth0ClientId;

  static String? get audience =>
      Env.auth0Audience.isNotEmpty ? Env.auth0Audience : null;

  static const String scopes = 'openid profile email offline_access';

  static String get scheme => Env.appScheme;
}
