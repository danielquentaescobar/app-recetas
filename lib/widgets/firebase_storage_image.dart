import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Widget especializado para imágenes de Firebase Storage en web
/// Maneja problemas de CORS específicos de Firebase Storage
class FirebaseStorageImage extends StatefulWidget {
  final String firebaseUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FirebaseStorageImage({
    Key? key,
    required this.firebaseUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _proxiedUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!kIsWeb) {
      // En móvil no hay problemas de CORS
      setState(() {
        _proxiedUrl = widget.firebaseUrl;
        _isLoading = false;
      });
      return;
    }

    try {
      // En web, intentar cargar la imagen directamente primero
      final img = html.ImageElement();
      img.crossOrigin = 'anonymous';
      
      await img.onLoad.first.timeout(Duration(seconds: 10));
      img.src = widget.firebaseUrl;
      
      setState(() {
        _proxiedUrl = widget.firebaseUrl;
        _isLoading = false;
      });
      
    } catch (e) {
      print('❌ Error cargando imagen Firebase en web: $e');
      
      // Intentar con un proxy CORS público
      final corsProxy = 'https://cors-anywhere.herokuapp.com/${widget.firebaseUrl}';
      
      try {
        final img = html.ImageElement();
        await img.onLoad.first.timeout(Duration(seconds: 10));
        img.src = corsProxy;
        
        setState(() {
          _proxiedUrl = corsProxy;
          _isLoading = false;
        });
        
      } catch (proxyError) {
        print('❌ Error con proxy CORS: $proxyError');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 8),
              Text('Cargando imagen...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (_hasError || _proxiedUrl == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
            SizedBox(height: 8),
            Text('Error CORS', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text('Imagen no disponible en web', 
                 style: TextStyle(fontSize: 8, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Image.network(
      _proxiedUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(height: 4),
              Text('Error de red', style: TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ),
        );
      },
    );
  }
}
