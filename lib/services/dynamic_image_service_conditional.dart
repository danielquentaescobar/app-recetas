// Archivo de exportación condicional para servicios de imágenes
export 'dynamic_image_service_mobile.dart' 
  if (dart.library.html) 'dynamic_image_service.dart';
