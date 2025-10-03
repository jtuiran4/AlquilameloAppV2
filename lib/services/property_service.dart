import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Agregar propiedad a favoritos (sin autenticación)
  Future<bool> addToFavorites(String propertyId) async {
    try {
      // Usar ID de usuario mock para desarrollo
      const String mockUserId = 'demo-user-123';

      // Agregar a la subcolección de favoritos del usuario
      await _firestore
          .collection('users')
          .doc(mockUserId)
          .collection('favorites')
          .doc(propertyId)
          .set({
        'propertyId': propertyId,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Incrementar contador de favoritos en el usuario
      await _firestore.collection('users').doc(mockUserId).update({
        'statistics.favoritesCount': FieldValue.increment(1),
      });

      // Incrementar contador de favoritos en la propiedad
      await _firestore.collection('properties').doc(propertyId).update({
        'favoritesCount': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error al agregar a favoritos: $e');
      return false;
    }
  }

  // Quitar propiedad de favoritos (sin autenticación)
  Future<bool> removeFromFavorites(String propertyId) async {
    try {
      // Usar ID de usuario mock para desarrollo
      const String mockUserId = 'demo-user-123';

      // Remover de la subcolección de favoritos del usuario
      await _firestore
          .collection('users')
          .doc(mockUserId)
          .collection('favorites')
          .doc(propertyId)
          .delete();

      // Decrementar contador de favoritos en el usuario
      await _firestore.collection('users').doc(mockUserId).update({
        'statistics.favoritesCount': FieldValue.increment(-1),
      });

      // Decrementar contador de favoritos en la propiedad
      await _firestore.collection('properties').doc(propertyId).update({
        'favoritesCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error al quitar de favoritos: $e');
      return false;
    }
  }

  // Obtener propiedades favoritas del usuario (sin autenticación)
  Stream<List<Property>> getFavoriteProperties() {
    // Usar ID de usuario mock para desarrollo
    const String mockUserId = 'demo-user-123';

    return _firestore
        .collection('users')
        .doc(mockUserId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Property> favoriteProperties = [];
      
      // Crear lista de documentos con timestamp para ordenar
      List<Map<String, dynamic>> docsWithTimestamp = snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'propertyId': data['propertyId'],
          'addedAt': data['addedAt'] ?? Timestamp.now(),
        };
      }).toList();
      
      // Ordenar por fecha de agregado (más recientes primero)
      docsWithTimestamp.sort((a, b) {
        Timestamp timeA = a['addedAt'];
        Timestamp timeB = b['addedAt'];
        return timeB.compareTo(timeA);
      });

      for (var docData in docsWithTimestamp) {
        String propertyId = docData['propertyId'];
        Property? property = await getProperty(propertyId);
        if (property != null) {
          favoriteProperties.add(property);
        }
      }

      return favoriteProperties;
    });
  }

  // Verificar si una propiedad está en favoritos (sin autenticación)
  Future<bool> isFavorite(String propertyId) async {
    try {
      // Usar ID de usuario mock para desarrollo
      const String mockUserId = 'demo-user-123';

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(mockUserId)
          .collection('favorites')
          .doc(propertyId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  // Incrementar contador de vistas (sin autenticación)
  Future<void> incrementViewCount(String propertyId) async {
    try {
      // Incrementar vistas en la propiedad
      await _firestore.collection('properties').doc(propertyId).update({
        'viewsCount': FieldValue.increment(1),
      });

      // Incrementar contador en usuario mock
      const String mockUserId = 'demo-user-123';
      await _firestore.collection('users').doc(mockUserId).update({
        'statistics.viewedProperties': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error al incrementar vistas: $e');
    }
  }

  // Registrar contacto con agente (sin autenticación)
  Future<bool> contactAgent({
    required String propertyId,
    required String agentId,
    required String message,
    required String contactMethod,
  }) async {
    try {
      // Usar ID de usuario mock para desarrollo
      const String mockUserId = 'demo-user-123';

      // Crear documento de contacto
      await _firestore.collection('contacts').add({
        'userId': mockUserId,
        'propertyId': propertyId,
        'agentId': agentId,
        'message': message,
        'contactMethod': contactMethod,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Incrementar contador en el usuario
      await _firestore.collection('users').doc(mockUserId).update({
        'statistics.contactedAgents': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error al contactar agente: $e');
      return false;
    }
  }
}