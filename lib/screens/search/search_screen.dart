import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/edamam_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/navigation_helper_enhanced.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/bottom_navigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _ingredientsController = TextEditingController();
  String _selectedRegion = '';
  String _selectedDifficulty = '';
  bool _isSearchingByIngredients = false;

  @override
  void dispose() {
    _searchController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigationHelper.goBack(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.search),
          leading: SmartBackButton(),
        ),
        body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Tabs de búsqueda
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Por Nombre'),
                        selected: !_isSearchingByIngredients,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isSearchingByIngredients = false;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Por Ingredientes'),
                        selected: _isSearchingByIngredients,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isSearchingByIngredients = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Campo de búsqueda
                TextField(
                  controller: _isSearchingByIngredients ? _ingredientsController : _searchController,
                  decoration: InputDecoration(
                    hintText: _isSearchingByIngredients 
                        ? 'Ej: tomate, cebolla, ajo'
                        : 'Buscar recetas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (_isSearchingByIngredients) {
                          _ingredientsController.clear();
                        } else {
                          _searchController.clear();
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) => _performSearch(),
                ),
                const SizedBox(height: 16),
                
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filtro por región
                      FilterChip(
                        label: Text(_selectedRegion.isEmpty ? 'Región' : _selectedRegion),
                        selected: _selectedRegion.isNotEmpty,
                        onSelected: (selected) => _showRegionDialog(),
                      ),
                      const SizedBox(width: 8),
                      
                      // Filtro por dificultad
                      FilterChip(
                        label: Text(_selectedDifficulty.isEmpty ? 'Dificultad' : _selectedDifficulty),
                        selected: _selectedDifficulty.isNotEmpty,
                        onSelected: (selected) => _showDifficultyDialog(),
                      ),
                      const SizedBox(width: 8),
                      
                      // Botón de limpiar filtros
                      if (_selectedRegion.isNotEmpty || _selectedDifficulty.isNotEmpty)
                        ActionChip(
                          label: const Text('Limpiar'),
                          onPressed: _clearFilters,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botón de búsqueda
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),
          
          // Resultados de búsqueda
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, _) {
                if (recipeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (recipeProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          recipeProvider.errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final recipes = recipeProvider.recipes;
                
                if (recipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppStrings.noResults,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos de búsqueda',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () => context.go('/recipe/${recipe.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
      ),
      ),
    );
  }

  void _performSearch() {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (_isSearchingByIngredients) {
      final ingredients = AppHelpers.stringToList(_ingredientsController.text);
      if (ingredients.isNotEmpty) {
        recipeProvider.searchRecipesByIngredients(ingredients);
      }
    } else {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        // Para búsqueda por nombre, usamos EDAMAM
        final edamamProvider = context.read<EdamamProvider>();
        edamamProvider.searchRecipes(query: query);
      }
    }
  }

  void _showRegionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Región'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: AppConstants.latinAmericanRegions.length,
            itemBuilder: (context, index) {
              final region = AppConstants.latinAmericanRegions[index];
              return ListTile(
                title: Text(region),
                trailing: _selectedRegion == region ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _selectedRegion = region;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRegion = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Dificultad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:                   AppConstants.difficultyLevels.map((difficulty) {
            return ListTile(
              title: Text(difficulty),
              trailing: _selectedDifficulty == difficulty ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDifficulty = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedRegion = '';
      _selectedDifficulty = '';
    });
  }
}
