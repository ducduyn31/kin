import 'package:flutter/material.dart';
import 'feature.dart';

class KinApp extends StatelessWidget {
  final List<IFeature> features;
  final String initialPath;

  const KinApp({
    super.key,
    required this.features,
    required this.initialPath,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialPath,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    for (final feature in features) {
      for (final route in feature.routes) {
        if (route.route == settings.name) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => route.builder(context, settings),
          );
        }
      }
    }
    return null;
  }
}
