import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/navigation_helper.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedRegion = AppConstants.latinAmericanRegions.first;
  String _selectedDifficulty = AppConstants.difficultyLevels.first;
  String _selectedCategory = AppConstants.recipeCategories.first;
  bool _isLoading = false;
  Recipe? _originalRecipe;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Verifica si hay cambios no guardados comparando con la receta original
  bool get _hasUnsavedChanges {
    if (_originalRecipe == null) return false;
    
    return _titleController.text != _originalRecipe!.title ||
           _descriptionController.text != _originalRecipe!.description ||
           _imageUrlController.text != _originalRecipe!.imageUrl ||
           _ingredientsController.text != _originalRecipe!.ingredients.join('\n') ||
           _instructionsController.text != _originalRecipe!.instructions.join('\n') ||
           _prepTimeController.text != _originalRecipe!.preparationTime.toString() ||
           _cookTimeController.text != _originalRecipe!.cookingTime.toString() ||
           _servingsController.text != _originalRecipe!.servings.toString() ||
           _tagsController.text != _originalRecipe!.tags.join(', ') ||
           _selectedRegion != _originalRecipe!.region ||
           _selectedDifficulty != _originalRecipe!.difficulty;
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final recipe = await recipeProvider.getRecipeById(widget.recipeId);
      
      if (recipe != null) {
        _originalRecipe = recipe;
        _populateForm(recipe);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receta no encontrada'),
              backgroundColor: Colors.red,
            ),
          );
          NavigationHelper.goBack(context, fallbackRoute: '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la receta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateForm(Recipe recipe) {
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description;
    _imageUrlController.text = recipe.imageUrl;
    _ingredientsController.text = recipe.ingredients.join('\n');
    _instructionsController.text = recipe.instructions.join('\n');
    _prepTimeController.text = recipe.prepTime.toString();
    _cookTimeController.text = recipe.cookTime.toString();
    _servingsController.text = recipe.servings.toString();
    _tagsController.text = recipe.tags.join(', ');
    
    setState(() {
      _selectedRegion = recipe.region;
      _selectedDifficulty = recipe.difficulty;
      _selectedCategory = recipe.category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await NavigationHelper.goBackWithConfirmation(
          context,
          hasUnsavedChanges: _hasUnsavedChanges,
          fallbackRoute: '/recipe/${widget.recipeId}',
        );
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receta'),
        elevation: 0,
        leading: SmartBackButton(
          fallbackRoute: '/recipe/${widget.recipeId}',
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateRecipe,
              child: const Text(
                AppStrings.save,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.title,
                        hintText: 'Ej: Empanadas Argentinas',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es requerido';
                        }
                        if (value.trim().length < 3) {
                          return 'El título debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.description,
                        hintText: 'Describe tu receta...',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es requerida';
                        }
                        if (value.trim().length < 10) {
                          return 'La descripción debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // URL de imagen
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen',
                        hintText: 'https://ejemplo.com/imagen.jpg',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !AppHelpers.isValidUrl(value)) {
                          return 'URL de imagen inválida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fila de dropdowns
                    Row(
                      children: [
                        // Región
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRegion,
                            decoration: const InputDecoration(
                              labelText: 'Región',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            items: AppConstants.latinAmericanRegions.map((region) {
                              return DropdownMenuItem(
                                value: region,
                                child: Text(region),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRegion = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dificultad
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Dificultad',
                              prefixIcon: Icon(Icons.signal_cellular_alt),
                            ),
                            items: AppConstants.difficultyLevels.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.recipeCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tiempos y porciones
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prepTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep. (min)',
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              final time = int.tryParse(value);
                              if (time == null || time <= 0) {
                                return 'Tiempo inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cookTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Cocción (min)',
                              prefixIcon: Icon(Icons.local_fire_department),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              final time = int.tryParse(value);
                              if (time == null || time <= 0) {
                                return 'Tiempo inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _servingsController,
                            decoration: const InputDecoration(
                              labelText: 'Porciones',
                              prefixIcon: Icon(Icons.people),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              final servings = int.tryParse(value);
                              if (servings == null || servings <= 0) {
                                return 'Porciones inválidas';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ingredientes
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.ingredients,
                        hintText: 'Un ingrediente por línea:\n- 2 tazas de harina\n- 1 huevo',
                        prefixIcon: Icon(Icons.list),
                      ),
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los ingredientes son requeridos';
                        }
                        final ingredients = AppHelpers.parseLines(value);
                        if (ingredients.isEmpty) {
                          return 'Debe tener al menos un ingrediente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Instrucciones
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.instructions,
                        hintText: 'Una instrucción por línea:\n1. Mezclar los ingredientes\n2. Hornear por 30 minutos',
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Las instrucciones son requeridas';
                        }
                        final instructions = AppHelpers.parseLines(value);
                        if (instructions.isEmpty) {
                          return 'Debe tener al menos una instrucción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Etiquetas (opcional)',
                        hintText: 'Separadas por comas: vegetariano, sin gluten, fácil',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de actualizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateRecipe,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Actualizar Receta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate() || _originalRecipe == null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar autenticado para editar recetas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que el usuario es el autor de la receta
    if (_originalRecipe!.authorId != authProvider.userModel!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes editar tus propias recetas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ingredients = AppHelpers.parseLines(_ingredientsController.text);
      final instructions = AppHelpers.parseLines(_instructionsController.text);
      final tags = AppHelpers.parseTags(_tagsController.text);

      final prepTime = int.parse(_prepTimeController.text);
      final cookTime = int.parse(_cookTimeController.text);
      final servings = int.parse(_servingsController.text);

      final updatedRecipe = _originalRecipe!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        region: _selectedRegion,
        difficulty: _selectedDifficulty,
        category: _selectedCategory,
        prepTime: prepTime,
        cookTime: cookTime,
        totalTime: prepTime + cookTime,
        servings: servings,
        ingredients: ingredients,
        instructions: instructions,
        tags: tags,
        updatedAt: DateTime.now(),
      );

      final success = await recipeProvider.updateRecipe(updatedRecipe);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppHelpers.getSuccessMessage('update')),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/recipe/${widget.recipeId}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la receta: ${AppHelpers.getErrorMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
