import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

/// Servidor dinámico para uploads de imágenes
void main(List<String> args) async {
  final uploadDir = 'web/uploads/recipes/';
  
  // Crear directorio si no existe
  final directory = Directory(uploadDir);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
    print('📁 Directorio creado: $uploadDir');
  }
  
  // Determinar puerto para el servidor de imágenes
  int serverPort = 8085; // Puerto por defecto
  
  // Si se pasa un puerto como argumento, usarlo
  if (args.isNotEmpty) {
    try {
      serverPort = int.parse(args[0]);
    } catch (e) {
      print('⚠️ Puerto inválido: ${args[0]}, usando puerto por defecto: $serverPort');
    }
  } else {
    // Intentar detectar si hay un proceso de Flutter corriendo
    try {
      final processResult = await Process.run('netstat', ['-an']);
      final output = processResult.stdout.toString();
      
      // Buscar puertos en uso por Flutter (normalmente 2147, 3000, etc.)
      final flutterPorts = <int>[];
      final portPattern = RegExp(r':(\d{4,5})\s');
      final matches = portPattern.allMatches(output);
      
      for (final match in matches) {
        final port = int.tryParse(match.group(1)!);
        if (port != null && port > 2000 && port < 10000) {
          flutterPorts.add(port);
        }
      }
      
      if (flutterPorts.isNotEmpty) {
        // Usar el primer puerto libre después del puerto de Flutter más alto
        final maxFlutterPort = flutterPorts.reduce((a, b) => a > b ? a : b);
        serverPort = maxFlutterPort + 1;
        
        // Verificar que el puerto esté disponible
        while (await _isPortInUse(serverPort)) {
          serverPort++;
        }
        
        print('🔍 Detectado Flutter en puertos: ${flutterPorts.join(', ')}');
        print('🎯 Usando puerto libre: $serverPort');
      }
    } catch (e) {
      print('⚠️ No se pudo detectar puerto de Flutter: $e');
    }
  }
  
  // Verificar disponibilidad del puerto final
  if (await _isPortInUse(serverPort)) {
    print('❌ Puerto $serverPort está en uso, buscando alternativo...');
    while (await _isPortInUse(serverPort)) {
      serverPort++;
    }
    print('✅ Usando puerto alternativo: $serverPort');
  }
  
  // Guardar información del puerto para que la app pueda leerla
  final portFile = File('web/server_port.txt');
  await portFile.writeAsString(serverPort.toString());
  print('💾 Puerto guardado en: ${portFile.path}');
  
  // Iniciar servidor
  final server = await HttpServer.bind('localhost', serverPort);
  print('🚀 Servidor de uploads iniciado en http://localhost:$serverPort');
  print('📁 Directorio de uploads: $uploadDir');
  print('🔗 URL de salud: http://localhost:$serverPort/health');
  
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
    
    try {
      if (request.uri.path == '/health') {
        // Endpoint de salud
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(json.encode({
            'status': 'OK',
            'port': serverPort,
            'timestamp': DateTime.now().toIso8601String(),
            'uploadDir': uploadDir,
          }));
        await request.response.close();
        
      } else if (request.uri.path == '/upload-image' && request.method == 'POST') {
        // Upload de imagen
        await _handleImageUpload(request, uploadDir, serverPort);
        
      } else if (request.uri.path.startsWith('/uploads/')) {
        // Servir archivos estáticos
        await _serveStaticFile(request, uploadDir);
        
      } else {
        // 404
        request.response
          ..statusCode = 404
          ..write('Not Found');
        await request.response.close();
      }
    } catch (e, stackTrace) {
      print('❌ Error procesando request: $e');
      print('📍 Stack trace: $stackTrace');
      
      request.response
        ..statusCode = 500
        ..write('Internal Server Error');
      await request.response.close();
    }
  });
  
  print('✅ Servidor listo para recibir requests');
  print('💡 Presiona Ctrl+C para detener el servidor');
}

/// Verifica si un puerto está en uso
Future<bool> _isPortInUse(int port) async {
  try {
    final socket = await ServerSocket.bind('localhost', port);
    await socket.close();
    return false;
  } catch (e) {
    return true;
  }
}

