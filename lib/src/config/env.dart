import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'ENVIRONMENT', defaultValue: 'development')
  static final String environment = _Env.environment;

  @EnviedField(varName: 'AUTH0_DOMAIN')
  static final String auth0Domain = _Env.auth0Domain;

  @EnviedField(varName: 'AUTH0_CLIENT_ID')
  static final String auth0ClientId = _Env.auth0ClientId;

  @EnviedField(varName: 'AUTH0_AUDIENCE', defaultValue: '')
  static final String auth0Audience = _Env.auth0Audience;

  @EnviedField(varName: 'APP_SCHEME', defaultValue: 'com.example.kin')
  static final String appScheme = _Env.appScheme;

  @EnviedField(varName: 'API_BASE_URL', defaultValue: '')
  static final String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'ENABLE_DEBUG_LOGGING', defaultValue: 'false')
  static final String _enableDebugLogging = _Env._enableDebugLogging;

  static bool get enableDebugLogging =>
      _enableDebugLogging.toLowerCase() == 'true';

  @EnviedField(varName: 'POSTHOG_API_KEY', defaultValue: '')
  static final String posthogApiKey = _Env.posthogApiKey;

  @EnviedField(varName: 'POSTHOG_HOST', defaultValue: 'https://app.posthog.com')
  static final String posthogHost = _Env.posthogHost;

  static bool get isProduction => environment.toLowerCase() == 'production';
  static bool get isDevelopment => !isProduction;
}
