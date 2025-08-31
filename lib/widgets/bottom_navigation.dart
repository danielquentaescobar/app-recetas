import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_dialog.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) async {
            // Si se proporciona un onTap personalizado, usarlo
            if (onTap != null) {
              onTap!(index);
              return;
            }

            // Lógica por defecto de navegación
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/search');
                break;
              case 2:
                context.go('/mealdb');
                break;
              case 3:
                // Verificar autenticación para favoritos
                if (authProvider.userModel != null) {
                  context.go('/favorites');
                } else {
                  await AuthDialog.showLoginRequiredDialog(context, 'ver tus recetas favoritas');
                }
                break;
              case 4:
                // Verificar autenticación para perfil
                if (authProvider.userModel != null) {
                  context.go('/profile');
                } else {
                  await AuthDialog.showLoginRequiredDialog(context, 'acceder a tu perfil');
                }
                break;
            }
          },
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: AppStrings.search,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public),
              label: 'TheMealDB',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: AppStrings.favorites,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppStrings.profile,
            ),
          ],
        );
      },
    );
  }
}
