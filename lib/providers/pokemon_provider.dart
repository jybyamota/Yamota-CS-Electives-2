import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service}) : _service = service ?? PokemonService();

  final PokemonService _service;

  List<Pokemon> _pokemons = const <Pokemon>[];
  bool _isLoading = false;
  String? _errorMessage;
  Pokemon? _selectedPokemon;

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;

  Future<void> fetchPokemon() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pokemons = await _service.fetchPokemon();
      if (_selectedPokemon != null &&
          _pokemons.every((pokemon) => pokemon.id != _selectedPokemon!.id)) {
        _selectedPokemon = _pokemons.first;
      }
    } catch (_) {
      _errorMessage = 'Could not load Pokémon.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }
}
