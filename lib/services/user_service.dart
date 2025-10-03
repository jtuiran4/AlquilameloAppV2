import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ID de usuario demo (ya que no tenemos autenticación)
  static const String demoUserId = 'demo-user-123';
  
  // Obtener perfil de usuario
  Stream<UserProfile?> getUserProfile() {
    return _firestore
        .collection('users')
        .doc(demoUserId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Crear o actualizar perfil de usuario
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(demoUserId)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  // Obtener estadísticas del usuario
  Future<UserStats> getUserStats() async {
    try {
      // Obtener favoritos
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(demoUserId)
          .collection('favorites')
          .get();
      
      // Obtener propiedades vistas (simulado por ahora)
      final viewedSnapshot = await _firestore
          .collection('users')
          .doc(demoUserId)
          .collection('viewed_properties')
          .get();
      
      // Obtener contactos con agentes
      final contactsSnapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: demoUserId)
          .get();
      
      return UserStats(
        favoriteCount: favoritesSnapshot.docs.length,
        viewedCount: viewedSnapshot.docs.length,
        contactedAgents: contactsSnapshot.docs.length,
      );
    } catch (e) {
      print('Error getting user stats: $e');
      // Retornar estadísticas por defecto en caso de error
      return UserStats(favoriteCount: 0, viewedCount: 0, contactedAgents: 0);
    }
  }
  
  // Agregar propiedad a las vistas
  Future<void> addViewedProperty(String propertyId) async {
    try {
      await _firestore
          .collection('users')
          .doc(demoUserId)
          .collection('viewed_properties')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'viewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding viewed property: $e');
    }
  }
  
  // Obtener configuraciones del usuario
  Stream<UserSettings> getUserSettings() {
    return _firestore
        .collection('users')
        .doc(demoUserId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserSettings(
          notificationsEnabled: data['notificationsEnabled'] ?? true,
          darkModeEnabled: data['darkModeEnabled'] ?? false,
          preferredLanguage: data['preferredLanguage'] ?? 'Español',
        );
      }
      return UserSettings(
        notificationsEnabled: true,
        darkModeEnabled: false,
        preferredLanguage: 'Español',
      );
    });
  }
  
  // Actualizar configuraciones del usuario
  Future<void> updateUserSettings(UserSettings settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(demoUserId)
          .set({
        'notificationsEnabled': settings.notificationsEnabled,
        'darkModeEnabled': settings.darkModeEnabled,
        'preferredLanguage': settings.preferredLanguage,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }
  
  // Inicializar perfil de usuario demo
  Future<void> initializeDemoUser() async {
    try {
      final userDoc = await _firestore.collection('users').doc(demoUserId).get();
      
      if (!userDoc.exists) {
        final demoProfile = UserProfile(
          id: demoUserId,
          name: 'Juan Carlos Pérez',
          email: 'juan.perez@email.com',
          phone: '+57 300 123 4567',
          profileImage: '',
          memberSince: '2023',
          notificationsEnabled: true,
          darkModeEnabled: false,
          preferredLanguage: 'Español',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await updateUserProfile(demoProfile);
        print('Demo user profile initialized');
      }
    } catch (e) {
      print('Error initializing demo user: $e');
    }
  }
}

// Clases auxiliares para manejo de datos
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

class UserSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String preferredLanguage;
  
  UserSettings({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.preferredLanguage,
  });
}