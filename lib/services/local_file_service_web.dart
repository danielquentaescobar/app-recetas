// Versión simplificada para compatibilidad móvil
import 'dart:typed_data';

/// Servicio para manejo de archivos físicos en el servidor (Simplificado)
class LocalFileServiceWeb {
  static String get uploadUrl {
    return 'http://localhost:10000/upload-image';
  }

  static Future<String?> uploadImageToServer(Uint8List imageBytes, String recipeId) async {
    // En móvil, las imágenes se manejan a través de Firebase Storage
    // Esta función no se usa en la versión móvil
    return null;
  }

  static Future<String?> uploadDeviceImage(Uint8List imageBytes, String filename) async {
    // En móvil, no se usa el servicio web de archivos
    return null;
  }

  static Future<Map<String, String>?> uploadImageBytes(Uint8List imageBytes, String filename) async {
    // En móvil, no se usa el servicio web de archivos
    return null;
  }

  static Future<List<Map<String, dynamic>>> listUploadedImages() async {
    // En móvil, no se usa el servicio web de archivos
    return [];
  }

  static Future<bool> deleteImageFromServer(String filename) async {
    // En móvil, no se usa el servicio web de archivos
    return false;
  }

  // Funciones adicionales para compatibilidad con local_file_service.dart
  static Future<String> saveImageToServer(Uint8List imageBytes, String fileName) async {
    // En móvil, no se usa el servicio web de archivos
    // Retornar un nombre de archivo temporal
    return fileName;
  }

  static Future<bool> isServerAvailable() async {
    // En móvil, asumir que el servidor no está disponible
    return false;
  }

  static Future<List<String>> getStoredImages() async {
    // En móvil, no hay imágenes almacenadas localmente
    return [];
  }

  static void cleanOldImages({int maxAgeHours = 24}) {
    // En móvil, no hay limpieza de archivos locales
  }
}