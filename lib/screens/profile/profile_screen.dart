import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/smart_image.dart';
import '../../utils/auth_dialog.dart';

class SmartBackButton extends StatelessWidget {
  final String fallbackRoute;
  
  const SmartBackButton({super.key, required this.fallbackRoute});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go(fallbackRoute);
        }
      },
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _favoritesLoaded = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Cargar recetas del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      
      if (authProvider.userModel != null) {
        _lastUserId = authProvider.userModel!.id;
        recipeProvider.loadUserRecipes(authProvider.userModel!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Función para obtener iniciales del nombre
  String getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return 'U';
    
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                try {
                  if (field == 'Nombre') {
                    await authProvider.updateDisplayName(controller.text);
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$field actualizado correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar $field: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInfo(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: user.photoUrl != null
                      ? ClipOval(
                          child: SmartImage(
                            imagePath: user.photoUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          getInitials((user.name?.isNotEmpty == true ? user.name : user.email) ?? 'Usuario'),
                          style: const TextStyle(fontSize: 24),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name ?? 'Sin nombre',
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog('Nombre', user.name ?? ''),
                          ),
                        ],
                      ),
                      Text(
                        user.email ?? 'Sin email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.favoriteRecipes.length} recetas favoritas',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRecipesTab(RecipeProvider recipeProvider) {
    if (recipeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final userRecipes = recipeProvider.userRecipes;

    if (userRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '¡Aún no has creado recetas!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte tus recetas favoritas con la comunidad',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-recipe'),
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primera receta'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.userModel != null) {
          recipeProvider.loadUserRecipes(authProvider.userModel!.id);
        }
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: userRecipes.length,
        itemBuilder: (context, index) {
          final recipe = userRecipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () => context.push('/recipe/${recipe.id}'),
            showAuthor: false,
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTab(user, RecipeProvider recipeProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        if (user.favoriteRecipes.isNotEmpty) {
          await recipeProvider.loadFavoriteRecipes(user.favoriteRecipes);
          setState(() {
            _favoritesLoaded = true;
          });
        }
      },
      child: Builder(
        builder: (context) {
          // Resetear flag si cambió el usuario
          if (_lastUserId != user.id) {
            _favoritesLoaded = false;
            _lastUserId = user.id;
          }

          // Cargar recetas favoritas solo una vez y si no están cargadas
          if (!_favoritesLoaded && user.favoriteRecipes.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!_favoritesLoaded && mounted) {
                await recipeProvider.loadFavoriteRecipes(user.favoriteRecipes);
                if (mounted) {
                  setState(() {
                    _favoritesLoaded = true;
                  });
                }
              }
            });
          }

          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteRecipes = recipeProvider.favoriteRecipes;

          if (user.favoriteRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Aún no tienes favoritos!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Marca recetas como favoritas para encontrarlas aquí',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.search),
                    label: const Text('Explorar recetas'),
                  ),
                ],
              ),
            );
          }

          if (favoriteRecipes.isEmpty && !_favoritesLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando recetas favoritas...'),
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
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = favoriteRecipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () => context.push('/recipe/${recipe.id}'),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, RecipeProvider>(
      builder: (context, authProvider, recipeProvider, child) {
        final user = authProvider.userModel;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Perfil'),
              centerTitle: true,
              leading: const SmartBackButton(fallbackRoute: '/home'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Únete a la comunidad!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crea una cuenta para guardar tus recetas favoritas, agregar tus propias recetas y escribir reseñas.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/register'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Registrarse'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Iniciar Sesión'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Continuar sin cuenta'),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigation(
              currentIndex: 4,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
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
                    // Ya estamos en perfil
                    break;
                }
              },
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mi Perfil'),
              centerTitle: true,
              leading: const SmartBackButton(fallbackRoute: '/home'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'logout':
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cerrar Sesión'),
                              content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Cerrar Sesión'),
                                ),
                              ],
                            );
                          },
                        );
                        
                        if (confirm == true) {
                          await authProvider.signOut();
                          if (mounted) {
                            context.go('/login');
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.restaurant_menu),
                    text: 'Mis Recetas',
                  ),
                  Tab(
                    icon: Icon(Icons.favorite),
                    text: 'Favoritos',
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                _buildUserInfo(user),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyRecipesTab(recipeProvider),
                      _buildFavoritesTab(user, recipeProvider),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigation(
              currentIndex: 4,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
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
                    // Ya estamos en perfil
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}
