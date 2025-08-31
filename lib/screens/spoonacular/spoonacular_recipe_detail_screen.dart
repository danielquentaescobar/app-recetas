import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/spoonacular_models.dart';
import '../../providers/spoonacular_provider.dart';

class SpoonacularRecipeDetailScreen extends StatefulWidget {
  final SpoonacularRecipe recipe;

  const SpoonacularRecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<SpoonacularRecipeDetailScreen> createState() =>
      _SpoonacularRecipeDetailScreenState();
}

class _SpoonacularRecipeDetailScreenState
    extends State<SpoonacularRecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar información detallada de la receta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpoonacularProvider>().getRecipeDetails(widget.recipe.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SpoonacularProvider>(
        builder: (context, provider, child) {
          final detailedRecipe = provider.selectedRecipe ?? widget.recipe;
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(detailedRecipe),
              SliverToBoxAdapter(
                child: provider.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _buildRecipeContent(detailedRecipe),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(SpoonacularRecipe recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.title,
          style: const TextStyle(
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: recipe.image.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey,
                        ),
                      );
                    },
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
              )
            : Container(
                color: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRecipeContent(SpoonacularRecipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipeInfo(recipe),
          const SizedBox(height: 24),
          _buildSummary(recipe),
          const SizedBox(height: 24),
          _buildIngredients(recipe),
          const SizedBox(height: 24),
          _buildInstructions(recipe),
          const SizedBox(height: 24),
          _buildNutritionInfo(recipe),
          const SizedBox(height: 24),
          _buildSourceInfo(recipe),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo(SpoonacularRecipe recipe) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              icon: Icons.access_time,
              label: 'Tiempo',
              value: recipe.readyInMinutes > 0 
                  ? '${recipe.readyInMinutes} min' 
                  : 'N/A',
            ),
            _buildInfoItem(
              icon: Icons.people,
              label: 'Porciones',
              value: recipe.servings > 0 
                  ? '${recipe.servings}' 
                  : 'N/A',
            ),
            _buildInfoItem(
              icon: Icons.restaurant,
              label: 'Fuente',
              value: 'Spoonacular',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(SpoonacularRecipe recipe) {
    if (recipe.summary.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _cleanHtmlTags(recipe.summary),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients(SpoonacularRecipe recipe) {
    if (recipe.extendedIngredients.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: recipe.extendedIngredients
                  .map((ingredient) => _buildIngredientItem(ingredient))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(SpoonacularIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.original.isNotEmpty
                  ? ingredient.original
                  : '${ingredient.amount} ${ingredient.unit} ${ingredient.name}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(SpoonacularRecipe recipe) {
    if (recipe.analyzedInstructions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instrucciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: recipe.analyzedInstructions
                  .expand((instruction) => instruction.steps)
                  .map((step) => _buildInstructionStep(step))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(SpoonacularStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.number}',
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
              step.step,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(SpoonacularRecipe recipe) {
    if (recipe.nutrition == null || recipe.nutrition!.nutrients.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final mainNutrients = recipe.nutrition!.nutrients
        .where((n) => ['Calories', 'Protein', 'Fat', 'Carbohydrates'].contains(n.name))
        .toList();
    
    if (mainNutrients.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Nutricional',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: mainNutrients
                  .map((nutrient) => _buildNutrientItem(nutrient))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientItem(SpoonacularNutrient nutrient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient.name,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${nutrient.amount.toStringAsFixed(1)} ${nutrient.unit}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceInfo(SpoonacularRecipe recipe) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Fuente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Esta receta proviene de Spoonacular API',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            if (recipe.sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ver receta original en el sitio web',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _cleanHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
