import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/spoonacular_provider.dart';
import '../../models/spoonacular_models.dart';
import '../../widgets/spoonacular_recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import 'spoonacular_recipe_detail_screen.dart';

class SpoonacularSearchScreen extends StatefulWidget {
  const SpoonacularSearchScreen({super.key});

  @override
  State<SpoonacularSearchScreen> createState() => _SpoonacularSearchScreenState();
}

class _SpoonacularSearchScreenState extends State<SpoonacularSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  
  late TabController _tabController;
  String? _selectedCuisine;
  String? _selectedDiet;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar recetas aleatorias al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpoonacularProvider>().getRandomRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ingredientsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Recetas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Buscar', icon: Icon(Icons.search)),
            Tab(text: 'Ingredientes', icon: Icon(Icons.kitchen)),
            Tab(text: 'Descubrir', icon: Icon(Icons.explore)),
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
              context.go('/home');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              // Ya estamos en spoonacular
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
    return Consumer<SpoonacularProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildSearchForm(),
            if (provider.error != null) _buildErrorWidget(provider.error!),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecipeGrid(provider.searchResults),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientsTab() {
    return Consumer<SpoonacularProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildIngredientsForm(),
            if (provider.error != null) _buildErrorWidget(provider.error!),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecipeGrid(provider.recipesByIngredients),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<SpoonacularProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildDiscoverControls(),
            if (provider.error != null) _buildErrorWidget(provider.error!),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecipeGrid(provider.randomRecipes),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar recetas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCuisine,
                    decoration: const InputDecoration(
                      labelText: 'Cocina',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'mexican', child: Text('Mexicana')),
                      DropdownMenuItem(value: 'latin american', child: Text('Latinoamericana')),
                      DropdownMenuItem(value: 'spanish', child: Text('Española')),
                      DropdownMenuItem(value: 'italian', child: Text('Italiana')),
                      DropdownMenuItem(value: 'asian', child: Text('Asiática')),
                    ],
                    onChanged: (value) => setState(() => _selectedCuisine = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDiet,
                    decoration: const InputDecoration(
                      labelText: 'Dieta',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todas')),
                      DropdownMenuItem(value: 'vegetarian', child: Text('Vegetariana')),
                      DropdownMenuItem(value: 'vegan', child: Text('Vegana')),
                      DropdownMenuItem(value: 'gluten free', child: Text('Sin Gluten')),
                      DropdownMenuItem(value: 'ketogenic', child: Text('Keto')),
                      DropdownMenuItem(value: 'paleo', child: Text('Paleo')),
                    ],
                    onChanged: (value) => setState(() => _selectedDiet = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _performSearch,
                icon: const Icon(Icons.search),
                label: Text(_isSearching ? 'Buscando...' : 'Buscar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredientes (separados por comas)',
                prefixIcon: Icon(Icons.kitchen),
                border: OutlineInputBorder(),
                hintText: 'pollo, arroz, tomate',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchByIngredients,
                icon: const Icon(Icons.search),
                label: Text(_isSearching ? 'Buscando...' : 'Buscar por Ingredientes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverControls() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Descubre nuevas recetas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _getRandomRecipes('mexican'),
                  child: const Text('Mexicanas'),
                ),
                ElevatedButton(
                  onPressed: () => _getRandomRecipes('vegetarian'),
                  child: const Text('Vegetarianas'),
                ),
                ElevatedButton(
                  onPressed: () => _getRandomRecipes('dessert'),
                  child: const Text('Postres'),
                ),
                ElevatedButton(
                  onPressed: () => _getRandomRecipes(),
                  child: const Text('Aleatorias'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(List<SpoonacularRecipe> recipes) {
    if (recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron recetas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return SpoonacularRecipeCard(
          recipe: recipes[index],
          onTap: () => _navigateToRecipeDetail(recipes[index]),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          TextButton(
            onPressed: () => context.read<SpoonacularProvider>().clearError(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    
    await context.read<SpoonacularProvider>().searchRecipes(
      query: _searchController.text.trim(),
      cuisine: _selectedCuisine,
      diet: _selectedDiet,
    );
    
    setState(() => _isSearching = false);
  }

  Future<void> _searchByIngredients() async {
    if (_ingredientsController.text.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    
    final ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    await context.read<SpoonacularProvider>().searchRecipesByIngredients(
      ingredients: ingredients,
    );
    
    setState(() => _isSearching = false);
  }

  Future<void> _getRandomRecipes([String? tags]) async {
    await context.read<SpoonacularProvider>().getRandomRecipes(tags: tags);
  }

  void _navigateToRecipeDetail(SpoonacularRecipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpoonacularRecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}
