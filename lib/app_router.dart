import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models.dart';
import 'screens.dart';
import 'shop_state.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: shopState,
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductDetailScreen(
        product: products.byId(state.pathParameters['id']!),
      ),
    ),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(
      path: '/checkout',
      redirect: (_, __) => shopState.itemCount == 0 ? '/cart' : null,
      builder: (_, __) => const CheckoutScreen(),
    ),
  ],
);
