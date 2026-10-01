import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_application1/screens/pokedex_screen.dart';
import 'package:flutter_application1/services/pokemon_service.dart';

void main() {
  testWidgets('shows the fetched Pokémon in a grid', (WidgetTester tester) async {
    final service = PokemonService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['limit'], '30');
        return httpResponse({
          'results': [
            {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
            {'name': 'ivysaur', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
          ],
        });
      }),
    );

    await tester.pumpWidget(MaterialApp(home: PokedexScreen(service: service)));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);
  });
}

http.Response httpResponse(Map<String, dynamic> body) => http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
