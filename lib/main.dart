import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/edamam_provider.dart';
import 'providers/mealdb_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/recipe/recipe_detail_screen.dart';
import 'screens/recipe/add_recipe_screen.dart';
import 'screens/recipe/edit_recipe_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/edamam/edamam_search_screen.dart';
import 'screens/edamam/edamam_recipe_detail_screen.dart';
import 'screens/mealdb/mealdb_recipe_detail_screen.dart';
import 'screens/mealdb/mealdb_search_screen.dart';
import 'utils/constants.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mensaje de bienvenida
  debugPrint('🎉 Iniciando App Recetas Latinas...');
  debugPrint('📱 Para usar la app con datos de prueba, usa las siguientes credenciales:');
  debugPrint('   Email: test@example.com | Password: 123456');
  debugPrint('   Email: demo@recetas.com | Password: demo123');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('⚠️ Error al inicializar Firebase: $e');
    debugPrint('🧪 La aplicación funcionará en modo de prueba');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EdamamProvider()),
        ChangeNotifierProvider(create: (_) => MealDBProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        // No redirigir automáticamente - permitir acceso libre a todas las pantallas
        // La validación de autenticación se manejará en cada acción específica
        return null;
      },
      // Habilitar navegación con botón del navegador
      observers: [
        _NavigationObserver(),
      ],
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/mealdb',
          builder: (context, state) => const MealDBSearchScreen(),
        ),
        GoRoute(
          path: '/mealdb/recipe/:id',
          builder: (context, state) {
            final mealId = state.pathParameters['id']!;
            return MealDBRecipeDetailScreen(mealId: mealId);
          },
        ),
        GoRoute(
          path: '/edamam',
          builder: (context, state) => const EdamamSearchScreen(),
        ),
        GoRoute(
          path: '/edamam/recipe/:recipeUri',
          builder: (context, state) {
            final recipeUri = Uri.decodeComponent(state.pathParameters['recipeUri']!);
            return EdamamRecipeDetailScreen(recipeUri: recipeUri);
          },
        ),
        GoRoute(
          path: '/add-recipe',
          builder: (context, state) => const AddRecipeScreen(),
        ),
        GoRoute(
          path: '/recipe/:id',
          builder: (context, state) {
            final recipeId = state.pathParameters['id']!;
            return RecipeDetailScreen(recipeId: recipeId);
          },
        ),
        GoRoute(
          path: '/edit-recipe/:id',
          builder: (context, state) {
            final recipeId = state.pathParameters['id']!;
            return EditRecipeScreen(recipeId: recipeId);
          },
        ),
      ],
    );
  }
}

/// Observer de navegación para mejorar la experiencia del botón atrás
class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Aquí se puede agregar lógica adicional para el tracking de navegación
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Lógica cuando se hace pop de una ruta
  }
}
