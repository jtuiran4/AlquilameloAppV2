import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/datasources.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._auth, this._firestore);

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        UserProfile? userProfile = await _getUserProfile(user.uid);
        return AuthResult.success(userProfile ?? _createDefaultUserProfile(user, email));
      }
      return AuthResult.failure('Error desconocido');
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado durante el inicio de sesión: $e';
    }
  }

  @override
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.uid,
          name: name,
          email: email,
          phone: '',
          profileImage: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(_userProfileToFirestore(userProfile));

        await user.updateDisplayName(name);

        return AuthResult.success(userProfile);
      }
      return AuthResult.failure('Error desconocido');
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado durante el registro: $e';
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    throw UnimplementedError('Google Sign In not implemented yet');
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await _getUserProfile(user.uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Error al enviar correo de restablecimiento: $e';
    }
  }

  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return _firestoreToUserProfile(userDoc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  UserProfile _createDefaultUserProfile(User user, String email) {
    return UserProfile(
      id: user.uid,
      name: user.displayName ?? 'Usuario',
      email: user.email ?? email,
      phone: '',
      profileImage: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _userProfileToFirestore(UserProfile user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'profileImage': user.profileImage,
      'createdAt': user.createdAt?.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
  }

  UserProfile _firestoreToUserProfile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró un usuario con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      default:
        return 'Error de autenticación desconocido.';
    }
  }
}