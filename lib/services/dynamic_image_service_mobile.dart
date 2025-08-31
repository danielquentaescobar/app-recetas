// Versión para móvil del servicio de imágenes dinámicas
class DynamicImageService {
  static String get currentBaseUrl {
    return 'http://localhost:10000';
  }
  
  static Future<String?> _getImageServerPort() async {
    // Para Android, siempre usar el servidor interno en puerto 10000
    return '10000';
  }
  
  static Future<String> convertImageUrl(String imageUrl) async {
    // En móvil, si es una URL de Firebase/externa, usarla directamente
    if (imageUrl.startsWith('http') && !imageUrl.contains('localhost')) {
      return imageUrl;
    }
    
    // Para imágenes locales, usar el servidor en puerto 10000
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('/')) {
      return 'http://localhost:10000/uploads/recipes/$imageUrl';
    }
    
    return imageUrl;
  }
  
  static bool isLocalImageUrl(String imageUrl) {
    return imageUrl.contains('/uploads/recipes/') || 
           (!imageUrl.startsWith('http') && imageUrl.contains('_recipe_image.jpg'));
  }
  
  static Future<String> getRelativeImageUrl(String fileName) async {
    return 'http://localhost:10000/uploads/recipes/$fileName';
  }
  
  static String getCurrentPort() {
    return '10000';
  }
  
  static String getStaticServerPort() {
    return '10000';
  }
  
  static String extractFileName(String imageUrl) {
    if (imageUrl.contains('/uploads/recipes/')) {
      return imageUrl.split('/uploads/recipes/').last;
    }
    return imageUrl;
  }
}
