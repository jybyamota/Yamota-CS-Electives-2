import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

final pokemonServiceProvider = Provider<PokemonService>((ref) {
  final service = PokemonService();
  ref.onDispose(service.dispose);
  return service;
});

final pokemonProvider = NotifierProvider<PokemonListNotifier, PokemonState>(
  PokemonListNotifier.new,
);

class PokemonState {
  const PokemonState({
    this.pokemons = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedType,
    this.favoritesOnly = false,
    this.favoriteIds = const {},
    this.nicknames = const {},
  });

  final List<Pokemon> pokemons;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedType;
  final bool favoritesOnly;
  final Set<int> favoriteIds;
  final Map<int, String> nicknames;

  List<Pokemon> get favoritePokemon =>
      pokemons.where((pokemon) => favoriteIds.contains(pokemon.id)).toList();

  List<String> get availableTypes =>
      pokemons.expand((pokemon) => pokemon.types).toSet().toList()..sort();

  List<Pokemon> get visiblePokemon {
    final query = searchQuery.trim().toLowerCase();
    return pokemons
        .where((pokemon) {
          final matchesQuery =
              query.isEmpty ||
              pokemon.name.toLowerCase().contains(query) ||
              displayNameFor(pokemon).toLowerCase().contains(query);
          final matchesType =
              selectedType == null || pokemon.types.contains(selectedType);
          final matchesFavorite =
              !favoritesOnly || favoriteIds.contains(pokemon.id);
          return matchesQuery && matchesType && matchesFavorite;
        })
        .toList(growable: false);
  }

  String displayNameFor(Pokemon pokemon) =>
      nicknames[pokemon.id] ?? pokemon.displayName;

  PokemonState copyWith({
    List<Pokemon>? pokemons,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? searchQuery,
    String? selectedType,
    bool clearSelectedType = false,
    bool? favoritesOnly,
    Set<int>? favoriteIds,
    Map<int, String>? nicknames,
  }) {
    return PokemonState(
      pokemons: pokemons ?? this.pokemons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: clearSelectedType
          ? null
          : selectedType ?? this.selectedType,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      nicknames: nicknames ?? this.nicknames,
    );
  }
}

class PokemonListNotifier extends Notifier<PokemonState> {
  late PokemonService _service;

  @override
  PokemonState build() {
    _service = ref.watch(pokemonServiceProvider);
    return const PokemonState();
  }

  Future<void> fetchPokemon() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      state = state.copyWith(
        pokemons: await _service.fetchPokemon(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage:
            'Could not load Pokémon. Check your connection and retry.',
        isLoading: false,
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(String? type) {
    state = state.copyWith(selectedType: type, clearSelectedType: type == null);
  }

  void setFavoritesOnly(bool enabled) {
    state = state.copyWith(favoritesOnly: enabled);
  }

  void toggleFavorite(Pokemon pokemon) {
    final favoriteIds = Set<int>.of(state.favoriteIds);
    if (!favoriteIds.add(pokemon.id)) {
      favoriteIds.remove(pokemon.id);
    }
    state = state.copyWith(favoriteIds: favoriteIds);
  }

  void updateNickname(Pokemon pokemon, String nickname) {
    final nicknames = Map<int, String>.of(state.nicknames);
    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isEmpty) {
      nicknames.remove(pokemon.id);
    } else {
      nicknames[pokemon.id] = trimmedNickname;
    }
    state = state.copyWith(nicknames: nicknames);
  }
}
