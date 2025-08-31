// Servicio universal de imágenes - Firebase Storage para todas las plataformas
import 'package:flutter/foundation.dart' show kIsWeb;

class DynamicImageService {
  static String get currentBaseUrl {
    // Ahora Firebase Storage es la base principal para todas las plataformas
    return 'https://firebasestorage.googleapis.com';
  }
  
  static Future<String> convertImageUrl(String imageUrl) async {
    // Si es una URL de Firebase Storage, usarla directamente (prioridad máxima)
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      return imageUrl;
    }
    
    // Si es una URL externa válida (Unsplash, etc.), usarla directamente
    if (imageUrl.startsWith('https://') && !imageUrl.contains('localhost')) {
      return imageUrl;
    }
    
    // Filtrar URLs de blob que no deben procesarse
    if (imageUrl.startsWith('blob:')) {
      print('⚠️ URL de blob detectada, usando placeholder');
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
    
    // Si es un archivo local del dispositivo (path completo)
    if (imageUrl.startsWith('/data/') || imageUrl.startsWith('/storage/')) {
      return imageUrl; // Mantener path local para que Image.file() lo maneje
    }
    
    // Si es una URL de localhost (versiones antiguas guardadas), convertir a placeholder
    if (imageUrl.contains('localhost')) {
      print('⚠️ URL localhost detectada, usando placeholder (Firebase Storage es la nueva ubicación)');
      return 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500';
    }
    
    // Si es solo un nombre de archivo, es probablemente de Firebase
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('/') && !imageUrl.startsWith('blob:')) {
      // En este caso, asumir que viene de Firebase Storage
      return imageUrl; // Dejar que Firebase Storage URL se resuelva
    }
    
    return imageUrl;
  }
  
  static bool isLocalImageUrl(String imageUrl) {
    // URLs de Firebase Storage no son "locales" en el sentido del servidor web
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      return false;
    }
    
    // URLs externas no son locales
    if (imageUrl.startsWith('https://') && !imageUrl.contains('localhost')) {
      return false;
    }
    
    // No procesar URLs de blob como locales
    if (imageUrl.startsWith('blob:')) {
      return false;
    }
    
    // Archivos del dispositivo SÍ son locales
    if (imageUrl.startsWith('/data/') || imageUrl.startsWith('/storage/')) {
      return true;
    }
    
    return imageUrl.contains('/uploads/recipes/') || 
           imageUrl.contains('localhost:') || 
           (!imageUrl.startsWith('http') && imageUrl.contains('_recipe_image.jpg'));
  }
  
  static Future<String> getRelativeImageUrl(String fileName) async {
    if (kIsWeb) {
      return 'http://localhost:10000/uploads/recipes/$fileName';
    } else {
      // En móvil, esto debería venir de Firebase Storage
      return fileName; // Dejar que Firebase maneje la URL completa
    }
  }
  
  static String getCurrentPort() {
    return kIsWeb ? '10000' : '0';
  }
  
  static String getStaticServerPort() {
    return '10000';
  }
  
  static String extractFileName(String imageUrl) {
    if (imageUrl.contains('/uploads/recipes/')) {
      return imageUrl.split('/uploads/recipes/').last;
    }
    if (imageUrl.contains('/')) {
      return imageUrl.split('/').last;
    }
    return imageUrl;
  }
}
