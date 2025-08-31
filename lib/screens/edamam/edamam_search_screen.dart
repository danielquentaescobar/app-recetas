import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/edamam_provider.dart';
import '../../models/edamam_models.dart';
import '../../widgets/edamam_recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

class EdamamSearchScreen extends StatefulWidget {
  const EdamamSearchScreen({super.key});

  @override
  State<EdamamSearchScreen> createState() => _EdamamSearchScreenState();
}

class _EdamamSearchScreenState extends State<EdamamSearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  // Filtros
  String? _selectedDiet;
  List<String> _selectedHealthLabels = [];
  String? _selectedCuisine;
  String? _selectedMealType;
  String? _selectedDishType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar recetas aleatorias al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EdamamProvider>().getRandomRecipes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar con EDAMAM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: 'Buscar',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Ingredientes',
            ),
            Tab(
              icon: Icon(Icons.explore),
              text: 'Descubrir',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildIngredientsTab(),
          _buildDiscoverTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              // Ya estamos aquí
              break;
            case 3:
              context.go('/favorites');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildSearchTab() {
    return Consumer<EdamamProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar recetas...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: _showFiltersDialog,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) => _performSearch(value),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _performSearch(_searchController.text),
                    child: const Text('Buscar Recetas'),
                  ),
                ],
              ),
            ),

            // Resultados de búsqueda
            Expanded(
              child: _buildSearchResults(provider.searchResults, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientsTab() {
    return Consumer<EdamamProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Input de ingredientes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredientes que tienes:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(
                      hintText: 'Ejemplo: pollo, arroz, cebolla',
                      prefixIcon: const Icon(Icons.kitchen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _searchByIngredients(),
                    child: const Text('Buscar por Ingredientes'),
                  ),
                ],
              ),
            ),

            // Resultados por ingredientes
            Expanded(
              child: _buildSearchResults(provider.ingredientResults, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<EdamamProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Opciones de descubrimiento
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => provider.getRandomRecipes(),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Aleatorias'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => provider.getHealthyRecipes(),
                          icon: const Icon(Icons.favorite),
                          label: const Text('Saludables'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Botones por tipo de comida
                  Wrap(
                    spacing: 8,
                    children: EdamamFilters.mealTypes.map((mealType) {
                      return ElevatedButton(
                        onPressed: () => provider.getRecipesByMealType(
                          mealType: mealType,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[100],
                          foregroundColor: Colors.orange[800],
                        ),
                        child: Text(mealType),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Resultados de descubrimiento
            Expanded(
              child: _buildSearchResults(
                provider.randomRecipes.isNotEmpty 
                    ? provider.randomRecipes 
                    : provider.recipes, 
                provider,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(List<EdamamRecipe> recipes, EdamamProvider provider) {
    if (provider.isLoading && recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando recetas en EDAMAM...'),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.clearError(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron recetas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: recipes.length + (provider.hasMoreResults ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == recipes.length) {
          // Botón para cargar más
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: provider.isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _loadMore(provider),
                      child: const Text('Cargar más recetas'),
                    ),
            ),
          );
        }

        final recipe = recipes[index];
        return EdamamRecipeCard(
          recipe: recipe,
          onTap: () => _navigateToRecipeDetail(recipe),
        );
      },
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    context.read<EdamamProvider>().searchRecipes(
      query: query,
      diet: _selectedDiet,
      health: _selectedHealthLabels,
      cuisineType: _selectedCuisine,
      mealType: _selectedMealType,
      dishType: _selectedDishType,
    );
  }

  void _searchByIngredients() {
    final ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) return;

    context.read<EdamamProvider>().searchRecipesByIngredients(
      ingredients: ingredients,
      diet: _selectedDiet,
      health: _selectedHealthLabels,
      cuisineType: _selectedCuisine,
      mealType: _selectedMealType,
    );
  }

  void _loadMore(EdamamProvider provider) {
    // Implementar lógica de carga más según la pestaña activa
    final currentTab = _tabController.index;
    
    switch (currentTab) {
      case 0: // Búsqueda
        provider.loadMoreResults(
          lastQuery: _searchController.text,
          searchType: 'search',
        );
        break;
      case 1: // Ingredientes
        final ingredients = _ingredientsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        provider.loadMoreResults(
          lastIngredients: ingredients,
          searchType: 'ingredients',
        );
        break;
      case 2: // Descubrir
        provider.loadMoreResults(searchType: 'random');
        break;
    }
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros de Búsqueda'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dieta
                  const Text('Dieta:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedDiet,
                    hint: const Text('Seleccionar dieta'),
                    isExpanded: true,
                    items: EdamamFilters.dietTypes.map((diet) {
                      return DropdownMenuItem(value: diet, child: Text(diet));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDiet = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tipo de cocina
                  const Text('Cocina:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedCuisine,
                    hint: const Text('Seleccionar cocina'),
                    isExpanded: true,
                    items: EdamamFilters.cuisineTypes.map((cuisine) {
                      return DropdownMenuItem(value: cuisine, child: Text(cuisine));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCuisine = value),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDiet = null;
                _selectedCuisine = null;
                _selectedMealType = null;
                _selectedDishType = null;
                _selectedHealthLabels.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _navigateToRecipeDetail(EdamamRecipe recipe) {
    context.push('/edamam/recipe/${Uri.encodeComponent(recipe.uri)}');
  }
}
