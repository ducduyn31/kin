import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'features/home/home_feature.dart';

void main() {
  runApp(
    ProviderScope(
      child: KinApp(
        initialPath: '/home',
        features: [
          HomeFeature(),
        ],
      ),
    ),
  );
}
