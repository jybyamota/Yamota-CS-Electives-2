import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
	const PokemonCard({
		required this.pokemon,
		this.onTap,
		super.key,
	});

	final Pokemon pokemon;
	final VoidCallback? onTap;

	@override
	Widget build(BuildContext context) {
		final cardContent = Padding(
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
						pokemon.displayName,
						maxLines: 1,
						overflow: TextOverflow.ellipsis,
						style: Theme.of(context).textTheme.titleMedium,
					),
				],
			),
		);

		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(12),
			child: Card(
				clipBehavior: Clip.antiAlias,
				child: cardContent,
			),
		);
	}
}