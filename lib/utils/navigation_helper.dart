import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utilidad para manejo inteligente de navegación hacia atrás
class NavigationHelper {
  /// Navega hacia atrás de manera inteligente
  /// Si puede hacer pop, lo hace. Si no, va a la ruta de fallback
  static void goBack(BuildContext context, {String fallbackRoute = '/home'}) {
    try {
      final router = GoRouter.of(context);
      
      // Verificar si podemos hacer pop de forma segura
      if (router.canPop()) {
        router.pop();
      } else {
        // Si no hay nada que hacer pop, ir a la ruta de fallback
        // Verificar que no estemos ya en la ruta de fallback
        final currentPath = GoRouterState.of(context).uri.path;
        if (currentPath != fallbackRoute) {
          router.go(fallbackRoute);
        }
      }
    } catch (e) {
      // Si hay cualquier error, ir directamente a home
      print('Error en navegación: $e');
      try {
        GoRouter.of(context).go('/home');
      } catch (e2) {
        print('Error crítico en navegación: $e2');
      }
    }
  }

  /// Navega hacia atrás con confirmación si hay cambios sin guardar
  static Future<bool> goBackWithConfirmation(
    BuildContext context, {
    required bool hasUnsavedChanges,
    String title = 'Descartar cambios',
    String message = '¿Estás seguro de que quieres salir? Los cambios no guardados se perderán.',
    String fallbackRoute = '/home',
  }) async {
    if (!hasUnsavedChanges) {
      goBack(context, fallbackRoute: fallbackRoute);
      return true;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.closeDialog(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => NavigationHelper.closeDialog(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      goBack(context, fallbackRoute: fallbackRoute);
      return true;
    }

    return false;
  }

  /// Verifica si se puede navegar hacia atrás
  static bool canGoBack(BuildContext context) {
    try {
      return GoRouter.of(context).canPop();
    } catch (e) {
      print('Error verificando canPop: $e');
      return false;
    }
  }

  /// Cierra un diálogo de forma segura
  static void closeDialog(BuildContext context, [dynamic result]) {
    try {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        router.pop(result);
      }
    } catch (e) {
      print('Error cerrando diálogo: $e');
    }
  }

  /// Navega a una ruta específica, reemplazando la actual
  static void navigateAndReplace(BuildContext context, String route) {
    try {
      GoRouter.of(context).go(route);
    } catch (e) {
      print('Error en navigateAndReplace: $e');
    }
  }

  /// Navega a una ruta específica, agregándola al stack
  static void navigateAndPush(BuildContext context, String route) {
    try {
      GoRouter.of(context).push(route);
    } catch (e) {
      print('Error en navigateAndPush: $e');
    }
  }
}

/// Widget de botón de atrás personalizado
class SmartBackButton extends StatelessWidget {
  final String fallbackRoute;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final String? tooltip;

  const SmartBackButton({
    super.key,
    this.fallbackRoute = '/home',
    this.onPressed,
    this.icon = Icons.arrow_back,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip ?? 'Volver',
      onPressed: onPressed ?? () {
        NavigationHelper.goBack(context, fallbackRoute: fallbackRoute);
      },
    );
  }
}

/// Widget de botón de atrás estilizado para AppBars con fondo oscuro
class StyledBackButton extends StatelessWidget {
  final String fallbackRoute;
  final VoidCallback? onPressed;
  final bool hasUnsavedChanges;

  const StyledBackButton({
    super.key,
    this.fallbackRoute = '/home',
    this.onPressed,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      onPressed: onPressed ?? () {
        if (hasUnsavedChanges) {
          NavigationHelper.goBackWithConfirmation(
            context,
            hasUnsavedChanges: hasUnsavedChanges,
            fallbackRoute: fallbackRoute,
          );
        } else {
          NavigationHelper.goBack(context, fallbackRoute: fallbackRoute);
        }
      },
    );
  }
}

/// Widget de botón de cerrar (X) para formularios
class SmartCloseButton extends StatelessWidget {
  final String fallbackRoute;
  final VoidCallback? onPressed;
  final bool hasUnsavedChanges;

  const SmartCloseButton({
    super.key,
    this.fallbackRoute = '/home',
    this.onPressed,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: onPressed ?? () {
        if (hasUnsavedChanges) {
          NavigationHelper.goBackWithConfirmation(
            context,
            hasUnsavedChanges: hasUnsavedChanges,
            fallbackRoute: fallbackRoute,
          );
        } else {
          NavigationHelper.goBack(context, fallbackRoute: fallbackRoute);
        }
      },
    );
  }
}
