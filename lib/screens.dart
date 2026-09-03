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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(child: ProductArt(product: product)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(product.category.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
                Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('\$${product.price.toStringAsFixed(0)}'),
              ]),
            ),
          ]),
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
                Text('\$${product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                Text(product.description),
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


