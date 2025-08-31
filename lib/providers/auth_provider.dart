import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  // Inicializar el provider
  void _init() async {
    try {
      // Inicializar Firebase Auth
      _authService.authStateChanges.listen((User? user) async {
        _user = user;
        if (user != null) {
          await _loadUserData();
        } else {
          _userModel = null;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('⚠️ Error al inicializar Firebase Auth: $e');
      _setError('Error de conexión. Verifica tu configuración de Firebase.');
    }
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    
    try {
      _userModel = await _authService.getCurrentUserData();
    } catch (e) {
      _errorMessage = 'Error al cargar datos del usuario: $e';
    }
  }

  // Recargar datos del usuario (método público)
  Future<void> reloadUserData() async {
    await _loadUserData();
    notifyListeners();
  }

  // Registrarse
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential? result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (result != null) {
        await _loadUserData();
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error en el registro: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        await _loadUserData();
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error en el inicio de sesión: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    }
  }

  // Enviar email de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al enviar email: ${_getErrorMessage(e)}');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateUserProfile(updatedUser);
      _userModel = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
      _setLoading(false);
      return false;
    }
  }

  // Eliminar cuenta
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _user = null;
      _userModel = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar cuenta: $e');
      _setLoading(false);
      return false;
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Convertir errores de Firebase a mensajes amigables
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-email':
          return 'Email inválido';
        case 'user-disabled':
          return 'Usuario deshabilitado';
        case 'too-many-requests':
          return 'Demasiados intentos, intenta más tarde';
        default:
          return error.message ?? 'Error desconocido';
      }
    }
    return error.toString();
  }

  // Limpiar mensajes de error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Actualizar nombre de usuario
  Future<void> updateDisplayName(String newName) async {
    if (_user == null || _userModel == null) return;
    
    try {
      _setLoading(true);
      
      // Actualizar en Firebase Auth
      await _user!.updateDisplayName(newName);
      
      // Actualizar en Firestore a través del servicio
      final updatedUser = _userModel!.copyWith(name: newName);
      await _authService.updateUserProfile(updatedUser);
      
      // Recargar datos del usuario
      await _loadUserData();
      
      _clearError();
    } catch (e) {
      _setError(_getErrorMessage(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
