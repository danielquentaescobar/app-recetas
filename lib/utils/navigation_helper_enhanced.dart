import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget para navegación inteligente entre pantallas
class NavigationHelper {
  /// Navegar a la pantalla principal
  static void goToHome(BuildContext context) {
    context.go('/home');
  }

  /// Navegar a búsqueda
  static void goToSearch(BuildContext context) {
    context.go('/search');
  }

  /// Navegar a favoritos
  static void goToFavorites(BuildContext context) {
    context.go('/favorites');
  }

  /// Navegar a perfil
  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }

  /// Navegar a agregar receta
  static void goToAddRecipe(BuildContext context) {
    context.go('/add-recipe');
  }

  /// Navegar a detalles de receta
  static void goToRecipeDetail(BuildContext context, String recipeId) {
    context.go('/recipe/$recipeId');
  }

  /// Navegar a editar receta
  static void goToEditRecipe(BuildContext context, String recipeId) {
    context.go('/edit-recipe/$recipeId');
  }

  /// Navegar hacia atrás de forma inteligente
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Si no hay páginas en el stack, ir al home
      context.go('/home');
    }
  }

  /// Obtener el índice de la navegación inferior basado en la ruta actual
  static int getCurrentNavIndex(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    
    if (currentPath.startsWith('/home')) return 0;
    if (currentPath.startsWith('/search')) return 1;
    if (currentPath.startsWith('/favorites')) return 2;
    if (currentPath.startsWith('/profile')) return 3;
    
    return 0; // Por defecto home
  }

  /// Navegar usando el índice de la navegación inferior
  static void navigateByIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        goToHome(context);
        break;
      case 1:
        goToSearch(context);
        break;
      case 2:
        goToFavorites(context);
        break;
      case 3:
        goToProfile(context);
        break;
    }
  }

  /// Mostrar diálogo de confirmación para salir de la app
  static Future<bool> showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de la aplicación'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Verificar si se puede navegar hacia atrás
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  /// Navegar y limpiar el stack de navegación
  static void goAndClearStack(BuildContext context, String route) {
    context.go(route);
  }

  /// Push una nueva ruta manteniendo el stack
  static void pushRoute(BuildContext context, String route) {
    context.push(route);
  }

  /// Navegar con reemplazo de la ruta actual
  static void replaceRoute(BuildContext context, String route) {
    context.pushReplacement(route);
  }
}

/// Widget de AppBar personalizado con navegación
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => NavigationHelper.goBack(context),
            )
          : null,
      actions: actions,
      elevation: 2,
      shadowColor: Colors.black26,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Widget para botón de navegación inteligente
class SmartBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const SmartBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: color,
        size: size,
      ),
      onPressed: onPressed ?? () => NavigationHelper.goBack(context),
    );
  }
}

/// Widget para el drawer de navegación lateral
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Recetas Latinas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              NavigationHelper.goToHome(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Buscar Recetas'),
            onTap: () {
              Navigator.pop(context);
              NavigationHelper.goToSearch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Mis Favoritos'),
            onTap: () {
              Navigator.pop(context);
              NavigationHelper.goToFavorites(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('Crear Receta'),
            onTap: () {
              Navigator.pop(context);
              NavigationHelper.goToAddRecipe(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              NavigationHelper.goToProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implementar pantalla de configuración
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración - Próximamente'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Recetas Latinas',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.restaurant_menu,
        size: 64,
        color: Colors.orange,
      ),
      children: [
        const Text(
          'Una aplicación para descubrir y compartir las mejores recetas de Latinoamérica.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Desarrollado con Flutter y Firebase.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
