import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/mealdb_models.dart';
import '../../providers/mealdb_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/modern_widgets.dart';

class MealDBRecipeDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDBRecipeDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<MealDBRecipeDetailScreen> createState() => _MealDBRecipeDetailScreenState();
}

class _MealDBRecipeDetailScreenState extends State<MealDBRecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealDBProvider>();
      provider.loadRecipeById(widget.mealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealDBProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (provider.selectedRecipe == null) {
            return _buildNotFoundState();
          }

          return _buildRecipeDetail(provider.selectedRecipe!);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
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
              'Error al cargar la receta',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receta no encontrada'),
      ),
      body: Center(
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
              'Receta no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'No se pudo encontrar la receta solicitada.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDetail(MealDBRecipe recipe) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(recipe),
        SliverToBoxAdapter(
          child: ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildRecipeInfo(recipe),
                const SizedBox(height: 24),
                _buildIngredients(recipe),
                const SizedBox(height: 24),
                _buildInstructions(recipe),
                const SizedBox(height: 24),
                _buildVideoSection(recipe),
                const SizedBox(height: 24),
                _buildSourceSection(recipe),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(MealDBRecipe recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe.image != null)
              Image.network(
                recipe.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(MealDBRecipe recipe) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Información de la Receta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Categoría', recipe.category ?? 'No especificada'),
          _buildInfoRow('Región', recipe.area ?? 'Internacional'),
          _buildInfoRow('Tiempo estimado', '${recipe.cookingTime} minutos'),
          _buildInfoRow('Porciones', '${recipe.servings} personas'),
          _buildInfoRow('Dificultad', recipe.difficulty),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(MealDBRecipe recipe) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Ingredientes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recipe.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
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
                  Expanded(
                    child: Text(
                      ingredient.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInstructions(MealDBRecipe recipe) {
    final themeProvider = context.watch<ThemeProvider>();
    final instructions = recipe.formatInstructions(recipe.instructions ?? '');
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (instructions.isEmpty)
            Text(
              recipe.instructions ?? 'No hay instrucciones disponibles.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        instruction,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildVideoSection(MealDBRecipe recipe) {
    if (recipe.video == null || recipe.video!.isEmpty) {
      return const SizedBox.shrink();
    }

    final themeProvider = context.watch<ThemeProvider>();
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Video Tutorial',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Aquí podrías abrir el video en una nueva pantalla o navegador
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Video: ${recipe.video}'),
                    action: SnackBarAction(
                      label: 'Abrir',
                      onPressed: () {
                        // Implementar navegación al video
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ver Video Tutorial'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(MealDBRecipe recipe) {
    if (recipe.source == null || recipe.source!.isEmpty) {
      return const SizedBox.shrink();
    }

    final themeProvider = context.watch<ThemeProvider>();
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_outlined,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Fuente Original',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fuente: ${recipe.source}'),
                    action: SnackBarAction(
                      label: 'Abrir',
                      onPressed: () {
                        // Implementar navegación a la fuente
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ver Fuente Original'),
            ),
          ),
        ],
      ),
    );
  }
}
