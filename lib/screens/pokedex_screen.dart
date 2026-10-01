import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
	const PokedexScreen({super.key, this.service});

	final PokemonService? service;

	@override
	State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
	late final PokemonService _service = widget.service ?? PokemonService();
	late Future<List<Pokemon>> _pokemonFuture;

	@override
	void initState() {
		super.initState();
		_pokemonFuture = _service.fetchPokemon();
	}

	void _retry() {
		setState(() {
			_pokemonFuture = _service.fetchPokemon();
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Pokédex List')),
			body: FutureBuilder<List<Pokemon>>(
				future: _pokemonFuture,
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}

					if (snapshot.hasError) {
						return _MessageState(
							message: 'Could not load Pokémon.',
							buttonLabel: 'Retry',
							onPressed: _retry,
						);
					}

					final pokemon = snapshot.data ?? const <Pokemon>[];
					if (pokemon.isEmpty) {
						return const _MessageState(message: 'No Pokémon found.');
					}

					return LayoutBuilder(
						builder: (context, constraints) {
							final columns = constraints.maxWidth >= 900
									? 5
									: constraints.maxWidth >= 600
											? 3
											: 2;
							return GridView.builder(
								padding: const EdgeInsets.all(12),
								gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: columns,
									crossAxisSpacing: 12,
									mainAxisSpacing: 12,
									childAspectRatio: 0.82,
								),
								itemCount: pokemon.length,
								itemBuilder: (context, index) =>
										PokemonCard(pokemon: pokemon[index]),
							);
						},
					);
				},
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