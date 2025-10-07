// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // <- para PlatformException

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserCredential> registerWithEmail(String email, String password, {String? displayName}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      await cred.user?.reload();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Google Sign-In (requiere proveedor Google activo y SHA-1/SHA-256 en Firebase)
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } on PlatformException catch (e) {
      // Errores típicos: code 10 (DEVELOPER_ERROR) cuando faltan fingerprints
      throw Exception('Error nativo Google Sign-In: ${e.code} ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar con Google: $e');
    }
  }

  Exception _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return Exception('Correo inválido.');
      case 'user-disabled': return Exception('Usuario deshabilitado.');
      case 'user-not-found': return Exception('Usuario no encontrado.');
      case 'wrong-password': return Exception('Contraseña incorrecta.');
      case 'email-already-in-use': return Exception('El correo ya está registrado.');
      case 'weak-password': return Exception('Contraseña demasiado débil.');
      case 'operation-not-allowed': return Exception('Operación no permitida en el proyecto Firebase.');
      default: return Exception('Error de autenticación: ${e.code}');
    }
  }
}
