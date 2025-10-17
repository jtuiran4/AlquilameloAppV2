import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registrar nuevo usuario
  Future<UserProfile?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      // Verificar si Firebase Auth está disponible
      if (_auth.app.options.projectId.isEmpty) {
        throw 'Firebase Auth no está configurado correctamente';
      }
      
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Crear perfil de usuario en Firestore
        final userProfile = UserProfile(
          id: user.uid,
          name: '$firstName $lastName',
          email: email,
          phone: phone,
          profileImage: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Guardar perfil en Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userProfile.toFirestore());

        // Actualizar nombre de usuario en Firebase Auth
        await user.updateDisplayName('$firstName $lastName');

        return userProfile;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado durante el registro: $e';
    }
  }

  // Iniciar sesión
  Future<UserProfile?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Obtener perfil de usuario desde Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return UserProfile.fromFirestore(userDoc);
        } else {
          // Si no existe el perfil, crear uno básico
          final userProfile = UserProfile(
            id: user.uid,
            name: user.displayName ?? 'Usuario',
            email: user.email ?? email,
            phone: '',
            profileImage: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userProfile.toFirestore());

          return userProfile;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado durante el inicio de sesión: $e';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error al enviar correo de restablecimiento: $e';
    }
  }

  // Validar formato de email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validar contraseña
  String? validatePassword(String password) {
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }
    return null;
  }

  // Validar nombre
  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (name.trim().length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(name)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  // Validar fecha de nacimiento
  String? validateDateOfBirth(String date) {
    if (date.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    
    try {
      final parts = date.split('/');
      if (parts.length != 3) {
        return 'Formato inválido. Use DD/MM/AAAA';
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      
      if (birthDate.isAfter(now)) {
        return 'La fecha no puede ser futura';
      }
      
      if (age < 18) {
        return 'Debe ser mayor de 18 años';
      }
      
      if (age > 100) {
        return 'Fecha inválida';
      }
      
      return null;
    } catch (e) {
      return 'Formato inválido. Use DD/MM/AAAA';
    }
  }

  // Mensajes de error personalizados
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Formato de correo inválido';
      case 'user-not-found':
        return 'No existe un usuario con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}

// Resultados de autenticación
class AuthResult {
  final bool success;
  final String? error;
  final UserProfile? user;

  AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.success(UserProfile user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult(success: false, error: error);
  }
}