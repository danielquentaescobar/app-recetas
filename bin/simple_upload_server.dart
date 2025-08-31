import 'dart:io';
import 'dart:convert';

/// Servidor simple para uploads de imágenes
void main() async {
  final uploadDir = 'web/uploads/recipes/';
  
  // Crear directorio si no existe
  final directory = Directory(uploadDir);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
    print('📁 Directorio creado: $uploadDir');
  }
  
  // Iniciar servidor
  final server = await HttpServer.bind('localhost', 8085);
  print('🚀 Servidor de uploads iniciado en http://localhost:8085');
  print('📁 Directorio de uploads: $uploadDir');
  
  server.listen((HttpRequest request) async {
    // CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    
    print('📨 ${request.method} ${request.uri.path}');
    
    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }
    
    if (request.method == 'GET' && request.uri.path == '/health') {
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({
        'status': 'ok',
        'message': 'Servidor funcionando',
        'uploadDir': uploadDir,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      await request.response.close();
      print('✅ Health check OK');
      return;
    }
    
    if (request.method == 'GET' && request.uri.path.startsWith('/uploads/recipes/')) {
      // Servir archivos de imágenes existentes
      try {
        final fileName = request.uri.path.replaceFirst('/uploads/recipes/', '');
        final filePath = '$uploadDir$fileName';
        final file = File(filePath);
        
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          
          // Determinar content type
          String contentType = 'image/jpeg';
          if (fileName.toLowerCase().endsWith('.png')) {
            contentType = 'image/png';
          } else if (fileName.toLowerCase().endsWith('.gif')) {
            contentType = 'image/gif';
          } else if (fileName.toLowerCase().endsWith('.webp')) {
            contentType = 'image/webp';
          }
          
          request.response.statusCode = 200;
          request.response.headers.contentType = ContentType.parse(contentType);
          request.response.add(bytes);
          await request.response.close();
          
          print('📸 Imagen servida: $fileName');
          return;
        } else {
          request.response.statusCode = 404;
          request.response.write('Imagen no encontrada');
          await request.response.close();
          print('❌ Imagen no encontrada: $fileName');
          return;
        }
      } catch (e) {
        print('❌ Error sirviendo imagen: $e');
        request.response.statusCode = 500;
        request.response.write('Error interno');
        await request.response.close();
        return;
      }
    }
    
    if (request.method == 'POST' && request.uri.path == '/upload-image') {
      try {
        // Leer todos los bytes
        final List<int> bytes = [];
        await for (final data in request) {
          bytes.addAll(data);
        }
        
        if (bytes.isEmpty) {
          request.response.statusCode = 400;
          request.response.write(json.encode({'error': 'No hay datos'}));
          await request.response.close();
          return;
        }
        
        // Generar nombre único
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${timestamp}_recipe_image.jpg';
        final filePath = '$uploadDir$fileName';
        
        // Guardar archivo
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        final url = 'http://localhost:8085/uploads/recipes/$fileName';
        
        print('✅ Imagen guardada: $fileName (${bytes.length} bytes)');
        
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(json.encode({
          'success': true,
          'fileName': fileName,
          'url': url,
          'size': bytes.length,
        }));
        await request.response.close();
        
      } catch (e) {
        print('❌ Error en upload: $e');
        request.response.statusCode = 500;
        request.response.write(json.encode({'error': 'Error: $e'}));
        await request.response.close();
      }
      return;
    }
    
    // 404 para otras rutas
    request.response.statusCode = 404;
    request.response.write('Not Found');
    await request.response.close();
  });
  
  print('⏰ Servidor listo. Presiona Ctrl+C para detener...');
}
