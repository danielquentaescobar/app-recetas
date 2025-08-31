import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/mealdb_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper_enhanced.dart';
import '../../utils/auth_dialog.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/modern_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final mealDBProvider = Provider.of<MealDBProvider>(context, listen: false);
      
      recipeProvider.loadPublicRecipes();
      // Cargar recetas aleatorias de MealDB (gratuita y sin límites)
      mealDBProvider.loadRandomRecipes(count: 12);
    });
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
            GradientAppBar(
              title: AppConstants.appName,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: () => context.go('/search'),
                  tooltip: 'Buscar recetas',
                ),
                IconButton(
                  icon: const Icon(Icons.public_rounded, color: Colors.white),
                  onPressed: () => context.go('/mealdb'),
                  tooltip: 'Buscar recetas internacionales',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        context.go('/profile');
                        break;
                      case 'logout':
                        _showLogoutDialog();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_rounded),
                          SizedBox(width: 8),
                          Text('Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            _buildCategorySection(),
            
            Expanded(
              child: _buildUnifiedRecipesView(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/mealdb');
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

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explora por categorías',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.watch<ThemeProvider>().textColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryButton(
                  title: 'Platos Principales',
                  icon: Icons.restaurant_rounded,
                  color: AppTheme.primaryRed,
                  onPressed: () => _filterByCategory('plato principal'),
                  isSelected: _selectedCategory == 'plato principal',
                ),
                CategoryButton(
                  title: 'Postres',
                  icon: Icons.cake_rounded,
                  color: AppTheme.primaryYellow,
                  onPressed: () => _filterByCategory('postre'),
                  isSelected: _selectedCategory == 'postre',
                ),
                CategoryButton(
                  title: 'Entradas',
                  icon: Icons.local_dining_rounded,
                  color: AppTheme.primaryGreen,
                  onPressed: () => _filterByCategory('entrada'),
                  isSelected: _selectedCategory == 'entrada',
                ),
                CategoryButton(
                  title: 'Bebidas',
                  icon: Icons.local_bar_rounded,
                  color: AppTheme.primaryBlue,
                  onPressed: () => _filterByCategory('bebida'),
                  isSelected: _selectedCategory == 'bebida',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección promocional de TheMealDB
  Widget _buildMealDBPromoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TheMealDB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Recetas gratuitas de todo el mundo',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '🌍 Recetas internacionales auténticas\n🍽️ Miles de platos tradicionales\n� API gratuita y sin límites',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/mealdb'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.explore),
                    label: const Text(
                      'Explorar TheMealDB',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedRecipesView() {
    return Consumer2<RecipeProvider, MealDBProvider>(
      builder: (context, recipeProvider, mealDBProvider, _) {
        final isLoading = recipeProvider.isLoading || mealDBProvider.isLoading;
        
        if (isLoading) {
          return _buildLoadingGrid();
        }

        final hasLocalRecipes = recipeProvider.recipes.isNotEmpty;
        final hasMealDBRecipes = mealDBProvider.randomRecipes.isNotEmpty;

        if (!hasLocalRecipes && !hasMealDBRecipes) {
          return _buildEmptyState();
        }

        return ResponsivePadding(
          child: CustomScrollView(
            slivers: [
              // Sección de recetas locales
              if (hasLocalRecipes) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recetas de la Comunidad',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = recipeProvider.recipes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: RecipeCard(
                          recipe: recipe,
                          onTap: () => context.go('/recipe/${recipe.id}'),
                        ),
                      );
                    },
                    childCount: recipeProvider.recipes.length,
                  ),
                ),
              ],
              
              // Sección de recetas de TheMealDB
              if (hasMealDBRecipes) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.public_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recetas Internacionales - TheMealDB',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.go('/mealdb'),
                          icon: const Icon(Icons.explore_outlined),
                          label: const Text('Ver más'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final mealDBRecipe = mealDBProvider.randomRecipes[index];
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
                    childCount: mealDBProvider.randomRecipes.length,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return ResponsivePadding(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const ModernCard(
            child: Column(
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 150,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ShimmerLoading(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Center(
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: themeProvider.subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las recetas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeProvider.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
                recipeProvider.loadPublicRecipes();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Center(
      child: ModernCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 64,
              color: themeProvider.subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay recetas aún',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en compartir una deliciosa receta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeProvider.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-recipe'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear Receta'),
            ),
          ],
        ),
      ),
    );
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? '' : category;
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (mounted) {
                  context.go('/login');
                }
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Construir botón flotante con menú de opciones
  Widget _buildFloatingActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return FloatingActionButton.extended(
          onPressed: () async {
            if (authProvider.userModel != null) {
              _showCreateMenu();
            } else {
              await AuthDialog.showLoginRequiredDialog(context, 'crear una receta');
            }
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Crear'),
          backgroundColor: AppTheme.primaryRed,
        );
      },
    );
  }

  /// Mostrar menú de opciones para crear contenido
  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '¿Qué quieres crear?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.primaryRed,
                  ),
                ),
                title: const Text('Nueva Receta'),
                subtitle: const Text('Comparte una receta original'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  NavigationHelper.goToAddRecipe(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                title: const Text('Buscar Recetas'),
                subtitle: const Text('Explora nuevas recetas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  NavigationHelper.goToSearch(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.green,
                  ),
                ),
                title: const Text('Explorar TheMealDB'),
                subtitle: const Text('Recetas gratuitas de todo el mundo'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/mealdb');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Colors.orange,
                  ),
                ),
                title: const Text('Explorar Spoonacular'),
                subtitle: const Text('Miles de recetas internacionales'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/spoonacular');
                },
              ),
              // Botón temporal para limpiar datos de prueba
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Limpiar Datos de Prueba'),
                subtitle: const Text('Eliminar todas las recetas (DEV)'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  Navigator.pop(context);
                  
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('⚠️ Confirmar Limpieza'),
                      content: const Text('¿Estás seguro de que quieres eliminar TODAS las recetas de Firebase? Esta acción no se puede deshacer.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Eliminar Todo', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
                    await recipeProvider.clearAllRecipes();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Todas las recetas han sido eliminadas'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
