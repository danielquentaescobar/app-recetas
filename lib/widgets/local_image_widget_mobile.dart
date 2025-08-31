import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Widget personalizado para mostrar imágenes guardadas localmente en MÓVIL
/// Maneja tanto URLs de servidor como imágenes del almacenamiento local
class LocalImageWidgetMobile extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalImageWidgetMobile({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LocalImageWidgetMobile> createState() => _LocalImageWidgetMobileState();
}

class _LocalImageWidgetMobileState extends State<LocalImageWidgetMobile> {
  Widget? _imageWidget;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(LocalImageWidgetMobile oldWidget) {
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
      // Primer intento: cargar desde archivo local
      final localImage = await _loadFromLocalFile();
      if (localImage != null) {
        setState(() {
          _imageWidget = localImage;
          _isLoading = false;
        });
        return;
      }

      // Segundo intento: cargar desde URL de red
      if (widget.imageUrl.startsWith('http')) {
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

  Future<Widget?> _loadFromLocalFile() async {
    try {
      final fileName = _extractFileName(widget.imageUrl);
      if (fileName == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final recipesDir = Directory('${directory.path}/recipes');

      if (!await recipesDir.exists()) {
        return null;
      }

      // Buscar el archivo en el directorio local
      final file = File('${recipesDir.path}/$fileName');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }

      return null;
    } catch (e) {
      print('❌ Error cargando archivo local: $e');
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
