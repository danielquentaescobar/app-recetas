import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/theme_provider.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';
import 'smart_image.dart';
import 'modern_widgets.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool showAuthor;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.showAuthor = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ModernCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la receta con overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: RecipeImage(
                    imagePath: recipe.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              
              // Overlay con degradado
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Rating badge
              if (recipe.rating > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppTheme.primaryYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Dificultad badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(recipe.difficulty),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    recipe.difficulty.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              // Tiempo e información en la parte inferior
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Tiempo
                    _buildInfoChip(
                      icon: Icons.schedule_rounded,
                      text: AppHelpers.formatTime(recipe.totalTime),
                    ),
                    const SizedBox(width: 8),
                    
                    // Porciones
                    _buildInfoChip(
                      icon: Icons.people_rounded,
                      text: AppHelpers.formatServings(recipe.servings),
                    ),
                    
                    const Spacer(),
                    
                    // Likes
                    if (recipe.likedBy.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.favorite_rounded,
                        text: '${recipe.likedBy.length}',
                        color: AppTheme.primaryRed,
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Contenido de la tarjeta
          Padding(
            padding: EdgeInsets.all(
              AppTheme.getResponsivePadding(context, 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: AppTheme.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Descripción
                if (recipe.description.isNotEmpty)
                  Text(
                    AppHelpers.truncateText(recipe.description, 80),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: themeProvider.subtitleColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                
                // Región y autor
                Row(
                  children: [
                    // Región
                    if (recipe.region.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: themeProvider.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.region,
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    
                    if (recipe.region.isNotEmpty && showAuthor)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: themeProvider.subtitleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    
                    // Autor
                    if (showAuthor)
                      Expanded(
                        child: Text(
                          'Por ${recipe.authorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // Fecha
                    Text(
                      AppHelpers.formatRelativeDate(recipe.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: themeProvider.subtitleColor.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                
                // Reviews
                if (recipe.reviewsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_rounded,
                          size: 14,
                          color: themeProvider.subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.reviewsCount} reseña${recipe.reviewsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color ?? Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return AppTheme.primaryGreen;
      case 'intermedio':
      case 'medium':
        return AppTheme.primaryYellow;
      case 'difícil':
      case 'hard':
        return AppTheme.primaryRed;
      default:
        return AppTheme.primaryBlue;
    }
  }
}
