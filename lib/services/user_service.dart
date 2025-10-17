import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';

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
      if (currentUser == null) return [];

      // Obtener contactos del usuario
      final contactsSnapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      List<Property> contactedProperties = [];
      
      for (var contact in contactsSnapshot.docs) {
        final propertyId = contact.data()['propertyId'] as String;
        final propertyDoc = await _firestore
            .collection('properties')
            .doc(propertyId)
            .get();
            
        if (propertyDoc.exists) {
          final property = Property.fromFirestore(
            propertyDoc.data() as Map<String, dynamic>, 
            propertyDoc.id
          );
          contactedProperties.add(property);
        }
      }

      return contactedProperties;
    } catch (e) {
      print('❌ Error obteniendo propiedades contactadas: $e');
      return [];
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