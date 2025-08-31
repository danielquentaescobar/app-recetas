import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/mealdb_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import '../../models/recipe_model.dart';

class MealDBSearchScreen extends StatefulWidget {
  const MealDBSearchScreen({super.key});

  @override
  State<MealDBSearchScreen> createState() => _MealDBSearchScreenState();
}

class _MealDBSearchScreenState extends State<MealDBSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealDBProvider>();
      provider.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final provider = context.read<MealDBProvider>();
    await provider.searchRecipes(query: query);

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Buscar en TheMealDB',
        showBackButton: true,
        fallbackRoute: '/home',
      ),
      body: Consumer<MealDBProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildSearchBar(),
              _buildCategoriesSection(provider),
              Expanded(
                child: _buildSearchResults(provider),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2, // TheMealDB es el índice 2
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: ModernCard(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar recetas internacionales...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: themeProvider.primaryColor,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSearching ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(MealDBProvider provider) {
    if (provider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorías Populares',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categories.length > 10 ? 10 : provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = category.name;
                        _performSearch();
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: category.image != null
                                  ? Image.network(
                                      category.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.restaurant_menu,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(MealDBProvider provider) {
    if (_searchController.text.trim().isEmpty) {
      return _buildEmptyState();
    }

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(provider.errorMessage!);
    }

    if (provider.searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ResponsivePadding(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.searchResults.length,
        itemBuilder: (context, index) {
          final mealDBRecipe = provider.searchResults[index];
          final appData = mealDBRecipe.toAppFormat();
          final recipe = Recipe(
            id: appData['id'],
            title: appData['title'],
            description: appData['description'],
            imageUrl: appData['imageUrl'],
            authorId: 'mealdb',
            authorName: 'TheMealDB',
            ingredients: (appData['ingredients'] as List<dynamic>).cast<String>(),
            instructions: (appData['instructions'] as List<dynamic>).cast<String>(),
            preparationTime: appData['preparationTime'],
            cookingTime: appData['cookingTime'],
            servings: appData['servings'],
            difficulty: appData['difficulty'],
            region: appData['region'],
            tags: [appData['category']],
            categories: [appData['region']],
            rating: 0,
            reviewsCount: 0,
            likedBy: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isPublic: true,
          );
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RecipeCard(
              recipe: recipe,
              onTap: () => context.go('/mealdb/recipe/${mealDBRecipe.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Busca recetas internacionales',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Escribe el nombre de un plato o ingrediente para comenzar',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error en la búsqueda',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron recetas para "${_searchController.text}"',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }
}
