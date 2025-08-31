import 'dart:typed_data';
import 'dart:html' as html;

class LocalImageService {
  /// Guarda una imagen localmente en el navegador y retorna la URL local
  static Future<String> saveImageLocally(Uint8List imageBytes, String fileName) async {
    try {
      print('💾 Guardando imagen localmente: $fileName');
      
      // Generar nombre único
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String extension = _getFileExtension(fileName);
      String uniqueFileName = '${timestamp}_recipe_image$extension';
      
      // Crear blob de la imagen
      final blob = html.Blob([imageBytes]);
      final url = html.Url.createObjectUrl(blob);
      
      print('📁 Imagen preparada como: $uniqueFileName');
      print('✅ URL blob generada: $url');
      
      // Guardar referencia en localStorage para persistencia
      _saveImageReference(uniqueFileName, url);
      
      // Retornar URL que puede ser usada en la aplicación
      return url;
    } catch (e) {
      print('❌ Error al guardar imagen localmente: $e');
      rethrow;
    }
  }
  
  /// Guarda referencia de la imagen en localStorage
  static void _saveImageReference(String fileName, String blobUrl) {
    try {
      final storage = html.window.localStorage;
      storage['image_$fileName'] = blobUrl;
      print('💾 Referencia guardada en localStorage: $fileName');
    } catch (e) {
      print('⚠️ No se pudo guardar en localStorage: $e');
    }
  }
  
  /// Obtiene una imagen guardada desde localStorage
  static String? getImageFromStorage(String fileName) {
    try {
      final storage = html.window.localStorage;
      return storage['image_$fileName'];
    } catch (e) {
      print('⚠️ No se pudo obtener imagen de localStorage: $e');
      return null;
    }
  }
  
  /// Extrae la extensión del archivo
  static String _getFileExtension(String fileName) {
    if (fileName.contains('.') && fileName.lastIndexOf('.') > 0) {
      final dotIndex = fileName.lastIndexOf('.');
      if (dotIndex < fileName.length - 1) {
        return fileName.substring(dotIndex);
      }
    }
    return '.jpg'; // Extensión por defecto
  }
  
  /// Lista todas las imágenes guardadas
  static List<String> getAllSavedImages() {
    try {
      final storage = html.window.localStorage;
      List<String> images = [];
      
      for (String key in storage.keys) {
        if (key.startsWith('image_') && key.length > 6) {
          String fileName = key.substring(6); // Remover 'image_'
          images.add(fileName);
        }
      }
      
      return images;
    } catch (e) {
      print('⚠️ Error al listar imágenes: $e');
      return [];
    }
  }
  
  /// Limpia imágenes antiguas (opcional)
  static void cleanOldImages({int maxAgeHours = 24}) {
    try {
      final storage = html.window.localStorage;
      final now = DateTime.now().millisecondsSinceEpoch;
      List<String> toRemove = [];
      
      for (String key in storage.keys) {
        if (key.startsWith('image_') && key.length > 6) {
          String fileName = key.substring(6);
          // Extraer timestamp del nombre del archivo
          if (fileName.contains('_')) {
            List<String> parts = fileName.split('_');
            if (parts.isNotEmpty) {
              String timestampStr = parts[0];
              try {
                int timestamp = int.parse(timestampStr);
                int ageHours = (now - timestamp) ~/ (1000 * 60 * 60);
                
                if (ageHours > maxAgeHours) {
                  toRemove.add(key);
                }
              } catch (e) {
                // Si no se puede parsear el timestamp, ignorar
              }
            }
          }
        }
      }
      
      // Remover imágenes antiguas
      for (String key in toRemove) {
        storage.remove(key);
        print('🗑️ Imagen antigua removida: $key');
      }
      
      if (toRemove.isNotEmpty) {
        print('✅ Limpieza completada: ${toRemove.length} imágenes removidas');
      }
    } catch (e) {
      print('⚠️ Error en limpieza de imágenes: $e');
    }
  }
}
