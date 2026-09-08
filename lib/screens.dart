import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models.dart';
import 'shop_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('STEAM SHELF', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.4)),
          actions: <Widget>[
            IconButton(
              tooltip: 'Open cart',
              onPressed: () => context.push('/cart'),
              icon: Badge(
                isLabelVisible: shopState.itemCount > 0,
                label: Text('${shopState.itemCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            IconButton(
              tooltip: 'Toggle theme',
              onPressed: shopState.toggleTheme,
              icon: Icon(shopState.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth >= 700 ? 3 : 2;
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 700 ? 40 : 20, 28, constraints.maxWidth >= 700 ? 40 : 20, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text('GAMES\nWORTH PLAYING', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: .95)),
                      const SizedBox(height: 14),
                      Text('A hand-picked shelf of memorable PC games for your next session.', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 22),
                      Text('${products.length} games / player-curated collection', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 700 ? 40 : 20, 8, constraints.maxWidth >= 700 ? 40 : 20, 32),
                  sliver: SliverGrid.builder(
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 24, childAspectRatio: .68),
                    itemBuilder: (_, index) => ProductCard(product: products[index]),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/product/${product.id}'),
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  AspectRatio(aspectRatio: 1.15, child: ProductArt(product: product)),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(product.category.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 5),
                      Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('₱${product.price.toStringAsFixed(2)}'),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.product, this.compact = false});
  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context) => Image.asset(
        product.image,
        width: compact ? 56 : double.infinity,
        height: compact ? 56 : double.infinity,
        fit: BoxFit.cover,
      );
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 700;
            final Widget details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(product.category.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Text(product.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('₱${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                Text(product.description),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    shopState.addToCart(product);
                    context.push('/cart');
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to cart'),
                ),
              ],
            );
            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 40 : 20),
              child: wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Expanded(child: AspectRatio(aspectRatio: 1, child: ProductArt(product: product))),
                      const SizedBox(width: 40),
                      Expanded(child: details),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      AspectRatio(aspectRatio: 1.15, child: ProductArt(product: product)),
                      const SizedBox(height: 24),
                      details,
                    ]),
            );
          },
        ),
      );
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: AnimatedBuilder(
          animation: shopState,
          builder: (context, _) {
            if (shopState.itemCount == 0) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Your cart is empty.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Browse products'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                for (final String productId in shopState.cart.keys)
                  CartItemTile(product: products.byId(productId)),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('₱${shopState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.push('/checkout'),
                  child: const Text('Proceed to checkout'),
                ),
              ],
            );
          },
        ),
      );
}

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: ProductArt(product: product, compact: true),
        title: Text(product.name),
        subtitle: Text('₱${product.price.toStringAsFixed(2)} each'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: () => shopState.removeFromCart(product),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${shopState.quantityFor(product)}'),
            IconButton(
              tooltip: 'Increase quantity',
              onPressed: () => shopState.addToCart(product),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      );
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Checkout confirmation')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.check_circle_outline, size: 72),
                const SizedBox(height: 16),
                const Text('Order confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('${shopState.itemCount} item(s) - ₱${shopState.subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    shopState.clearCart();
                    context.go('/');
                  },
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      );
}


