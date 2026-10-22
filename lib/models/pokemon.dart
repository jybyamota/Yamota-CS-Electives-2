class Pokemon {
  const Pokemon({required this.id, required this.name, this.types = const []});

  final int id;
  final String name;
  final List<String> types;

  factory Pokemon.fromApi(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final types = (json['types'] as List<dynamic>? ?? const [])
        .map(
          (entry) =>
              (entry as Map<String, dynamic>)['type'] as Map<String, dynamic>,
        )
        .map((type) => type['name'] as String)
        .toList(growable: false);

    return Pokemon(id: id, name: json['name'] as String, types: types);
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
