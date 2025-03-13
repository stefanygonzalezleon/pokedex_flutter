import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemonList(int limit, int offset) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Pokemon> pokemons = [];

      for (var item in data['results']) {
        final pokemonResponse = await http.get(Uri.parse(item['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          pokemons.add(Pokemon.fromJson(pokemonData));
        }
      }

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  Future<Pokemon> getPokemonDetails(String nameOrId) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$nameOrId'));

    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  Future<List<Pokemon>> searchPokemon(String query) async {
    try {
      final pokemon = await getPokemonDetails(query.toLowerCase());
      return [pokemon];
    } catch (e) {
      return [];
    }
  }
}