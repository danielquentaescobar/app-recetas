// Versión stub para móvil del servicio de archivos locales web
import 'dart:typed_data';

class LocalFileServiceWeb {
  static String get uploadUrl {
    return 'http://localhost:10000/upload-image';
  }

  static Future<String?> uploadImageToServer(Uint8List imageBytes, String recipeId) async {
    // En móvil, no se usa el servicio web de archivos
    // Las imágenes se manejan a través de Firebase Storage
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
}
