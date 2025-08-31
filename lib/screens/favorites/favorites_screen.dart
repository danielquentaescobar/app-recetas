import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/modern_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Diferir la carga hasta después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (authProvider.userModel != null) {
      recipeProvider.loadFavoriteRecipes(authProvider.userModel!.favoriteRecipes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: GradientBackground(
        isDark: themeProvider.isDarkMode,
        child: Column(
          children: [
            _buildModernAppBar(),
            _buildSearchAndFilters(),
            Expanded(child: _buildFavoritesContent()),
          ],
        ),
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
              // Ya estamos en favorites
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildModernAppBar() {
    return GradientAppBar(
      title: 'Mis Favoritos ❤️',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _loadFavorites,
          tooltip: 'Actualizar',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'clear_search':
                _clearSearch();
                break;
              case 'sort_name':
                _sortByName();
                break;
              case 'sort_date':
                _sortByDate();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_search',
              child: Row(
                children: [
                  Icon(Icons.clear),
                  SizedBox(width: 8),
                  Text('Limpiar búsqueda'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha),
                  SizedBox(width: 8),
                  Text('Ordenar por nombre'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 8),
                  Text('Ordenar por fecha'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar en favoritos...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtros por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todas'),
                _buildFilterChip('Entrada'),
                _buildFilterChip('Plato Principal'),
                _buildFilterChip('Postre'),
                _buildFilterChip('Bebida'),
                _buildFilterChip('Desayuno'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    const primaryColor = Colors.orange;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? filter : 'Todas';
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<AuthProvider, RecipeProvider>(
        builder: (context, authProvider, recipeProvider, _) {
          if (authProvider.userModel == null) {
            return _buildNotLoggedIn();
          }

          if (recipeProvider.isLoading) {
            return _buildLoadingState();
          }

          if (recipeProvider.errorMessage != null) {
            return _buildErrorState(recipeProvider.errorMessage!);
          }

          final favoriteRecipes = _getFilteredRecipes(recipeProvider.favoriteRecipes);

          if (favoriteRecipes.isEmpty) {
            return _buildEmptyState();
          }

          return _buildRecipesList(favoriteRecipes, authProvider, recipeProvider);
        },
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return ResponsivePadding(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Inicia sesión para ver tus favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Guarda tus recetas favoritas y accede a ellas desde cualquier lugar',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.login),
              label: const Text('Iniciar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const ResponsivePadding(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando tus favoritos...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return ResponsivePadding(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasFilter = _selectedFilter != 'Todas';
    
    return ResponsivePadding(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch || hasFilter ? Icons.search_off_rounded : Icons.favorite_border_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch || hasFilter 
                  ? 'No se encontraron recetas'
                  : 'No tienes recetas favoritas',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch || hasFilter
                  ? 'Prueba con otros términos de búsqueda o filtros'
                  : 'Explora recetas y marca tus favoritas con ❤️',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasSearch || hasFilter) ...[
              ElevatedButton.icon(
                onPressed: () {
                  _clearSearch();
                  setState(() {
                    _selectedFilter = 'Todas';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.explore),
              label: const Text('Buscar Recetas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(List<dynamic> recipes, AuthProvider authProvider, RecipeProvider recipeProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadFavorites();
      },
      color: Colors.orange,
      child: ResponsivePadding(
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _buildFavoriteRecipeCard(recipe, authProvider, recipeProvider);
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteRecipeCard(dynamic recipe, AuthProvider authProvider, RecipeProvider recipeProvider) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          RecipeCard(
            recipe: recipe,
            onTap: () => context.go('/recipe/${recipe.id}'),
          ),
          
          // Botón de favorito personalizado
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
                onPressed: () => _removeFavorite(recipe.id, authProvider, recipeProvider),
                tooltip: 'Quitar de favoritos',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FUNCIONES AUXILIARES

  List<dynamic> _getFilteredRecipes(List<dynamic> recipes) {
    var filtered = recipes;
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               recipe.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(_searchQuery.toLowerCase())) ||
               recipe.tags.any((tag) => 
                 tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
    
    // Filtrar por categoría
    if (_selectedFilter != 'Todas') {
      filtered = filtered.where((recipe) {
        return recipe.categories.any((category) => 
          category.toLowerCase().contains(_selectedFilter.toLowerCase()));
      }).toList();
    }
    
    return filtered;
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _sortByName() {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final recipes = List.from(recipeProvider.favoriteRecipes);
    recipes.sort((a, b) => a.title.compareTo(b.title));
    // Implementar sorting en provider si es necesario
  }

  void _sortByDate() {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final recipes = List.from(recipeProvider.favoriteRecipes);
    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Implementar sorting en provider si es necesario
  }

  Future<void> _removeFavorite(String recipeId, AuthProvider authProvider, RecipeProvider recipeProvider) async {
    final user = authProvider.userModel;
    if (user == null) return;

    // Mostrar confirmación
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.red),
            SizedBox(width: 8),
            Text('Quitar de favoritos'),
          ],
        ),
        content: const Text('¿Estás seguro de que deseas quitar esta receta de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      final success = await recipeProvider.removeFromFavorites(user.id, recipeId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Receta quitada de favoritos'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Error al quitar de favoritos'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
