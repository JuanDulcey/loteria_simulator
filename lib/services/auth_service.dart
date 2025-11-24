import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../modules/auth/models/user_model.dart';

class AuthService {
  static const String _userKey = 'auth_user';
  final SharedPreferences _prefs;

  // Instancias privadas
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._prefs);

  /// Iniciar sesión con Google (REAL)
  Future<UserModel?> signInWithGoogle() async {
    try {
      // A. Disparar el flujo de selección de cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // El usuario cerró la ventana de login
      }

      // B. Obtener los tokens de autenticación de la cuenta seleccionada
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // C. Crear credencial para Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // D. Iniciar sesión en Firebase con esa credencial
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // E. Crear nuestro modelo de usuario propio
        final userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Usuario',
          photoUrl: firebaseUser.photoURL ?? '',
        );

        // F. Guardar sesión localmente (Persistencia rápida)
        await _saveUser(userModel);

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("❌ Firebase Auth Error: ${e.message} (${e.code})");
      }
      // Re-throw or handle specific errors here
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error Genérico en Login Google: $e");
      }
    }
    return null;
  }

  /// Cerrar Sesión (REAL)
  Future<void> signOut() async {
    try {
      // 1. Cerrar sesión en Google
      await _googleSignIn.signOut();

      // 2. Cerrar sesión en Firebase
      await _firebaseAuth.signOut();

      // 3. Borrar datos locales
      await _prefs.remove(_userKey);
    } catch (e) {
      if (kDebugMode) {
        print("Error al cerrar sesión: $e");
      }
    }
  }

  /// Obtener usuario actual (Síncrono/Local)
  /// Usamos SharedPreferences para una respuesta instantánea al iniciar la app
  UserModel? getCurrentUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromMap(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// Método privado para persistencia
  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}
