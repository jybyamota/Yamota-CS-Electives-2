import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_application1/providers/pokemon_provider.dart';
import 'package:flutter_application1/screens/pokedex_screen.dart';
import 'package:flutter_application1/services/pokemon_service.dart';

void main() {
  testWidgets('shows the fetched Pokémon in a grid', (
    WidgetTester tester,
  ) async {
    final service = PokemonService(
      client: MockClient((request) async {
        if (request.url.path == '/api/v2/pokemon') {
          expect(request.url.queryParameters['limit'], '30');
          return httpResponse({
            'results': [
              {
                'name': 'bulbasaur',
                'url': 'https://pokeapi.co/api/v2/pokemon/1/',
              },
              {
                'name': 'ivysaur',
                'url': 'https://pokeapi.co/api/v2/pokemon/2/',
              },
              {
                'name': 'charmander',
                'url': 'https://pokeapi.co/api/v2/pokemon/4/',
              },
            ],
          });
        }

        final id = int.parse(
          request.url.pathSegments.where((segment) => segment.isNotEmpty).last,
        );
        final names = {1: 'bulbasaur', 2: 'ivysaur', 4: 'charmander'};
        final type = id == 4 ? 'fire' : 'grass';
        return httpResponse({
          'id': id,
          'name': names[id],
          'types': [
            {
              'slot': 1,
              'type': {'name': type},
            },
          ],
        });
      }),
    );
    final fetchedPokemon = await service.fetchPokemon();
    expect(fetchedPokemon, hasLength(3));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pokemonServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: PokedexScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load Pokémon. Check your connection and retry.'),
      findsNothing,
    );
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pumpAndSettle();
    expect(find.text('Favorites (1)'), findsNWidgets(2));

    final nicknameButton = find.byTooltip('Edit nickname').first;
    await tester.ensureVisible(nicknameButton);
    await tester.pumpAndSettle();
    await tester.tap(nicknameButton);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Sprout');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Sprout'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('type-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Ivysaur'), findsNothing);
  });
}

http.Response httpResponse(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);
