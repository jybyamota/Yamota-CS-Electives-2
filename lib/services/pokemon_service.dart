import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Pokemon>> fetchPokemon() async {
    final response = await _client.get(
      Uri.https('pokeapi.co', '/api/v2/pokemon', {'limit': '30'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load Pokémon (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return Future.wait(
      results.map((result) async {
        final pokemonUrl = Uri.parse(
          (result as Map<String, dynamic>)['url'] as String,
        );
        final pokemonResponse = await _client.get(pokemonUrl);
        if (pokemonResponse.statusCode != 200) {
          throw Exception(
            'Could not load Pokémon details (${pokemonResponse.statusCode}).',
          );
        }

        return Pokemon.fromApi(
          jsonDecode(pokemonResponse.body) as Map<String, dynamic>,
        );
      }),
    );
  }

  void dispose() => _client.close();
}
