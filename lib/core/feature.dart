import 'package:flutter/material.dart';

typedef RouteBuilder = Widget Function(BuildContext context, RouteSettings settings);

class RouteDefinition {
  final String route;
  final RouteBuilder builder;

  const RouteDefinition({
    required this.route,
    required this.builder,
  });
}

abstract class IFeature {
  String get namespace;
  List<RouteDefinition> get routes => [];
}
