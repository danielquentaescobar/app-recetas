import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthDialog {
  /// Muestra un diálogo pidiendo al usuario que inicie sesión
  static Future<bool> showLoginRequiredDialog(BuildContext context, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.login, color: Colors.blue),
              SizedBox(width: 8),
              Text('Iniciar Sesión Requerido'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para $action necesitas tener una cuenta.'),
              const SizedBox(height: 16),
              const Text(
                '¿Qué quieres hacer?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                context.go('/register');
              },
              child: const Text('Registrarse'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                context.go('/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// Verifica si el usuario está autenticado, si no muestra el diálogo
  static Future<bool> requireAuth(BuildContext context, String action) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      return true;
    }
    
    return await showLoginRequiredDialog(context, action);
  }

  /// Redirección rápida a login para navegación
  static void redirectToLogin(BuildContext context, String action) async {
    await showLoginRequiredDialog(context, action);
  }

  /// Muestra un snackbar informativo cuando se requiere autenticación
  static void showAuthRequiredSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Para $action necesitas iniciar sesión'),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Iniciar Sesión',
          textColor: Colors.yellow,
          onPressed: () {
            context.push('/login');
          },
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  /// Widget que requiere autenticación para mostrar su contenido
  static Widget requireAuthWidget({
    required BuildContext context,
    required Widget child,
    required Widget fallback,
    required String action,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        }
        
        return GestureDetector(
          onTap: () => showLoginRequiredDialog(context, action),
          child: fallback,
        );
      },
    );
  }

  /// Botón que requiere autenticación
  static Widget authRequiredButton({
    required BuildContext context,
    required String action,
    required VoidCallback onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ElevatedButton(
          style: style,
          onPressed: authProvider.isAuthenticated
              ? onPressed
              : () => showLoginRequiredDialog(context, action),
          child: child,
        );
      },
    );
  }

  /// FloatingActionButton que requiere autenticación
  static Widget authRequiredFAB({
    required BuildContext context,
    required String action,
    required VoidCallback onPressed,
    required Widget child,
    String? tooltip,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return FloatingActionButton(
          tooltip: tooltip,
          onPressed: authProvider.isAuthenticated
              ? onPressed
              : () => showLoginRequiredDialog(context, action),
          child: child,
        );
      },
    );
  }

  /// IconButton que requiere autenticación
  static Widget authRequiredIconButton({
    required BuildContext context,
    required String action,
    required VoidCallback onPressed,
    required Icon icon,
    String? tooltip,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return IconButton(
          tooltip: tooltip,
          onPressed: authProvider.isAuthenticated
              ? onPressed
              : () => showLoginRequiredDialog(context, action),
          icon: icon,
        );
      },
    );
  }
}
