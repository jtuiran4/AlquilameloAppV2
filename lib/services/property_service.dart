import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener todas las propiedades (método simple sin índices)
  Stream<List<Property>> getAllPropertiesSimple() {
    return _firestore
        .collection('properties')
        .snapshots()
        .map((snapshot) {
          List<Property> properties = snapshot.docs
              .map((doc) => Property.fromFirestore(doc.data(), doc.id))
              .where((property) => property.isActive) // Filtrar en el cliente
              .toList();
          
          // Ordenar en el cliente por fecha de creación (más recientes primero)
          properties.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return properties;
        });
  }

  // Obtener todas las propiedades
  Stream<List<Property>> getProperties() {
    return _firestore
        .collection('properties')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          List<Property> properties = snapshot.docs
              .map((doc) => Property.fromFirestore(doc.data(), doc.id))
              .toList();
          
          // Ordenar en el cliente por fecha de creación (más recientes primero)
          properties.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return properties;
        });
  }

  // Obtener propiedades por tipo
  Stream<List<Property>> getPropertiesByType(String type) {
    return _firestore
        .collection('properties')
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
          List<Property> properties = snapshot.docs
              .map((doc) => Property.fromFirestore(doc.data(), doc.id))
              .toList();
          
          // Ordenar en el cliente por fecha de creación (más recientes primero)
          properties.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return properties;
        });
  }

  // Buscar propiedades
  Future<List<Property>> searchProperties({
    String? location,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
  }) async {
    Query query = _firestore.collection('properties').where('isActive', isEqualTo: true);

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isGreaterThanOrEqualTo: location)
                  .where('location', isLessThan: location + 'z');
    }

    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    QuerySnapshot snapshot = await query.get();
    List<Property> properties = snapshot.docs
        .map((doc) => Property.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Filtrar por habitaciones si es necesario (no se puede hacer en Firestore con múltiples where)
    if (minRooms != null) {
      properties = properties.where((p) => p.rooms >= minRooms).toList();
    }
    if (maxRooms != null) {
      properties = properties.where((p) => p.rooms <= maxRooms).toList();
    }

    return properties;
  }

  // Obtener una propiedad específica
  Future<Property?> getProperty(String propertyId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (doc.exists) {
        return Property.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener propiedad: $e');
      return null;
    }
  }

  // ========== SISTEMA DE FAVORITOS CON AUTENTICACIÓN ==========

  // Obtener propiedades favoritas del usuario autenticado
  Stream<List<Property>> getFavoriteProperties() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Retornar lista vacía si no está autenticado
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
          List<Property> favoriteProperties = [];
          
          for (var doc in snapshot.docs) {
            String propertyId = doc.data()['propertyId'] as String;
            Property? property = await getProperty(propertyId);
            if (property != null && property.isActive) {
              favoriteProperties.add(property);
            }
          }
          
          // Ordenar por fecha de agregado (más recientes primero)
          favoriteProperties.sort((a, b) {
            var aTimestamp = snapshot.docs
                .firstWhere((doc) => doc.data()['propertyId'] == a.id)
                .data()['addedAt'] as Timestamp?;
            var bTimestamp = snapshot.docs
                .firstWhere((doc) => doc.data()['propertyId'] == b.id)
                .data()['addedAt'] as Timestamp?;
                
            if (aTimestamp == null && bTimestamp == null) return 0;
            if (aTimestamp == null) return 1;
            if (bTimestamp == null) return -1;
            return bTimestamp.compareTo(aTimestamp);
          });
          
          return favoriteProperties;
        });
  }

  // Verificar si una propiedad es favorita del usuario actual
  Future<bool> isFavorite(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(propertyId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  // Agregar propiedad a favoritos
  Future<bool> addToFavorites(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado. Por favor inicia sesión.';
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'addedAt': FieldValue.serverTimestamp(),
        'userId': currentUser.uid,
      });

      print('✅ Propiedad $propertyId agregada a favoritos');
      return true;
    } catch (e) {
      print('❌ Error al agregar a favoritos: $e');
      throw 'Error al agregar a favoritos: $e';
    }
  }

  // Quitar propiedad de favoritos
  Future<bool> removeFromFavorites(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado. Por favor inicia sesión.';
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(propertyId)
          .delete();

      print('✅ Propiedad $propertyId removida de favoritos');
      return true;
    } catch (e) {
      print('❌ Error al remover de favoritos: $e');
      throw 'Error al remover de favoritos: $e';
    }
  }

  // Toggle favorito (agregar si no está, quitar si está)
  Future<bool> toggleFavorite(String propertyId) async {
    try {
      bool isCurrentlyFavorite = await isFavorite(propertyId);
      
      if (isCurrentlyFavorite) {
        await removeFromFavorites(propertyId);
        return false; // Ya no es favorito
      } else {
        await addToFavorites(propertyId);
        return true; // Ahora es favorito
      }
    } catch (e) {
      print('❌ Error al toggle favorito: $e');
      rethrow;
    }
  }

  // ========== ESTADÍSTICAS Y MÉTRICAS ==========

  // Incrementar contador de vistas
  Future<void> incrementViewCount(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      
      // Incrementar vistas en la propiedad
      await _firestore.collection('properties').doc(propertyId).update({
        'viewsCount': FieldValue.increment(1),
      });

      // Si hay usuario autenticado, incrementar sus estadísticas
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'statistics.viewedProperties': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error al incrementar vistas: $e');
    }
  }

  // Registrar contacto con agente
  Future<bool> contactAgent({
    required String propertyId,
    required String agentId,
    required String message,
    required String contactMethod,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado. Por favor inicia sesión para contactar agentes.';
      }

      // Crear documento de contacto
      await _firestore.collection('contacts').add({
        'userId': currentUser.uid,
        'propertyId': propertyId,
        'agentId': agentId,
        'message': message,
        'contactMethod': contactMethod,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Incrementar contador en el usuario
      await _firestore.collection('users').doc(currentUser.uid).update({
        'statistics.contactedAgents': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error al contactar agente: $e');
      rethrow;
    }
  }
}