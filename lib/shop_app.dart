import 'package:flutter/material.dart';

import 'app_router.dart';
import 'app_theme.dart';
import 'shop_state.dart';

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: shopState,
        builder: (context, _) => MaterialApp.router(
          title: 'Steam Shelf',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: shopState.themeMode,
          routerConfig: router,
        ),
      );
}
