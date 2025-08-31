import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Importar directamente - solo funcionará cuando sea posible
import 'local_file_service_web.dart';
import 'local_file_service_mobile.dart';

/// Servicio universal para manejo de archivos que funciona en web y móvil
class LocalFileService {
  /// Guarda una imagen y retorna la URL
  /// Funciona tanto en web como en dispositivos móviles
  static Future<String> saveImageToServer(Uint8List imageBytes, String fileName) async {
    if (kIsWeb) {
      return LocalFileServiceWeb.saveImageToServer(imageBytes, fileName);
    } else {
      return LocalFileServiceMobile.saveImageToServer(imageBytes, fileName);
    }
  }
  
  /// Eliminar imagen
  static Future<bool> deleteImageFromServer(String imageUrl) async {
    if (kIsWeb) {
      return LocalFileServiceWeb.deleteImageFromServer(imageUrl);
    } else {
      return LocalFileServiceMobile.deleteImageFromServer(imageUrl);
    }
  }
  
  /// Verificar si el servidor está disponible
  static Future<bool> isServerAvailable() async {
    if (kIsWeb) {
      return LocalFileServiceWeb.isServerAvailable();
    } else {
      return LocalFileServiceMobile.isServerAvailable();
    }
  }
  
  /// Obtener imágenes almacenadas
  static Future<List<String>> getStoredImages() async {
    if (kIsWeb) {
      return LocalFileServiceWeb.getStoredImages();
    } else {
      return LocalFileServiceMobile.getStoredImages();
    }
  }
  
  /// Limpiar imágenes antiguas
  static void cleanOldImages({int maxAgeHours = 24}) {
    if (kIsWeb) {
      LocalFileServiceWeb.cleanOldImages(maxAgeHours: maxAgeHours);
    } else {
      LocalFileServiceMobile.cleanOldImages(maxAgeHours: maxAgeHours);
    }
  }
}
