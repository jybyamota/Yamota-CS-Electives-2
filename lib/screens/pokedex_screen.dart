import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
	const PokedexScreen({super.key});

	@override
	State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			context.read<PokemonProvider>().fetchPokemon();
		});
	}

	@override
	Widget build(BuildContext context) {
		return Consumer<PokemonProvider>(
			builder: (context, provider, child) {
				return Scaffold(
					appBar: AppBar(
						title: const Text('Pokédex List'),
						actions: [
							IconButton(
								onPressed: provider.isLoading ? null : () => provider.fetchPokemon(),
								icon: const Icon(Icons.refresh),
								tooltip: 'Refresh',
							),
						],
					),
					body: provider.isLoading
						? const Center(child: CircularProgressIndicator())
						: provider.errorMessage != null
							? _MessageState(
									message: provider.errorMessage!,
									buttonLabel: 'Retry',
									onPressed: () => provider.fetchPokemon(),
								)
							: provider.pokemons.isEmpty
								? const _MessageState(message: 'No Pokémon found.')
								: RefreshIndicator(
										onRefresh: provider.fetchPokemon,
										child: LayoutBuilder(
											builder: (context, constraints) {
												final columns = constraints.maxWidth >= 900
														? 5
														: constraints.maxWidth >= 600
																? 3
																: 2;
												return GridView.builder(
													padding: const EdgeInsets.all(12),
													gridDelegate:
														SliverGridDelegateWithFixedCrossAxisCount(
															crossAxisCount: columns,
															crossAxisSpacing: 12,
															mainAxisSpacing: 12,
															childAspectRatio: 0.82,
														),
													itemCount: provider.pokemons.length,
													itemBuilder: (context, index) {
														final pokemon = provider.pokemons[index];
														return PokemonCard(
															pokemon: pokemon,
															onTap: () {
																provider.selectPokemon(pokemon);
																Navigator.push(
																	context,
																	MaterialPageRoute(
																		builder: (_) =>
																			const PokemonDetailScreen(),
																	),
																);
															},
														);
													},
												);
											},
										),
									),
					);
			},
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