import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

/// Widget personalizado para mostrar imágenes guardadas localmente en WEB
/// Maneja tanto URLs de servidor como imágenes del localStorage
class LocalImageWidgetWeb extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalImageWidgetWeb({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LocalImageWidgetWeb> createState() => _LocalImageWidgetWebState();
}

class _LocalImageWidgetWebState extends State<LocalImageWidgetWeb> {
  Widget? _imageWidget;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(LocalImageWidgetWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Primer intento: cargar desde URL directa
      if (await _canLoadDirectly(widget.imageUrl)) {
        setState(() {
          _imageWidget = Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
          _isLoading = false;
        });
        return;
      }

      // Segundo intento: buscar en localStorage
      final localImage = await _loadFromLocalStorage();
      if (localImage != null) {
        setState(() {
          _imageWidget = localImage;
          _isLoading = false;
        });
        return;
      }

      // Si llegamos aquí, no se pudo cargar la imagen
      setState(() {
        _hasError = true;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error cargando imagen: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<bool> _canLoadDirectly(String url) async {
    try {
      // Para URLs blob: o data:, intentar cargar directamente
      if (url.startsWith('blob:') || url.startsWith('data:')) {
        return true;
      }

      // Para URLs http/https, verificar disponibilidad
      if (url.startsWith('http')) {
        final img = html.ImageElement();
        img.src = url;
        
        await img.onLoad.first.timeout(Duration(seconds: 3));
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Widget?> _loadFromLocalStorage() async {
    try {
      final fileName = _extractFileName(widget.imageUrl);
      if (fileName == null) return null;

      // Buscar en diferentes formatos de localStorage
      final storageKeys = [
        'server_img_$fileName',
        'backup_img_$fileName',
        'file_$fileName',
        'image_$fileName',
      ];

      for (final key in storageKeys) {
        final base64Data = html.window.localStorage[key];
        if (base64Data != null) {
          try {
            final bytes = base64Decode(base64Data);
            
            return Image.memory(
              bytes,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
            );
          } catch (e) {
            print('⚠️ Error decodificando imagen de localStorage: $e');
            continue;
          }
        }
      }

      // Buscar URLs alternativas
      final urlKeys = [
        'server_url_$fileName',
        'backup_url_$fileName',
        'url_$fileName',
      ];

      for (final key in urlKeys) {
        final storedUrl = html.window.localStorage[key];
        if (storedUrl != null && await _canLoadDirectly(storedUrl)) {
          return Image.network(
            storedUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
        }
      }

      return null;
    } catch (e) {
      print('❌ Error cargando desde localStorage: $e');
      return null;
    }
  }

  String? _extractFileName(String url) {
    try {
      if (url.contains('/')) {
        return url.split('/').last;
      }
      return url;
    } catch (e) {
      return null;
    }
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                'Imagen no disponible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _imageWidget == null) {
      return _buildErrorWidget();
    }

    return _imageWidget!;
  }
}
