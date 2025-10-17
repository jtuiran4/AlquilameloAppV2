import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import 'shared_preferences_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener perfil de usuario autenticado
  Stream<UserProfile?> getUserProfile() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        // Crear perfil automáticamente si no existe
        _createUserProfileFromAuth(currentUser);
        return UserProfile(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: currentUser.displayName ?? 'Usuario',
          phone: '',
          createdAt: DateTime.now(),
        );
      }
    });
  }

  // Crear perfil de usuario desde Firebase Auth
  Future<void> _createUserProfileFromAuth(User user) async {
    try {
      final userProfile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'Usuario',
        email: user.email ?? '',
        phone: '',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toFirestore());
      
      // Perfil creado
    } catch (e) {
      print('❌ Error creando perfil de usuario: $e');
    }
  }

  // Crear o actualizar perfil de usuario
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado';
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));
      
      // Marcar última sincronización
      await SharedPreferencesService.setLastSyncTime(DateTime.now());
      
      // Perfil actualizado
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Obtener estadísticas del usuario autenticado
  Future<UserStats> getUserStats() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return UserStats(favoriteCount: 0, viewedCount: 0, contactedAgents: 0);
      }

      // Obtener favoritos
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .get();

      // Obtener documento del usuario para estadísticas
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      int viewedCount = 0;
      int contactedAgents = 0;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final stats = userData['statistics'] as Map<String, dynamic>? ?? {};
        viewedCount = stats['viewedProperties'] ?? 0;
        contactedAgents = stats['contactedAgents'] ?? 0;
      }

      return UserStats(
        favoriteCount: favoritesSnapshot.docs.length,
        viewedCount: viewedCount,
        contactedAgents: contactedAgents,
      );
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return UserStats(favoriteCount: 0, viewedCount: 0, contactedAgents: 0);
    }
  }

  // Obtener propiedades contactadas por el usuario
  Future<List<Property>> getContactedProperties() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Primero intentar obtener contactos SIN orderBy para evitar problemas de índices
      QuerySnapshot contactsSnapshot;
      try {
        contactsSnapshot = await _firestore
            .collection('contacts')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (orderByError) {
        // Si falla el orderBy (puede ser por falta de índice), intentar sin él
        contactsSnapshot = await _firestore
            .collection('contacts')
            .where('userId', isEqualTo: currentUser.uid)
            .get();
      }

      List<Property> contactedProperties = [];
      Set<String> processedPropertyIds = {}; // Para evitar duplicados
      
      for (var contact in contactsSnapshot.docs) {
        final contactData = contact.data() as Map<String, dynamic>;
        final propertyId = contactData['propertyId'] as String?;
        
        if (propertyId == null || propertyId.isEmpty) {
          continue;
        }
        
        // Evitar propiedades duplicadas
        if (processedPropertyIds.contains(propertyId)) {
          continue;
        }
        processedPropertyIds.add(propertyId);
        
        try {
          final propertyDoc = await _firestore
              .collection('properties')
              .doc(propertyId)
              .get();
              
          if (propertyDoc.exists) {
            final propertyData = propertyDoc.data() as Map<String, dynamic>;
            final property = Property.fromFirestore(propertyData, propertyDoc.id);
            contactedProperties.add(property);
          }
        } catch (propertyError) {
          // Error silenciado para evitar interrumpir el flujo
        }
      }

      // Ordenar por título si no pudimos ordenar por fecha
      if (contactedProperties.isNotEmpty) {
        contactedProperties.sort((a, b) => a.title.compareTo(b.title));
      }
      
      return contactedProperties;
    } catch (e) {
      return [];
    }
  }

  // Método simple para verificar si existen contactos
  Future<int> getContactsCount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final contactsSnapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return contactsSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado';
      }

      // Re-autenticar al usuario con su contraseña actual
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);
      
      // Cambiar la contraseña
      await currentUser.updatePassword(newPassword);
      
      print('✅ Contraseña cambiada correctamente');
    } catch (e) {
      print('❌ Error cambiando contraseña: $e');
      if (e.toString().contains('wrong-password')) {
        throw 'La contraseña actual es incorrecta';
      } else if (e.toString().contains('weak-password')) {
        throw 'La nueva contraseña es muy débil';
      } else if (e.toString().contains('requires-recent-login')) {
        throw 'Por seguridad, necesitas volver a iniciar sesión antes de cambiar la contraseña';
      }
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      rethrow;
    }
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Verificar si el usuario está autenticado
  bool get isAuthenticated {
    return _auth.currentUser != null;
  }

  // Obtener email del usuario actual
  String? get currentUserEmail {
    return _auth.currentUser?.email;
  }

  // Obtener UID del usuario actual
  String? get currentUserId {
    return _auth.currentUser?.uid;
  }
}

// Clase para estadísticas del usuario
class UserStats {
  final int favoriteCount;
  final int viewedCount;
  final int contactedAgents;

  UserStats({
    required this.favoriteCount,
    required this.viewedCount,
    required this.contactedAgents,
  });
}