import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;

/// Widget universal para mostrar imágenes guardadas localmente
/// Usa diferentes estrategias según la plataforma
class LocalImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LocalImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LocalImageWidget> createState() => _LocalImageWidgetState();
}

class _LocalImageWidgetState extends State<LocalImageWidget> {
  Widget? _imageWidget;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(LocalImageWidget oldWidget) {
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
      Widget imageWidget;
      
      // Si es un archivo del dispositivo (path local)
      if (widget.imageUrl.startsWith('/data/') || widget.imageUrl.startsWith('/storage/')) {
        if (kIsWeb) {
          // En web, los paths locales no funcionan, usar placeholder
          imageWidget = _buildErrorWidget();
        } else {
          // En móvil, usar Image.file para archivos locales
          imageWidget = Image.file(
            File(widget.imageUrl),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          );
        }
      } 
      // Si es una URL de Firebase Storage
      else if (widget.imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        imageWidget = Image.network(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
      // Si es una URL de localhost (solo en web)
      else if (widget.imageUrl.contains('localhost') && kIsWeb) {
        imageWidget = Image.network(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
      // Para cualquier otra URL
      else if (widget.imageUrl.startsWith('http')) {
        imageWidget = Image.network(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
      // Si no es ninguna de las anteriores, mostrar error
      else {
        imageWidget = _buildErrorWidget();
      }

      setState(() {
        _imageWidget = imageWidget;
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

/// Widget simplificado para casos comunes
class RecipeImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const RecipeImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LocalImageWidget(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, color: Colors.grey[600], size: 40),
              SizedBox(height: 8),
              Text(
                'Imagen de receta\nno disponible',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
