import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe_model.dart';
import '../../models/review_model.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/auth_dialog.dart';
import '../../widgets/smart_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;
  List<Review> _reviews = [];
  bool _loadingReviews = false;
  final _reviewController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      
      // Buscar la receta en la lista actual
      final recipe = recipeProvider.recipes.where((r) => r.id == widget.recipeId).firstOrNull;
      
      if (recipe != null) {
        setState(() {
          _recipe = recipe;
          _isLoading = false;
        });
        await _loadReviews();
      } else {
        // Si no está en la lista, cargar todas las recetas
        recipeProvider.loadPublicRecipes();
        
        // Esperar un poco para que se carguen
        await Future.delayed(const Duration(seconds: 1));
        
        final loadedRecipe = recipeProvider.recipes.where((r) => r.id == widget.recipeId).firstOrNull;
        
        setState(() {
          _recipe = loadedRecipe;
          _isLoading = false;
        });
        
        if (loadedRecipe != null) {
          await _loadReviews();
        }
      }
    } catch (e) {
      print('Error loading recipe: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    if (_recipe == null) return;
    
    setState(() {
      _loadingReviews = true;
    });

    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      await recipeProvider.loadRecipeReviews(_recipe!.id);
      final reviews = recipeProvider.currentRecipeReviews;
      
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
      
      print('✅ Cargadas ${reviews.length} reseñas para la receta ${_recipe!.title}');
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _reviews = []; // Lista vacía en caso de error
        _loadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigationHelper.goBack(context, fallbackRoute: '/home');
        return false; // Prevenir el pop automático
      },
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recipe == null
                ? const Center(
                    child: Text('Receta no encontrada'),
                  )
                : CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(),
                      SliverToBoxAdapter(
                        child: _buildRecipeContent(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () {
          try {
            NavigationHelper.goBack(context, fallbackRoute: '/home');
          } catch (e) {
            print('Error en botón atrás: $e');
            GoRouter.of(context).go('/home');
          }
        },
      ),
      actions: [
        // Botón de favoritos en la AppBar
        Consumer2<AuthProvider, RecipeProvider>(
          builder: (context, authProvider, recipeProvider, _) {
            final user = authProvider.userModel;
            final isFavorite = user != null && user.favoriteRecipes.contains(widget.recipeId);
            
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                  size: 24,
                ),
              ),
              onPressed: () async {
                if (user != null) {
                  await _toggleFavorite(recipeProvider, authProvider);
                } else {
                  await AuthDialog.showLoginRequiredDialog(context, 'agregar esta receta a favoritos');
                }
              },
            );
          },
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (_recipe?.authorId == authProvider.userModel?.id) {
              return PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.go('/edit-recipe/${widget.recipeId}');
                      break;
                    case 'delete':
                      _showDeleteDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _recipe?.imageUrl.isNotEmpty == true
            ? SmartImage(
                imagePath: _recipe!.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              ),
      ),
    );
  }

  Widget _buildRecipeContent() {
    if (_recipe == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y rating
          Row(
            children: [
              Expanded(
                child: Text(
                  _recipe!.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_recipe!.rating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _recipe!.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Autor y fecha
          Row(
            children: [
              Text(
                'Por ${_recipe!.authorName}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                AppHelpers.formatRelativeDate(_recipe!.createdAt),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Información rápida
          Row(
            children: [
              _buildInfoChip(Icons.schedule, AppHelpers.formatTime(_recipe!.totalTime)),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.people, AppHelpers.formatServings(_recipe!.servings)),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.signal_cellular_alt,
                _recipe!.difficulty,
                color: _getDifficultyColor(_recipe!.difficulty),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            _recipe!.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Ingredientes
          Text(
            AppStrings.ingredients,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._recipe!.ingredients.map((ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ingredient)),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Instrucciones
          Text(
            AppStrings.instructions,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._recipe!.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(instruction)),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              // Botón de favoritos
              Expanded(
                child: Consumer2<RecipeProvider, AuthProvider>(
                  builder: (context, recipeProvider, authProvider, _) {
                    final user = authProvider.userModel;
                    final isFavorite = user != null && user.favoriteRecipes.contains(_recipe!.id);
                    
                    return ElevatedButton.icon(
                      onPressed: () async {
                        if (user != null) {
                          await _toggleFavorite(recipeProvider, authProvider);
                        } else {
                          await AuthDialog.showLoginRequiredDialog(context, 'agregar esta receta a favoritos');
                        }
                      },
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      label: Text(isFavorite ? 'En Favoritos' : 'Favorito'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFavorite ? Colors.red[50] : null,
                        foregroundColor: isFavorite ? Colors.red : null,
                        side: isFavorite ? BorderSide(color: Colors.red[300]!) : null,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: isFavorite ? 0 : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Botón de reseña
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Reseñar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Reseñas
          Text(
            '${AppStrings.reviews} (${_reviews.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_loadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No hay reseñas aún',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Sé el primero en dejar una reseña!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: review.userPhotoUrl != null && review.userPhotoUrl!.isNotEmpty
                      ? NetworkImage(review.userPhotoUrl!)
                      : null,
                  child: review.userPhotoUrl == null || review.userPhotoUrl!.isEmpty
                      ? Text(
                          AppHelpers.getInitials(review.userName.isNotEmpty ? review.userName : 'Usuario'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Estrellas
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.orange,
                                size: 18,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          // Fecha
                          Text(
                            AppHelpers.formatRelativeDate(review.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating numérico
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(RecipeProvider recipeProvider, AuthProvider authProvider) async {
    final user = authProvider.userModel;
    if (user == null || _recipe == null) return;

    final isFavorite = user.favoriteRecipes.contains(_recipe!.id);
    
    try {
      bool success;
      if (isFavorite) {
        success = await recipeProvider.removeFromFavorites(user.id, _recipe!.id);
      } else {
        success = await recipeProvider.addToFavorites(user.id, _recipe!.id);
      }

      if (mounted && success) {
        // Recargar el usuario para actualizar la lista de favoritos
        await authProvider.reloadUserData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isFavorite ? Icons.favorite_border : Icons.favorite,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(isFavorite 
                    ? 'Receta quitada de favoritos'
                    : 'Receta agregada a favoritos'),
              ],
            ),
            backgroundColor: isFavorite ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error al ${isFavorite ? 'quitar de' : 'agregar a'} favoritos'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddReviewDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.userModel == null) {
      await AuthDialog.showLoginRequiredDialog(context, 'escribir una reseña');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.rate_review, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(AppStrings.addReview),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                const Text(
                  'Calificación:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _userRating = index + 1.0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  _getRatingText(_userRating),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                // Comentario
                const Text(
                  'Comentario (opcional):',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    hintText: 'Comparte tu experiencia con esta receta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                try {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                  }
                } catch (e) {
                  print('Error cerrando diálogo: $e');
                }
                _reviewController.clear();
                setState(() {
                  _userRating = 5.0;
                });
              },
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton.icon(
              onPressed: _submitReview,
              icon: const Icon(Icons.send),
              label: const Text(AppStrings.submit),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Muy malo 😞';
      case 2:
        return 'Malo 😕';
      case 3:
        return 'Regular 😐';
      case 4:
        return 'Bueno 😊';
      case 5:
        return 'Excelente 😍';
      default:
        return 'Excelente 😍';
    }
  }

  Future<void> _submitReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (authProvider.userModel == null || _recipe == null) return;

    final user = authProvider.userModel!;
    
    // Crear la review
    final review = Review(
      id: '', // Se generará automáticamente en Firebase
      recipeId: _recipe!.id,
      userId: user.id,
      userName: user.name,
      userPhotoUrl: user.photoUrl,
      rating: _userRating,
      comment: _reviewController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Enviar la review
      final success = await recipeProvider.createReview(review);
      
      if (mounted) {
        try {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          }
        } catch (e) {
          print('Error cerrando diálogo: $e');
        }
        
        if (success) {
          // Recargar las reviews
          await _loadReviews();
          
          // Resetear el formulario
          _reviewController.clear();
          setState(() {
            _userRating = 5.0;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('¡Reseña enviada exitosamente!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Error al enviar la reseña'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          }
        } catch (e2) {
          print('Error cerrando diálogo: $e2');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Receta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta receta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              try {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                }
              } catch (e) {
                print('Error cerrando diálogo: $e');
              }
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                }
              } catch (e) {
                print('Error cerrando diálogo: $e');
              }
              
              final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
              final success = await recipeProvider.deleteRecipe(widget.recipeId);
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppHelpers.getSuccessMessage('delete')),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/home');
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return Colors.green;
      case 'intermedio':
      case 'medium':
        return Colors.orange;
      case 'difícil':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
