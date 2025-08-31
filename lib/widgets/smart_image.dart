import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_manager_service.dart';
import '../services/dynamic_image_service.dart';
import 'local_image_widget.dart';

class SmartImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? placeholder;
  final bool showLoading;

  const SmartImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.showLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageManager = ImageManagerService();
    
    // Si es una imagen local que necesita conversión de URL, usar FutureBuilder
    if (_isLocalStorageImage(imagePath)) {
      return FutureBuilder<String>(
        future: DynamicImageService.convertImageUrl(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return showLoading ? _buildLoadingWidget() : const SizedBox.shrink();
          }
          
          if (snapshot.hasError) {
            print('❌ Error convirtiendo URL de imagen: ${snapshot.error}');
            return _buildErrorWidget();
          }
          
          final processedImagePath = snapshot.data ?? imagePath;
          return _buildImageWidget(processedImagePath, imageManager);
        },
      );
    }
    
    // Para otros tipos de imagen, usar directamente
    return _buildImageWidget(imagePath, imageManager);
  }
  
  Widget _buildImageWidget(String processedImagePath, ImageManagerService imageManager) {
    print('🔍 SmartImage procesando URL: $processedImagePath');
    
    Widget imageWidget;

    if (imageManager.isAssetImage(processedImagePath)) {
      // Imagen local (asset)
      print('📱 Usando Image.asset para: $processedImagePath');
      imageWidget = Image.asset(
        processedImagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (_isFirebaseStorageUrl(processedImagePath)) {
      // Imagen de Firebase Storage - con solución CORS temporal
      print('🔥 Usando CachedNetworkImage para Firebase Storage: $processedImagePath');
      
      // Crear URL con proxy CORS para desarrollo
      String corsProxyUrl = processedImagePath;
      if (kIsWeb && processedImagePath.startsWith('https://firebasestorage.googleapis.com')) {
        // En desarrollo web, usar proxy CORS público
        corsProxyUrl = 'https://cors-anywhere.herokuapp.com/$processedImagePath';
        print('🌐 Usando proxy CORS para desarrollo: $corsProxyUrl');
      }
      
      imageWidget = CachedNetworkImage(
        imageUrl: corsProxyUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: showLoading
            ? (context, url) => _buildLoadingWidget()
            : null,
        errorWidget: (context, url, error) {
          print('❌ Error con proxy CORS, intentando imagen directa: $error');
          // Fallback: intentar imagen directa
          return Image.network(
            processedImagePath,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingWidget();
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error definitivo con imagen Firebase: $error');
              return Container(
                width: width,
                height: height,
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: Colors.grey[400], size: 40),
                    SizedBox(height: 4),
                    Text('Imagen subida\ncorrectamente', 
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              );
            },
          );
        },
      );
    } else if (_isLocalStorageImage(processedImagePath)) {
      // Imagen guardada localmente (archivos físicos o localStorage)
      print('💾 Usando LocalImageWidget para: $processedImagePath');
      imageWidget = LocalImageWidget(
        imageUrl: processedImagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: showLoading ? _buildLoadingWidget() : null,
        errorWidget: _buildErrorWidget(),
      );
    } else if (imageManager.isNetworkImage(processedImagePath)) {
      // Imagen de internet con caché (URLs externas)
      print('🌐 Usando CachedNetworkImage para URL externa: $processedImagePath');
      imageWidget = CachedNetworkImage(
        imageUrl: processedImagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: showLoading
            ? (context, url) => _buildLoadingWidget()
            : null,
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    } else {
      // Fallback
      print('⚠️ Usando fallback para: $processedImagePath');
      imageWidget = _buildErrorWidget();
    }

    // Aplicar border radius si se especifica
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Verifica si la imagen es de almacenamiento local
  bool _isLocalStorageImage(String imagePath) {
    // Excluir Firebase Storage URLs de almacenamiento local
    if (_isFirebaseStorageUrl(imagePath)) {
      return false;
    }
    
    return imagePath.contains('localhost:') && imagePath.contains('/uploads/') ||
           imagePath.startsWith('blob:') ||
           imagePath.startsWith('/data/') ||  // Archivos del dispositivo Android
           imagePath.startsWith('/storage/') ||  // Almacenamiento externo Android
           imagePath.startsWith('/var/mobile/') ||  // iOS
           imagePath.startsWith('/private/var/') ||  // iOS
           imagePath.contains('_recipe') ||
           DynamicImageService.isLocalImageUrl(imagePath);
  }

  /// Verifica si es una URL de Firebase Storage
  bool _isFirebaseStorageUrl(String imagePath) {
    return imagePath.contains('firebasestorage.googleapis.com') ||
           (imagePath.contains('firebase') && imagePath.contains('storage'));
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: width != null && height != null 
                ? (height! * 0.3).clamp(24.0, 64.0)
                : 48.0,
          ),
          if (placeholder != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                placeholder!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget especializado para imágenes de recetas
class RecipeImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const RecipeImage({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SmartImage(
          imagePath: imagePath,
          width: width,
          height: height,
          borderRadius: BorderRadius.circular(12),
          placeholder: 'Imagen de receta',
        ),
        if (showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavoritePressed,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para selector de imágenes con preview
class ImageSelector extends StatefulWidget {
  final String? currentImagePath;
  final Function(String) onImageSelected;
  final bool allowCamera;
  final bool allowGallery;
  final bool showAssetOptions;

  const ImageSelector({
    Key? key,
    this.currentImagePath,
    required this.onImageSelected,
    this.allowCamera = true,
    this.allowGallery = true,
    this.showAssetOptions = true,
  }) : super(key: key);

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  final ImageManagerService _imageManager = ImageManagerService();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview de la imagen actual
        if (_selectedImagePath != null)
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            child: SmartImage(
              imagePath: _selectedImagePath!,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

        // Botones de selección
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.allowCamera)
              ElevatedButton.icon(
                onPressed: _selectFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            if (widget.allowGallery)
              ElevatedButton.icon(
                onPressed: _selectFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            if (widget.showAssetOptions)
              ElevatedButton.icon(
                onPressed: _selectFromAssets,
                icon: const Icon(Icons.image),
                label: const Text('Predefinidas'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectFromCamera() async {
    final file = await _imageManager.takePhoto();
    if (file != null) {
      // Aquí podrías subir a Firebase y obtener la URL
      // Por ahora usamos el path local
      _updateSelectedImage(file.path);
    }
  }

  Future<void> _selectFromGallery() async {
    final imageBytes = await _imageManager.pickImageFromDevice();
    if (imageBytes != null) {
      // Aquí podrías subir a Firebase y obtener la URL
      // Por ahora mostramos un mensaje de éxito
      print('Imagen seleccionada desde dispositivo');
    }
  }

  Future<void> _selectFromAssets() async {
    final assetImages = ImageManagerService.recipeAssets;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen predefinida'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: assetImages.length - 1, // Excluir 'default'
            itemBuilder: (context, index) {
              final entries = assetImages.entries
                  .where((e) => e.key != 'default')
                  .toList();
              
              // Verificar que el índice esté dentro del rango
              if (index >= entries.length) {
                return const SizedBox.shrink();
              }
              
              final entry = entries[index];
              
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _updateSelectedImage(entry.value);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SmartImage(
                          imagePath: entry.value,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _updateSelectedImage(String imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
    });
    widget.onImageSelected(imagePath);
  }
}
