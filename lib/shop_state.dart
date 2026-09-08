import 'package:flutter/material.dart';

import 'models.dart';

final ShopState shopState = ShopState();

class ShopState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  final Map<String, int> _cart = <String, int>{};

  Map<String, int> get cart => Map<String, int>.unmodifiable(_cart);

  int quantityFor(Product product) => _cart[product.id] ?? 0;

  int get itemCount => _cart.values.fold(0, (total, quantity) => total + quantity);

  double get subtotal => _cart.entries.fold(0, (total, entry) {
        final Product product = products.byId(entry.key);
        return total + product.price * entry.value;
      });

  void addToCart(Product product) {
    _cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final int quantity = quantityFor(product);
    if (quantity <= 1) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = quantity - 1;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}
