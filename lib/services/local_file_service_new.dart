import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:convert';

/// Servicio simplificado para manejo de archivos físicos en el servidor
class LocalFileService {
  static const String uploadUrl = 'http://localhost:8081/upload-image';
  static const String baseUrl = 'http://localhost:6708/uploads/recipes/';
  static const int uploadServerPort = 8081;
  
  /// Guarda una imagen como archivo físico y retorna la URL
  static Future<String> saveImageToServer(Uint8List imageBytes, String fileName) async {
    try {
      print('Subiendo imagen al servidor: $fileName');
      
      // Crear FormData
      final formData = html.FormData();
      final blob = html.Blob([imageBytes]);
      
      // Agregar archivo al form
      formData.appendBlob('image', blob, fileName);
      
      // Crear request
      final request = html.HttpRequest();
      request.open('POST', uploadUrl);
      
      // Configurar headers para CORS
      request.setRequestHeader('Accept', 'application/json');
      
      // Enviar archivo
      request.send(formData);
      
      // Esperar respuesta
      await request.onLoadEnd.first;
      
      if (request.status == 200) {
        print('✅ Imagen subida exitosamente a servidor');
        
        // Construir URL directa del archivo
        final fileUrl = '$baseUrl$fileName';
        
        // Guardar en localStorage como backup
        _saveToLocalStorage(fileName, fileUrl, imageBytes);
        
        return fileUrl;
      } else {
        print('❌ Error del servidor: ${request.status} - ${request.statusText}');
        throw Exception('Error del servidor: ${request.status}');
      }
      
    } catch (e) {
      print('❌ Error subiendo imagen, usando método local: $e');
      return await _saveLocallyAsBackup(imageBytes, fileName);
    }
  }
  
  /// Método de respaldo: guardar localmente en localStorage
  static Future<String> _saveLocallyAsBackup(Uint8List imageBytes, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      
      // Crear blob URL
      final blob = html.Blob([imageBytes]);
      final blobUrl = html.Url.createObjectUrl(blob);
      
      // Guardar en localStorage
      final base64 = base64Encode(imageBytes);
      html.window.localStorage['backup_img_$uniqueFileName'] = base64;
      html.window.localStorage['backup_url_$uniqueFileName'] = blobUrl;
      
      print('💾 Imagen guardada localmente como respaldo: $uniqueFileName');
      
      return blobUrl;
    } catch (e) {
      print('❌ Error en método de respaldo: $e');
      
      // Última opción: imagen por defecto
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
  }
  
  /// Guardar referencia en localStorage
  static void _saveToLocalStorage(String fileName, String url, Uint8List imageBytes) {
    try {
      final base64 = base64Encode(imageBytes);
      html.window.localStorage['server_img_$fileName'] = base64;
      html.window.localStorage['server_url_$fileName'] = url;
      print('💾 Imagen guardada en localStorage: $fileName');
    } catch (e) {
      print('❌ Error guardando en localStorage: $e');
    }
  }
  
  /// Eliminar imagen del servidor
  static Future<bool> deleteImageFromServer(String imageUrl) async {
    try {
      if (!imageUrl.startsWith(baseUrl)) {
        return false; // No es una imagen de nuestro servidor
      }
      
      final filename = imageUrl.split('/').last;
      final deleteUrl = 'http://localhost:$uploadServerPort/delete-image';
      
      final request = html.HttpRequest();
      request.open('DELETE', deleteUrl);
      request.setRequestHeader('Content-Type', 'application/json');
      
      final data = json.encode({'filename': filename});
      
      request.send(data);
      await request.onLoadEnd.first;
      
      if (request.status == 200) {
        print('🗑️ Imagen eliminada exitosamente: $filename');
        _removeFromLocalStorage(filename);
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('❌ Error al eliminar imagen: $e');
      return false;
    }
  }
  
  /// Verificar si el servidor está disponible
  static Future<bool> isServerAvailable() async {
    try {
      final request = html.HttpRequest();
      request.open('GET', 'http://localhost:$uploadServerPort/health');
      request.timeout = 3000; // 3 segundos
      
      request.send();
      await request.onLoadEnd.first;
      
      return request.status == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtener todas las imágenes guardadas
  static Future<List<String>> getStoredImages() async {
    try {
      final listUrl = 'http://localhost:$uploadServerPort/list-images';
      final request = html.HttpRequest();
      
      request.open('GET', listUrl);
      await request.onLoadEnd.first;
      
      if (request.status == 200 && request.responseText != null) {
        final data = json.decode(request.responseText!);
        final List<String> images = [];
        
        for (String filename in data['images']) {
          images.add('$baseUrl$filename');
        }
        
        return images;
      }
      
    } catch (e) {
      print('❌ Error al obtener lista de imágenes: $e');
    }
    
    return [];
  }

  /// Obtener imagen del localStorage si existe
  static String? getImageFromStorage(String fileName) {
    try {
      // Buscar primero en imágenes del servidor
      final serverUrl = html.window.localStorage['server_url_$fileName'];
      if (serverUrl != null) {
        return serverUrl;
      }
      
      // Buscar en respaldos locales
      final backupUrl = html.window.localStorage['backup_url_$fileName'];
      if (backupUrl != null) {
        return backupUrl;
      }
      
      return null;
    } catch (e) {
      print('❌ Error obteniendo imagen del storage: $e');
      return null;
    }
  }
  
  /// Eliminar de localStorage
  static void _removeFromLocalStorage(String fileName) {
    try {
      html.window.localStorage.remove('server_img_$fileName');
      html.window.localStorage.remove('server_url_$fileName');
      html.window.localStorage.remove('backup_img_$fileName');
      html.window.localStorage.remove('backup_url_$fileName');
    } catch (e) {
      print('❌ Error eliminando de localStorage: $e');
    }
  }
  
  /// Listar todas las imágenes guardadas
  static List<Map<String, String>> getAllSavedImages() {
    final images = <Map<String, String>>[];
    
    try {
      final storage = html.window.localStorage;
      
      storage.forEach((key, value) {
        if (key.startsWith('server_url_') || key.startsWith('backup_url_')) {
          final fileName = key.replaceFirst(RegExp(r'^(server_url_|backup_url_)'), '');
          final type = key.startsWith('server_url_') ? 'servidor' : 'local';
          
          images.add({
            'fileName': fileName,
            'url': value,
            'type': type,
            'key': key,
          });
        }
      });
      
      print('📁 Encontradas ${images.length} imágenes guardadas');
    } catch (e) {
      print('❌ Error listando imágenes: $e');
    }
    
    return images;
  }
  
  /// Limpiar imágenes antiguas del localStorage
  static void cleanOldImages({int maxAgeHours = 24}) {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = maxAgeHours * 60 * 60 * 1000;
      final storage = html.window.localStorage;
      final keysToRemove = <String>[];
      
      storage.forEach((key, value) {
        if (key.startsWith('server_') || key.startsWith('backup_')) {
          // Extraer timestamp del nombre
          final parts = key.split('_');
          if (parts.length >= 3) {
            try {
              final timestamp = int.parse(parts[2]);
              if (now - timestamp > maxAge) {
                keysToRemove.add(key);
              }
            } catch (e) {
              // Si no se puede parsear, remover
              keysToRemove.add(key);
            }
          }
        }
      });
      
      for (final key in keysToRemove) {
        storage.remove(key);
      }
      
      print('🧹 Limpiadas ${keysToRemove.length} imágenes antiguas');
    } catch (e) {
      print('❌ Error limpiando imágenes: $e');
    }
  }
}
