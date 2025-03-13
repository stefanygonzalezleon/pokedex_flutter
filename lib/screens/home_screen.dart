import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<Pokemon> _pokemonList = [];
  List<Pokemon> _filteredPokemonList = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    try {
      final pokemons = await _pokemonService.getPokemonList(20, 0);
      setState(() {
        _pokemonList = pokemons;
        _filteredPokemonList = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Pokémon: $e')),
      );
    }
  }

  // Actualiza este método para buscar en la API
  Future<void> _filterPokemon(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredPokemonList = _pokemonList;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Primero busca en la lista local
    final localResults = _pokemonList.where((pokemon) {
      final pokemonIdString = pokemon.id.toString();
      final nameLower = pokemon.name.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          pokemonIdString.contains(searchLower);
    }).toList();

    if (localResults.isNotEmpty) {
      setState(() {
        _filteredPokemonList = localResults;
        _isSearching = false;
      });
      return;
    }

    // Si no hay resultados locales, busca en la API
    try {
      final results = await _pokemonService.searchPokemon(query);
      setState(() {
        _filteredPokemonList = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _filteredPokemonList = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró ningún Pokémon: $e')),
      );
    }
  }

  // En el método build, actualiza el contenido central para mostrar un indicador de carga durante la búsqueda
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/pokedex_logo.png',
                width: 150,
              ),
              const SizedBox(height: 10),
              const Text(
                'Search for Pokémon by name or using the National Pokédex number.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterPokemon,
                  decoration: const InputDecoration(
                    hintText: 'What Pokémon are you looking for?',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPokemonList.isEmpty
                    ? const Center(child: Text('No Pokémon found'))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredPokemonList.length,
                  itemBuilder: (context, index) {
                    final pokemon = _filteredPokemonList[index];
                    return _buildPokemonCard(pokemon);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(pokemon: pokemon),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: pokemon.typeColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  pokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 80);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      pokemon.formattedId,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}