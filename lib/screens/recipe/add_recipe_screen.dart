import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/recipe_model.dart';
import '../../utils/auth_dialog.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _regionController = TextEditingController();
  
  String _selectedCategory = 'Plato Principal';
  String _selectedDifficulty = 'Fácil';
  final List<String> _categories = [
    'Plato Principal',
    'Entrada',
    'Postre',
    'Bebida',
    'Ensalada',
    'Sopa',
    'Snack',
    'Desayuno',
    'Almuerzo',
    'Cena'
  ];
  
  final List<String> _difficulties = [
    'Fácil',
    'Medio',
    'Difícil'
  ];
  
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose();
    _preparationTimeController.dispose();
    _servingsController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Obtener bytes de la imagen para previsualización en web
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    if (authProvider.userModel == null) {
      if (mounted) {
        AuthDialog.showLoginRequiredDialog(context, 'agregar recetas');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear objeto Recipe
      final recipe = Recipe(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredientsController.text
            .split('\n')
            .where((ingredient) => ingredient.trim().isNotEmpty)
            .map((ingredient) => ingredient.trim())
            .toList(),
        instructions: _instructionsController.text
            .split('\n')
            .where((instruction) => instruction.trim().isNotEmpty)
            .map((instruction) => instruction.trim())
            .toList(),
        preparationTime: int.tryParse(_preparationTimeController.text) ?? 15,
        cookingTime: int.tryParse(_cookingTimeController.text) ?? 30,
        servings: int.tryParse(_servingsController.text) ?? 4,
        difficulty: _selectedDifficulty,
        region: _regionController.text.trim().isEmpty ? 'Latinoamérica' : _regionController.text.trim(),
        categories: [_selectedCategory],
        authorId: authProvider.userModel!.id,
        authorName: authProvider.userModel!.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        rating: 0.0,
        reviewsCount: 0,
        imageUrl: '', // Se asignará después de subir la imagen
      );

      // Si hay imagen, subirla primero
      String imageUrl = '';
      if (_selectedImage != null && _imageBytes != null) {
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_recipe_image.jpg';
          imageUrl = await recipeProvider.uploadImageFromBytes(
            _imageBytes!,
            'recipes',
            fileName,
          );
          // Actualizar la receta con la URL de la imagen
          final updatedRecipe = recipe.copyWith(imageUrl: imageUrl);
          
          // Crear receta con imagen
          final success = await recipeProvider.createRecipe(updatedRecipe);
          
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Receta agregada exitosamente!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al agregar la receta'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          print('Error al subir imagen: $e');
          // Crear receta sin imagen como fallback
          final success = await recipeProvider.createRecipe(recipe);
          
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Receta agregada exitosamente! (sin imagen)'),
                backgroundColor: Colors.orange,
              ),
            );
            context.go('/home');
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al agregar la receta'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Crear receta sin imagen
        final success = await recipeProvider.createRecipe(recipe);

        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Receta agregada exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar la receta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar receta: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Verificar autenticación
        if (authProvider.userModel == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Agregar Receta'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Comparte tus recetas!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Inicia sesión para agregar tus propias recetas y compartirlas con la comunidad.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Iniciar Sesión'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/register'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Registrarse'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Volver al inicio'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Usuario autenticado - mostrar formulario completo
        return Scaffold(
          appBar: AppBar(
            title: const Text('Agregar Receta'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _selectedImage != null && _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Agregar foto de la receta',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la receta *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es obligatorio';
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
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
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
                    value: _selectedCategory,
                  ),
                  const SizedBox(height: 16),

                  // Tiempo de preparación
                  TextFormField(
                    controller: _preparationTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de preparación (minutos) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El tiempo de preparación es obligatorio';
                      }
                      final time = int.tryParse(value);
                      if (time == null || time <= 0) {
                        return 'Ingrese un tiempo válido en minutos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tiempo de cocción
                  TextFormField(
                    controller: _cookingTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de cocción (minutos) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El tiempo de cocción es obligatorio';
                      }
                      final time = int.tryParse(value);
                      if (time == null || time <= 0) {
                        return 'Ingrese un tiempo válido en minutos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Porciones
                  TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Número de porciones *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El número de porciones es obligatorio';
                      }
                      final servings = int.tryParse(value);
                      if (servings == null || servings <= 0) {
                        return 'Ingrese un número válido de porciones';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Región
                  TextFormField(
                    controller: _regionController,
                    decoration: const InputDecoration(
                      labelText: 'Región (ej: México, Colombia, Argentina)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Opcional - por defecto será Latinoamérica',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dificultad
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Dificultad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bar_chart),
                    ),
                    items: _difficulties.map((difficulty) {
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
                    value: _selectedDifficulty,
                  ),
                  const SizedBox(height: 16),

                  // Ingredientes
                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredientes (uno por línea) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                      hintText: 'Ejemplo:\n2 tazas de harina\n1 huevo\n1 taza de leche',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Los ingredientes son obligatorios';
                      }
                      final ingredients = value.split('\n')
                          .where((ingredient) => ingredient.trim().isNotEmpty)
                          .toList();
                      if (ingredients.length < 2) {
                        return 'Debe incluir al menos 2 ingredientes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Instrucciones
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones (una por línea) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                      hintText: 'Ejemplo:\nMezclar los ingredientes secos\nAgregar los líquidos\nCocinar por 30 minutos',
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las instrucciones son obligatorias';
                      }
                      final instructions = value.split('\n')
                          .where((instruction) => instruction.trim().isNotEmpty)
                          .toList();
                      if (instructions.length < 3) {
                        return 'Debe incluir al menos 3 pasos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitRecipe,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Guardando...' : 'Guardar Receta'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
