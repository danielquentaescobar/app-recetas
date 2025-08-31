// Archivo de exportación condicional para servicios de archivos web
export 'local_file_service_web_mobile.dart' 
  if (dart.library.html) 'local_file_service_web.dart';
