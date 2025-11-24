import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/auth/models/user_model.dart';

class AuthService {
  static const String _userKey = 'auth_user';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Simulate Google Sign In
  // TODO: IMPLEMENTACION REAL CON FIREBASE
  // 1. Agregar paquetes: flutter pub add firebase_auth google_sign_in
  // 2. Importar:
  //    import 'package:firebase_auth/firebase_auth.dart';
  //    import 'package:google_sign_in/google_sign_in.dart';
  // 3. Reemplazar este método con la lógica real:
  /*
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Usuario canceló

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
         final userModel = UserModel(
           id: user.uid,
           email: user.email ?? '',
           displayName: user.displayName ?? 'Usuario',
           photoUrl: user.photoURL,
         );
         // Guardar en estado local si se desea
         return userModel;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
  */
  Future<UserModel?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a mock user
    // In a real app, this would come from GoogleSignIn and FirebaseAuth
    final user = UserModel(
      id: 'google_123456789',
      email: 'usuario@ejemplo.com',
      displayName: 'Usuario de Prueba',
      photoUrl: 'https://lh3.googleusercontent.com/a/default-user=s96-c', // Placeholder
    );

    await _saveUser(user);
    return user;
  }

  Future<void> signOut() async {
    // TODO: IMPLEMENTACION REAL CON FIREBASE
    // await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();

    await Future.delayed(const Duration(milliseconds: 500));
    await _prefs.remove(_userKey);
  }

  UserModel? getCurrentUser() {
    // TODO: En Firebase se usa FirebaseAuth.instance.currentUser
    // Pero para persistencia rápida local en este ejemplo mock usamos SharedPreferences
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromMap(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}
