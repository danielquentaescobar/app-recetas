// Stub para evitar errores de compilación en Android
// Este archivo se usa automáticamente cuando dart:html no está disponible

import 'dart:typed_data';

class LocalFileServiceWeb {
  static Future<String> saveImageToServer(Uint8List imageBytes, String fileName) async {
    throw UnsupportedError('Web service not supported on this platform');
  }
  
  static Future<bool> deleteImageFromServer(String imageUrl) async {
    throw UnsupportedError('Web service not supported on this platform');
  }
  
  static Future<bool> isServerAvailable() async {
    return false;
  }
  
  static Future<List<String>> getStoredImages() async {
    return [];
  }
  
  static void cleanOldImages({int maxAgeHours = 24}) {
    // No-op for non-web platforms
  }
}
