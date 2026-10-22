import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    required this.pokemon,
    required this.displayName,
    required this.isFavorite,
    this.onFavoriteTap,
    this.onNicknameTap,
    this.onTap,
    super.key,
  });

  final Pokemon pokemon;
  final String displayName;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onNicknameTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.catching_pokemon, size: 64),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: onFavoriteTap,
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber.shade800 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit nickname',
                    onPressed: onNicknameTap,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                children: pokemon.types.take(2).map((type) {
                  return Chip(
                    label: Text(type),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
