import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

void main() {
	runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
	const PokedexApp({super.key});

	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider(
			create: (_) => PokemonProvider(),
			child: MaterialApp(
				title: 'Pokédex List',
				debugShowCheckedModeBanner: false,
				theme: ThemeData(
					colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
					useMaterial3: true,
				),
				home: const PokedexScreen(),
			),
		);
	}
}
