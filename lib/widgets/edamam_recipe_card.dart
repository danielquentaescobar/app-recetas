import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/edamam_models.dart';

class EdamamRecipeCard extends StatelessWidget {
  final EdamamRecipe recipe;
  final VoidCallback? onTap;

  const EdamamRecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: recipe.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    recipe.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),

                  // Fuente
                  if (recipe.source.isNotEmpty)
                    Text(
                      'Por ${recipe.source}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),

                  const SizedBox(height: 12),

                  // Información nutricional
                  Row(
                    children: [
                      if (recipe.totalTime > 0) ...[
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalTime} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.yield} porcion${recipe.yield != 1 ? 'es' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories.toInt()} cal',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Etiquetas de dieta y salud
                  if (recipe.dietLabels.isNotEmpty || recipe.healthLabels.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Etiquetas de dieta
                        ...recipe.dietLabels.take(2).map((diet) => 
                          _buildTag(diet, Colors.green[100]!, Colors.green[800]!)
                        ),
                        // Etiquetas de salud
                        ...recipe.healthLabels.take(3).map((health) => 
                          _buildTag(health, Colors.blue[100]!, Colors.blue[800]!)
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Tipo de cocina y tipo de plato
                  if (recipe.cuisineType.isNotEmpty || recipe.dishType.isNotEmpty)
                    Row(
                      children: [
                        if (recipe.cuisineType.isNotEmpty) ...[
                          Icon(Icons.public, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            recipe.cuisineType.first,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                        if (recipe.cuisineType.isNotEmpty && recipe.dishType.isNotEmpty)
                          const Text(' • '),
                        if (recipe.dishType.isNotEmpty) ...[
                          Icon(Icons.restaurant_menu, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            recipe.dishType.first,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.replaceAll('-', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
