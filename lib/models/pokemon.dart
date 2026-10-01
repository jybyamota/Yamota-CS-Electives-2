class Pokemon {
	const Pokemon({required this.id, required this.name});

	final int id;
	final String name;

	factory Pokemon.fromApi(Map<String, dynamic> json) {
		final url = Uri.parse(json['url'] as String);
		final id = int.parse(url.pathSegments.where((part) => part.isNotEmpty).last);

		return Pokemon(id: id, name: json['name'] as String);
	}

	String get imageUrl =>
			'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}