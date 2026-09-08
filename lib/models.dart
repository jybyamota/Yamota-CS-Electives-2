class Product {
  const Product(
    this.id,
    this.name,
    this.category,
    this.price,
    this.image,
    this.description,
  );

  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;
}

const List<Product> products = <Product>[
  Product(
    'stardew',
    'Stardew Valley',
    'Cozy farming sim',
    849.00,
    'assets/images/stardewvalley.webp',
    'Build a new life, grow a farm, and make a home in the valley.',
  ),
  Product(
    'hades',
    'Sekiro: Shadows Die Twice',
    'Action-adventure RPG',
    1499.00,
    'assets/images/sekiro.jpg',
    'Master precise swordplay and face relentless enemies in a striking shinobi adventure.',
  ),
  Product(
    'portal',
    'Elden Ring',
    'Open-world action RPG',
    599.00,
    'assets/images/elden ring.jpg',
    'Explore the Lands Between, face legendary foes, and forge your own path.',
  ),
  Product(
    'cities',
    'Outlast 2',
    'Survival horror',
    999.00,
    'assets/images/outlast2.webp',
    'Survive a terrifying journey through an isolated wilderness and its secrets.',
  ),
];

extension ProductLookup on List<Product> {
  Product byId(String id) =>
      firstWhere((product) => product.id == id, orElse: () => first);
}
