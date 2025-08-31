import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/edamam_models.dart';
import '../../services/edamam_service.dart';
import 'package:flutter/services.dart';

class EdamamRecipeDetailScreen extends StatefulWidget {
  final String recipeUri;

  const EdamamRecipeDetailScreen({
    super.key,
    required this.recipeUri,
  });

  @override
  State<EdamamRecipeDetailScreen> createState() => _EdamamRecipeDetailScreenState();
}

class _EdamamRecipeDetailScreenState extends State<EdamamRecipeDetailScreen> {
  EdamamRecipe? _recipe;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  Future<void> _loadRecipeDetails() async {
    try {
      final recipe = await EdamamService().getRecipeDetails(widget.recipeUri);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando receta...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar la receta: $_error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Receta no encontrada'),
        ),
        body: const Center(
          child: Text('No se pudo cargar la receta'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _recipe!.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: _recipe!.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _recipe!.image,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 100),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 100),
                    ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _buildBasicInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Etiquetas
                  if (_recipe!.dietLabels.isNotEmpty || _recipe!.healthLabels.isNotEmpty)
                    _buildLabels(),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredientes
                  _buildIngredients(),
                  
                  const SizedBox(height: 24),
                  
                  // Información nutricional
                  if (_recipe!.totalNutrients != null)
                    _buildNutritionInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Botón para ver receta completa
                  _buildViewRecipeButton(),
                  
                  const SizedBox(height: 100), // Espacio extra al final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fuente: ${_recipe!.source}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.people,
                  '${_recipe!.yield}',
                  'Porciones',
                ),
                if (_recipe!.totalTime > 0)
                  _buildStatItem(
                    Icons.access_time,
                    '${_recipe!.totalTime}',
                    'Minutos',
                  ),
                _buildStatItem(
                  Icons.local_fire_department,
                  '${_recipe!.calories.toInt()}',
                  'Calorías',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLabels() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            if (_recipe!.dietLabels.isNotEmpty) ...[
              const Text(
                'Dieta:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _recipe!.dietLabels.map((diet) => 
                  _buildTag(diet, Colors.green[100]!, Colors.green[800]!)
                ).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            if (_recipe!.healthLabels.isNotEmpty) ...[
              const Text(
                'Salud:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _recipe!.healthLabels.take(6).map((health) => 
                  _buildTag(health, Colors.blue[100]!, Colors.blue[800]!)
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.replaceAll('-', ' '),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildIngredients() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredientes (${_recipe!.ingredientLines.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...(_recipe!.ingredientLines.map((ingredient) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo() {
    final nutrients = _recipe!.totalNutrients!.nutrients;
    final importantNutrients = ['ENERC_KCAL', 'PROCNT', 'FAT', 'CHOCDF', 'FIBTG'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Nutricional',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...importantNutrients.map((key) {
              final nutrient = nutrients[key];
              if (nutrient == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nutrient.label),
                    Text(
                      '${nutrient.quantity.toStringAsFixed(1)} ${nutrient.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRecipeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchRecipeUrl(),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Copiar URL de Receta'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _launchRecipeUrl() async {
    // Copiar URL al portapapeles
    await Clipboard.setData(ClipboardData(text: _recipe!.url));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL copiada al portapapeles: ${_recipe!.url}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
