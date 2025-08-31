import 'package:intl/intl.dart';

class AppHelpers {
  // Formatear tiempo
  static String formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  // Formatear fecha
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formatear fecha y hora
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Formatear fecha relativa (hace X tiempo)
  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  // Validar email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validar contraseña
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    if (text.length == 1) return text.toUpperCase();
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalizar cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Obtener iniciales del nombre
  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    
    List<String> words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    
    if (words.isEmpty) return '?';
    
    if (words.length == 1) {
      return words[0].isNotEmpty && words[0].length > 0 ? words[0].substring(0, 1).toUpperCase() : '?';
    } else {
      String first = words[0].isNotEmpty && words[0].length > 0 ? words[0].substring(0, 1) : '';
      String second = words.length > 1 && words[1].isNotEmpty && words[1].length > 0 ? words[1].substring(0, 1) : '';
      String result = '${first}${second}'.toUpperCase();
      return result.isNotEmpty ? result : '?';
    }
  }

  // Formatear rating con estrellas
  static String formatRating(double rating) {
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  // Obtener color por dificultad
  static String getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return '#4CAF50'; // Verde
      case 'intermedio':
      case 'medium':
        return '#FF9800'; // Naranja
      case 'difícil':
      case 'hard':
        return '#F44336'; // Rojo
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Limpiar texto HTML (para descripciones de Spoonacular)
  static String stripHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Truncar texto
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Convertir lista a string separado por comas
  static String listToString(List<String> list) {
    return list.join(', ');
  }

  // Convertir string separado por comas a lista
  static List<String> stringToList(String text) {
    if (text.trim().isEmpty) return [];
    return text.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }

  // Generar ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Formatear número de porciones
  static String formatServings(int servings) {
    return '$servings porcion${servings > 1 ? 'es' : ''}';
  }

  // Validar tamaño de archivo
  static bool isValidFileSize(int fileSize, int maxSize) {
    return fileSize <= maxSize;
  }

  // Obtener extensión de archivo
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Validar tipo de archivo de imagen
  static bool isValidImageType(String fileName) {
    const allowedTypes = ['jpg', 'jpeg', 'png', 'gif'];
    String extension = getFileExtension(fileName);
    return allowedTypes.contains(extension);
  }

  // Convertir tiempo a minutos
  static int convertToMinutes(int hours, int minutes) {
    return (hours * 60) + minutes;
  }

  // Convertir minutos a horas y minutos
  static Map<String, int> convertFromMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return {'hours': hours, 'minutes': minutes};
  }

  // Mostrar mensaje de éxito o error
  static String getSuccessMessage(String action) {
    switch (action) {
      case 'create':
        return 'Receta creada exitosamente';
      case 'update':
        return 'Receta actualizada exitosamente';
      case 'delete':
        return 'Receta eliminada exitosamente';
      case 'review':
        return 'Reseña agregada exitosamente';
      case 'login':
        return 'Sesión iniciada exitosamente';
      case 'signup':
        return 'Cuenta creada exitosamente';
      case 'logout':
        return 'Sesión cerrada exitosamente';
      default:
        return 'Operación completada exitosamente';
    }
  }

  // Validar si el texto contiene solo letras y espacios
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$').hasMatch(name);
  }

  // Limpiar espacios en blanco extra
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Validar URL
  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/.+\..+').hasMatch(url);
  }

  // Parsear líneas de texto (para ingredientes e instrucciones)
  static List<String> parseLines(String text) {
    if (text.trim().isEmpty) return [];
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // Parsear tags separados por comas
  static List<String> parseTags(String text) {
    if (text.trim().isEmpty) return [];
    return text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  // Obtener mensaje de error
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return 'Ha ocurrido un error inesperado';
    }
  }
}
