import 'dart:io';
import 'dart:convert';

/// Servidor simple para manejar uploads de imágenes
/// Este servidor se ejecuta en el puerto 8080 y maneja uploads de archivos
class ImageUploadServer {
  static HttpServer? _server;
  static final String uploadDir = 'web/uploads/recipes/';
  
  /// Inicia el servidor de uploads
  static Future<void> start() async {
    try {
      // Crear directorio si no existe
      final directory = Directory(uploadDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('📁 Directorio creado: $uploadDir');
      }
      
      // Iniciar servidor
      _server = await HttpServer.bind('localhost', 8083);
      print('Servidor de uploads iniciado en http://localhost:8083');
      
      // Configurar CORS
      _server!.listen((HttpRequest request) async {
        _setCorsHeaders(request.response);
        
        if (request.method == 'OPTIONS') {
          request.response.statusCode = 200;
          await request.response.close();
          return;
        }
        
        if (request.method == 'POST' && request.uri.path == '/upload-image') {
          await _handleImageUpload(request);
        } else if (request.method == 'GET' && request.uri.path == '/health') {
          await _handleHealthCheck(request);
        } else {
          request.response.statusCode = 404;
          request.response.write('Not Found');
          await request.response.close();
        }
      });
      
    } catch (e) {
      print('❌ Error iniciando servidor: $e');
    }
  }
  
  /// Configura headers CORS
  static void _setCorsHeaders(HttpResponse response) {
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  }
  
  /// Maneja el upload de imágenes
  static Future<void> _handleImageUpload(HttpRequest request) async {
    try {
      print('📤 Recibiendo upload de imagen...');
      
      // Leer el contenido completo
      final List<int> bytes = [];
      await for (final data in request) {
        bytes.addAll(data);
      }
      
      print('📊 Bytes recibidos: ${bytes.length}');
      
      if (bytes.isEmpty) {
        request.response.statusCode = 400;
        request.response.write(json.encode({'error': 'No se recibieron datos'}));
        await request.response.close();
        return;
      }
      
      // Generar nombre único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_recipe_image.jpg';
      final filePath = '$uploadDir$fileName';
      
      // Extraer solo los bytes de la imagen (simplificado)
      List<int> imageBytes = bytes;
      
      // Si es multipart, intentar extraer solo la imagen
      if (request.headers.contentType?.mimeType == 'multipart/form-data') {
        imageBytes = _extractImageFromMultipart(bytes);
      }
      
      // Guardar archivo
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      // Respuesta exitosa
      final responseData = {
        'success': true,
        'fileName': fileName,
        'url': 'http://localhost:6708/uploads/recipes/$fileName',
        'path': filePath,
        'size': imageBytes.length,
        'timestamp': timestamp,
      };
      
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode(responseData));
      await request.response.close();
      
      print('✅ Imagen guardada: $fileName (${imageBytes.length} bytes)');
      
    } catch (e) {
      print('❌ Error en upload: $e');
      request.response.statusCode = 500;
      request.response.write(json.encode({'error': 'Error interno del servidor: $e'}));
      await request.response.close();
    }
  }
  
  /// Extrae bytes de imagen de datos multipart (implementación simple)
  static List<int> _extractImageFromMultipart(List<int> bytes) {
    try {
      // Buscar el patrón que indica el inicio de datos binarios
      
      // Buscar inicio JPEG
      for (int i = 0; i < bytes.length - 1; i++) {
        if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
          return bytes.sublist(i);
        }
      }
      
      // Buscar inicio PNG
      for (int i = 0; i < bytes.length - 3; i++) {
        if (bytes[i] == 0x89 && bytes[i + 1] == 0x50 && 
            bytes[i + 2] == 0x4E && bytes[i + 3] == 0x47) {
          return bytes.sublist(i);
        }
      }
      
      // Si no encuentra headers de imagen, devolver todo
      return bytes;
    } catch (e) {
      print('⚠️ Error extrayendo imagen de multipart, usando datos completos: $e');
      return bytes;
    }
  }

  /// Maneja el endpoint de health check
  static Future<void> _handleHealthCheck(HttpRequest request) async {
    try {
      final responseData = {
        'status': 'ok',
        'message': 'Servidor de uploads funcionando',
        'timestamp': DateTime.now().toIso8601String(),
        'uploadDir': uploadDir,
      };
      
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode(responseData));
      await request.response.close();
      
    } catch (e) {
      print('Error en health check: $e');
      request.response.statusCode = 500;
      request.response.write(json.encode({'error': 'Error interno del servidor'}));
      await request.response.close();
    }
  }
  
  /// Detiene el servidor
  static Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('Servidor de uploads detenido');
    }
  }
}

/// Punto de entrada para ejecutar el servidor
void main() async {
  await ImageUploadServer.start();
  
  // Mantener el servidor corriendo
  print('Presiona Ctrl+C para detener el servidor...');
  
  // Manejar señales de terminación
  ProcessSignal.sigint.watch().listen((signal) async {
    print('\n🛑 Deteniendo servidor...');
    await ImageUploadServer.stop();
    exit(0);
  });
}
