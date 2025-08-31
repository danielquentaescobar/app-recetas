import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrarse con email y contraseña
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento de usuario en Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!, name);
      }

      return result;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar email de restablecimiento: $e');
      rethrow;
    }
  }

  // Crear documento de usuario en Firestore
  Future<void> _createUserDocument(User user, String name) async {
    try {
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());
    } catch (e) {
      print('Error al crear documento de usuario: $e');
      rethrow;
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      rethrow;
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toFirestore());
    } catch (e) {
      print('Error al actualizar perfil: $e');
      rethrow;
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Eliminar documento de Firestore
        await _firestore.collection('users').doc(currentUser!.uid).delete();
        
        // Eliminar cuenta de Firebase Auth
        await currentUser!.delete();
      }
    } catch (e) {
      print('Error al eliminar cuenta: $e');
      rethrow;
    }
  }
}
