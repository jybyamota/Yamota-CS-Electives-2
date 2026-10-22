import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(pokemonProvider.notifier).fetchPokemon();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final notifier = ref.read(pokemonProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : notifier.fetchPokemon,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Pokémon',
          ),
        ],
      ),
      body: state.isLoading && state.pokemons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.pokemons.isEmpty
          ? _MessageState(
              message: state.errorMessage!,
              buttonLabel: 'Retry',
              onPressed: notifier.fetchPokemon,
            )
          : RefreshIndicator(
              onRefresh: notifier.fetchPokemon,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _FiltersPanel(
                      state: state,
                      searchController: _searchController,
                      onSearchChanged: notifier.setSearchQuery,
                      onTypeChanged: notifier.setTypeFilter,
                      onFavoritesChanged: notifier.setFavoritesOnly,
                    ),
                  ),
                  if (state.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  if (state.favoritePokemon.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _FavoritesPanel(
                        pokemons: state.favoritePokemon,
                        displayName: state.displayNameFor,
                        onTap: (pokemon) => _openDetails(context, pokemon),
                      ),
                    ),
                  if (state.visiblePokemon.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        message: 'No Pokémon match these filters.',
                      ),
                    )
                  else
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 1000
                            ? 5
                            : width >= 640
                            ? 3
                            : 2;
                        return SliverPadding(
                          padding: const EdgeInsets.all(12),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.72,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final pokemon = state.visiblePokemon[index];
                              return PokemonCard(
                                pokemon: pokemon,
                                displayName: state.displayNameFor(pokemon),
                                isFavorite: state.favoriteIds.contains(
                                  pokemon.id,
                                ),
                                onFavoriteTap: () =>
                                    notifier.toggleFavorite(pokemon),
                                onNicknameTap: () => _editNickname(
                                  context,
                                  pokemon,
                                  state.displayNameFor(pokemon),
                                ),
                                onTap: () => _openDetails(context, pokemon),
                              );
                            }, childCount: state.visiblePokemon.length),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  void _openDetails(BuildContext context, Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  Future<void> _editNickname(
    BuildContext context,
    Pokemon pokemon,
    String currentName,
  ) async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (_) => _NicknameDialog(
        pokemonName: pokemon.displayName,
        initialValue: currentName,
      ),
    );
    if (mounted && nickname != null) {
      ref.read(pokemonProvider.notifier).updateNickname(pokemon, nickname);
    }
  }
}

class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({
    required this.pokemonName,
    required this.initialValue,
  });

  final String pokemonName;
  final String initialValue;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nickname for ${widget.pokemonName}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nickname'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onFavoritesChanged,
  });

  final PokemonState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Pokémon',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('${state.pokemons.length} in your Pokédex'),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search Pokémon',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('All (${state.pokemons.length})'),
                      selected: !state.favoritesOnly,
                      onSelected: (_) => onFavoritesChanged(false),
                    ),
                    ChoiceChip(
                      label: Text('Favorites (${state.favoriteIds.length})'),
                      selected: state.favoritesOnly,
                      onSelected: (_) => onFavoritesChanged(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 132,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const ValueKey('type-filter'),
                      isExpanded: true,
                      value: state.selectedType ?? '',
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All types'),
                        ),
                        ...state.availableTypes.map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type[0].toUpperCase() + type.substring(1),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (type) =>
                          onTypeChanged(type == '' ? null : type),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoritesPanel extends StatelessWidget {
  const _FavoritesPanel({
    required this.pokemons,
    required this.displayName,
    required this.onTap,
  });

  final List<Pokemon> pokemons;
  final String Function(Pokemon) displayName;
  final ValueChanged<Pokemon> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text('Favorites (${pokemons.length})'),
        children: pokemons.map((pokemon) {
          return ListTile(
            leading: Image.network(
              pokemon.imageUrl,
              width: 42,
              errorBuilder: (_, _, _) => const Icon(Icons.catching_pokemon),
            ),
            title: Text(displayName(pokemon)),
            subtitle: Text('#${pokemon.id.toString().padLeft(3, '0')}'),
            onTap: () => onTap(pokemon),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (buttonLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
