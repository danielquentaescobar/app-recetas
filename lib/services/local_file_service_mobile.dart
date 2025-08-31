import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dynamic_image_service.dart';

/// Servicio para manejo de archivos físicos en dispositivos móviles
/// En móvil, preferimos Firebase Storage sobre archivos locales
class LocalFileServiceMobile {
  static String get uploadUrl {
    final staticPort = DynamicImageService.getStaticServerPort();
    return 'http://10.0.2.2:$staticPort/upload-image'; // Para Android Emulator
  }
  
  static String get baseUrl {
    final staticPort = DynamicImageService.getStaticServerPort();
    return 'http://10.0.2.2:$staticPort/uploads/recipes/';
  }
  
  static int get uploadServerPort {
    return int.parse(DynamicImageService.getStaticServerPort());
  }
  
  /// Guarda una imagen como archivo físico temporal (Firebase Storage es preferido)
  static Future<String> saveImageToServer(Uint8List imageBytes, String fileName) async {
    try {
      print('📱 Guardando imagen temporal en móvil: $fileName');
      
      // Para móvil, guardar temporalmente y devolver path local
      // El servicio principal debería usar Firebase Storage
      return await _saveLocallyAsMobile(imageBytes, fileName);
      
    } catch (e) {
      print('❌ Error guardando imagen temporal en móvil: $e');
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
  }
  
  /// Guardar archivo localmente en el dispositivo móvil
  static Future<String> _saveLocallyAsMobile(Uint8List imageBytes, String fileName) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final recipesDir = Directory('${appDocDir.path}/recipes');
      
      if (!await recipesDir.exists()) {
        await recipesDir.create(recursive: true);
      }
      
      final file = File('${recipesDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      
      print('💾 Imagen guardada localmente en móvil: ${file.path}');
      return file.path;
      
    } catch (e) {
      print('❌ Error guardando localmente en móvil: $e');
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
  }
  
  /// Eliminar imagen del servidor
  static Future<bool> deleteImageFromServer(String imageUrl) async {
    try {
      if (!imageUrl.startsWith(baseUrl) && !imageUrl.startsWith('/data/')) {
        return false; // No es una imagen de nuestro servidor o local
      }
      
      if (imageUrl.startsWith('/data/')) {
        // Es archivo local, eliminar del dispositivo
        final file = File(imageUrl);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
        return false;
      }
      
      // Es archivo del servidor
      final fileName = imageUrl.split('/').last;
      final deleteUrl = 'http://10.0.2.2:$uploadServerPort/delete-image';
      
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'filename': fileName}),
      );
      
      if (response.statusCode == 200) {
        print('🗑️ Imagen eliminada exitosamente desde móvil: $fileName');
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('❌ Error al eliminar imagen desde móvil: $e');
      return false;
    }
  }
  
  /// Verificar si el servidor está disponible
  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:$uploadServerPort/health'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtener todas las imágenes almacenadas
  static Future<List<String>> getStoredImages() async {
    final images = <String>[];
    
    try {
      // Obtener imágenes locales
      final appDocDir = await getApplicationDocumentsDirectory();
      final recipesDir = Directory('${appDocDir.path}/recipes');
      
      if (await recipesDir.exists()) {
        final files = recipesDir.listSync()
            .where((item) => item is File && item.path.toLowerCase().endsWith('.jpg') || 
                           item.path.toLowerCase().endsWith('.png') ||
                           item.path.toLowerCase().endsWith('.jpeg'))
            .map((item) => item.path)
            .toList();
        
        images.addAll(files);
      }
      
      // Intentar obtener imágenes del servidor
      if (await isServerAvailable()) {
        try {
          final response = await http.get(
            Uri.parse('http://10.0.2.2:$uploadServerPort/list-images'),
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            for (String filename in data['images']) {
              images.add('$baseUrl$filename');
            }
          }
        } catch (e) {
          print('❌ Error obteniendo imágenes del servidor: $e');
        }
      }
      
    } catch (e) {
      print('❌ Error al obtener lista de imágenes móvil: $e');
    }
    
    return images;
  }
  
  /// Limpiar imágenes antiguas del dispositivo móvil
  static void cleanOldImages({int maxAgeHours = 24}) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final recipesDir = Directory('${appDocDir.path}/recipes');
      
      if (!await recipesDir.exists()) return;
      
      final now = DateTime.now();
      final maxAge = Duration(hours: maxAgeHours);
      int removedCount = 0;
      
      final files = recipesDir.listSync();
      for (final item in files) {
        if (item is File) {
          final fileStat = await item.stat();
          if (now.difference(fileStat.modified) > maxAge) {
            await item.delete();
            removedCount++;
          }
        }
      }
      
      print('🧹 Limpiadas $removedCount imágenes antiguas del móvil');
    } catch (e) {
      print('❌ Error limpiando imágenes del móvil: $e');
    }
  }
}