/// Maneja la subida de imágenes
Future<void> _handleImageUpload(HttpRequest request, String uploadDir, int serverPort) async {
  try {
    print('📤 Procesando upload de imagen...');
    
    // Leer todos los bytes del request
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
    }
    
    print('📊 Bytes recibidos: ${bytes.length}');
    
    if (bytes.isEmpty) {
      throw Exception('No se recibieron datos');
    }
    
    // Convertir a string para procesar multipart
    final requestString = String.fromCharCodes(bytes);
    final lines = requestString.split('\r\n');
    
    // Encontrar el boundary
    String? boundary;
    for (final line in lines) {
      if (line.startsWith('------WebKitFormBoundary')) {
        boundary = line;
        break;
      }
    }
    
    if (boundary == null) {
      throw Exception('No se encontró el boundary del formulario');
    }
    
    print('🔍 Boundary encontrado: $boundary');
    
    // Buscar el inicio y fin del archivo
    final boundaryBytes = boundary.codeUnits;
    final data = Uint8List.fromList(bytes);
    
    int fileStart = -1;
    int fileEnd = -1;
    
    // Buscar el inicio de los datos del archivo (después de Content-Type)
    for (int i = 0; i < data.length - 20; i++) {
      // Buscar doble CRLF que indica fin de headers
      if (data[i] == 13 && data[i + 1] == 10 && 
          data[i + 2] == 13 && data[i + 3] == 10) {
        fileStart = i + 4;
        break;
      }
    }
    
    if (fileStart == -1) {
      throw Exception('No se encontró el inicio de los datos del archivo');
    }
    
    // Buscar el boundary final
    for (int i = fileStart; i < data.length - boundaryBytes.length; i++) {
      bool matches = true;
      for (int j = 0; j < boundaryBytes.length; j++) {
        if (data[i + j] != boundaryBytes[j]) {
          matches = false;
          break;
        }
      }
      if (matches) {
        // Retroceder para quitar el CRLF antes del boundary
        fileEnd = i - 2;
        break;
      }
    }
    
    if (fileEnd == -1) {
      fileEnd = data.length;
    }
    
    // Extraer los datos del archivo
    final imageBytes = data.sublist(fileStart, fileEnd);
    
    print('📏 Datos extraídos: ${imageBytes.length} bytes');
    
    if (imageBytes.length < 100) {
      throw Exception('Datos de imagen inválidos (muy pequeños)');
    }
    
    // Verificar que sea un archivo JPEG válido
    if (imageBytes[0] != 0xFF || imageBytes[1] != 0xD8) {
      throw Exception('El archivo no es un JPEG válido');
    }
    
    // Generar nombre único para la imagen
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_recipe_image.jpg';
    
    // Guardar archivo
    final file = File('$uploadDir$uniqueFileName');
    await file.writeAsBytes(imageBytes);
    
    print('💾 Imagen guardada: ${file.path}');
    print('📏 Tamaño: ${imageBytes.length} bytes');
    
    // Respuesta exitosa
    final imageUrl = 'http://localhost:$serverPort/uploads/recipes/$uniqueFileName';
    
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(json.encode({
        'success': true,
        'url': imageUrl,
        'fileName': uniqueFileName,
        'size': imageBytes.length,
        'timestamp': timestamp,
      }));
    await request.response.close();
    
    print('✅ Upload completado exitosamente');
    print('🔗 URL: $imageUrl');
    
  } catch (e, stackTrace) {
    print('❌ Error en upload: $e');
    print('📍 Stack trace: $stackTrace');
    
    request.response
      ..statusCode = 500
      ..headers.contentType = ContentType.json
      ..write(json.encode({
        'success': false,
        'error': e.toString(),
      }));
    await request.response.close();
  }
}

/// Sirve archivos estáticos
Future<void> _serveStaticFile(HttpRequest request, String uploadDir) async {
  try {
    final fullPath = request.uri.path;
    
    // Filtrar URLs de blob que no deben llegar aquí
    if (fullPath.contains('blob:')) {
      print('⚠️ URL de blob recibida incorrectamente: $fullPath');
      request.response
        ..statusCode = 400
        ..write('Bad Request: Blob URLs not supported');
      await request.response.close();
      return;
    }
    
    final filePath = fullPath.replaceFirst('/uploads/recipes/', '');
    
    // Validar que el nombre del archivo sea válido
    if (filePath.isEmpty || filePath.contains('..') || filePath.contains('/') || filePath.contains('\\')) {
      print('⚠️ Nombre de archivo inválido: $filePath');
      request.response
        ..statusCode = 400
        ..write('Bad Request: Invalid file name');
      await request.response.close();
      return;
    }
    
    final file = File('$uploadDir$filePath');
    
    print('📂 Buscando archivo: ${file.path}');
    
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      
      // Determinar content type
      String contentType = 'application/octet-stream';
      if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (filePath.endsWith('.png')) {
        contentType = 'image/png';
      } else if (filePath.endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (filePath.endsWith('.webp')) {
        contentType = 'image/webp';
      }
      
      print('✅ Archivo encontrado: ${file.path} (${bytes.length} bytes)');
      
      request.response
        ..statusCode = 200
        ..headers.set('Content-Type', contentType)
        ..headers.set('Content-Length', bytes.length.toString())
        ..headers.set('Cache-Control', 'public, max-age=31536000') // Cache por 1 año
        ..add(bytes);
      await request.response.close();
      
      print('✅ Archivo servido: ${bytes.length} bytes');
    } else {
      print('❌ Archivo no encontrado: ${file.path}');
      print('🖼️ Sirviendo imagen placeholder para: $filePath');
      
      final placeholderUrl = 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=500&h=300&fit=crop&auto=format';
      
      try {
        final client = HttpClient();
        final uri = Uri.parse(placeholderUrl);
        final imgRequest = await client.getUrl(uri);
        final imgResponse = await imgRequest.close();
        
        if (imgResponse.statusCode == 200) {
          final bytes = await imgResponse.fold<List<int>>([], (a, b) => a..addAll(b));
          request.response
            ..statusCode = 200
            ..headers.set('Content-Type', 'image/jpeg')
            ..headers.set('Content-Length', bytes.length.toString())
            ..headers.set('Cache-Control', 'public, max-age=3600')
            ..add(bytes);
          await request.response.close();
          print('✅ Placeholder servido directamente');
        } else {
          request.response
            ..statusCode = 404
            ..write('No se pudo obtener el placeholder');
          await request.response.close();
          print('❌ Error al obtener el placeholder');
        }
        client.close();
      } catch (e) {
        print('❌ Error interno al servir placeholder: $e');
        request.response
          ..statusCode = 500
          ..write('Error interno al servir placeholder');
        await request.response.close();
      }
    }
  } catch (e) {
    print('❌ Error sirviendo archivo: $e');
    request.response
      ..statusCode = 500
      ..write('Error serving file');
    await request.response.close();
  }
}
