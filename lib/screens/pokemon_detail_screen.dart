import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({required this.pokemon, super.key});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);
    final isFavorite = state.favoriteIds.contains(pokemon.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.displayNameFor(pokemon)),
        actions: [
          IconButton(
            onPressed: () => notifier.toggleFavorite(pokemon),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                pokemon.imageUrl,
                height: 260,
                width: 260,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.catching_pokemon, size: 120),
              ),
              const SizedBox(height: 20),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.displayNameFor(pokemon),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: pokemon.types
                    .map((type) => Chip(label: Text(type)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
