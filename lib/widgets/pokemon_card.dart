import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
	const PokemonCard({required this.pokemon, super.key});

	final Pokemon pokemon;

	@override
	Widget build(BuildContext context) {
		return Card(
			clipBehavior: Clip.antiAlias,
			child: Padding(
				padding: const EdgeInsets.all(12),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							child: Image.network(
								pokemon.imageUrl,
								fit: BoxFit.contain,
								errorBuilder: (context, error, stackTrace) => const Icon(
									Icons.catching_pokemon,
									size: 64,
								),
							),
						),
						Text(
							'#${pokemon.id.toString().padLeft(3, '0')}',
							style: Theme.of(context).textTheme.labelMedium,
						),
						Text(
							pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
							style: Theme.of(context).textTheme.titleMedium,
						),
					],
				),
			),
		);
	}
}