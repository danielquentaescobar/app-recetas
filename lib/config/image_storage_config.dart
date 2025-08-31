/// Configuración para el almacenamiento de imágenes
/// Sistema de archivos físicos en servidor
class ImageStorageConfig {
  /// Directorio base para archivos físicos
  static const String UPLOAD_DIR = 'web/uploads/recipes/';
  
  /// URL base para acceder a archivos físicos
  static const String BASE_URL = 'http://localhost:6708/uploads/recipes/';
  
  /// Endpoint del servidor de uploads
  static const String UPLOAD_SERVER_URL = 'http://localhost:8082/upload-image';
  
  /// Puerto del servidor de uploads
  static const int UPLOAD_SERVER_PORT = 8082;
  
  /// Puerto de la aplicación Flutter
  static const int FLUTTER_APP_PORT = 6708;
  
  /// Instrucciones de uso
  static String get instructions => '''
🔧 SISTEMA DE ARCHIVOS FÍSICOS

� CONFIGURACIÓN:
   📁 Directorio: $UPLOAD_DIR
   🌐 URLs: $BASE_URL
   🚀 Servidor uploads: $UPLOAD_SERVER_URL

🚀 PARA USAR:
1️⃣ Iniciar servidor: dart bin/upload_server.dart
2️⃣ Iniciar app: flutter run -d web-server --web-port $FLUTTER_APP_PORT
3️⃣ Usar aplicación en: http://localhost:$FLUTTER_APP_PORT
''';
}
