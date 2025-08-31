import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firestore_service.dart';

class ImageManagerService {
  final ImagePicker _picker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();

  // Rutas de assets locales para recetas
  static const Map<String, String> recipeAssets = {
    'empanadas': 'assets/images/recipes/empanadas.jpg',
    'tacos': 'assets/images/recipes/tacos.jpg',
    'ceviche': 'assets/images/recipes/ceviche.jpg',
    'arepas': 'assets/images/recipes/arepas.jpg',
    'tamales': 'assets/images/recipes/tamales.jpg',
    'paella': 'assets/images/recipes/paella.jpg',
    'guacamole': 'assets/images/recipes/guacamole.jpg',
    'chimichurri': 'assets/images/recipes/chimichurri.jpg',
    'tres_leches': 'assets/images/recipes/tres_leches.jpg',
    'flan': 'assets/images/recipes/flan.jpg',
    'default': 'assets/images/placeholders/recipe-placeholder.jpg',
  };

  // URLs de respaldo (Unsplash)
  static const Map<String, String> fallbackUrls = {
    'empanadas': 'https://images.unsplash.com/photo-1624300629298-e9de39c13be5?w=500',
    'tacos': 'https://images.unsplash.com/photo-1601312540537-3f9765b2e0a2?w=500',
    'ceviche': 'https://images.unsplash.com/photo-1626200419199-391ae4be7a41?w=500',
    'arepas': 'https://images.unsplash.com/photo-1583935436376-2a7a5b2e9c6c?w=500',
    'tamales': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
    'paella': 'https://images.unsplash.com/photo-1624300629298-e9de39c13be5?w=500',
    'guacamole': 'https://images.unsplash.com/photo-1601312540537-3f9765b2e0a2?w=500',
    'chimichurri': 'https://images.unsplash.com/photo-1626200419199-391ae4be7a41?w=500',
    'tres_leches': 'https://images.unsplash.com/photo-1583935436376-2a7a5b2e9c6c?w=500',
    'flan': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
    'default': 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500',
  };

  /// Obtener imagen para una receta por nombre
  String getRecipeImage(String recipeName, {bool useAssets = false}) {
    String key = _normalizeRecipeName(recipeName);
    
    // Usar URLs de Unsplash por defecto para evitar errores 404
    return fallbackUrls[key] ?? fallbackUrls['default']!;
  }

  /// Obtener imagen aleatoria para recetas
  String getRandomRecipeImage({bool useAssets = false}) {
    // Usar URLs de Unsplash por defecto
    final keys = fallbackUrls.keys.toList();
    keys.remove('default');
    
    if (keys.isEmpty) return fallbackUrls['default']!;
    
    final randomKey = keys[DateTime.now().millisecondsSinceEpoch % keys.length];
    return fallbackUrls[randomKey]!;
  }

  /// Seleccionar imagen desde el dispositivo (Web compatible)
  Future<Uint8List?> pickImageFromDevice() async {
    try {
      if (kIsWeb) {
        // En web usamos file_picker para mejor compatibilidad
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
          withData: true, // Importante para web
        );
        
        if (result != null && result.files.single.bytes != null) {
          return result.files.single.bytes!;
        }
      } else {
        // En móvil usamos image_picker
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          return await image.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      print('Error al seleccionar imagen del dispositivo: $e');
      return null;
    }
  }

  /// Tomar foto con la cámara
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && !kIsWeb) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  /// Subir imagen a Firebase Storage
  Future<String?> uploadToFirebase(File imageFile, String userId, String recipeId) async {
    try {
      if (kIsWeb) {
        print('Subida de archivos no soportada en web');
        return null;
      }

      String path = 'recipes/$userId/$recipeId';
      String downloadUrl = await _firestoreService.uploadImage(imageFile, path);
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen a Firebase: $e');
      return null;
    }
  }

  /// Mostrar selector de fuente de imagen
  Future<dynamic> showImageSourceSelector(BuildContext context) async {
    if (kIsWeb) {
      // En web solo dispositivo
      return await pickImageFromDevice();
    }

    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await takePhoto();
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar desde dispositivo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImageFromDevice();
                  Navigator.of(context).pop(file);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  /// Verificar si es una URL o asset local
  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('assets/');
  }

  /// Verificar si es una URL de internet
  bool isNetworkImage(String imagePath) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://');
  }

  /// Normalizar nombre de receta para búsqueda
  String _normalizeRecipeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_')
        .replaceAll('ñ', 'n')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  /// Obtener lista de recetas con imágenes locales disponibles
  List<String> getAvailableRecipeNames() {
    return recipeAssets.keys.where((key) => key != 'default').toList();
  }

  /// Verificar si existe asset local para una receta
  bool hasLocalAsset(String recipeName) {
    String key = _normalizeRecipeName(recipeName);
    return recipeAssets.containsKey(key);
  }
}
