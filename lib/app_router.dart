import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models.dart';
import 'screens.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductDetailScreen(
        product: products.byId(state.pathParameters['id']!),
      ),
    ),
  ],
);
