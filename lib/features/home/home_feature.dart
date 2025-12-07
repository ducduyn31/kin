import '../../core/feature.dart';
import 'home_screen.dart';

class HomeFeature extends IFeature {
  @override
  String get namespace => 'home';

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition(
          route: '/home',
          builder: (context, settings) => const HomeScreen(),
        ),
      ];
}
