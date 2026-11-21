import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get total => product.price * quantity;
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: 1)];
      return;
    }
    final item = state[index];
    if (item.quantity >= product.stock) return;
    state = [
      for (var i = 0; i < state.length; i++)
        i == index ? item.copyWith(quantity: item.quantity + 1) : state[i],
    ];
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      remove(product);
      return;
    }
    final safeQuantity = quantity > product.stock ? product.stock : quantity;
    state = [
      for (final item in state)
        item.product.id == product.id
            ? item.copyWith(quantity: safeQuantity)
            : item,
    ];
  }

  void remove(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void clear() => state = [];

  int get count => state.fold(0, (sum, item) => sum + item.quantity);
  double get total => state.fold(0, (sum, item) => sum + item.total);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);
