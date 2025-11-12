import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/datasources.dart';

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final FirebaseFirestore _firestore;

  PropertyRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<Property>> getProperties({
    String? searchQuery,
    String? action,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    String? location,
    int limit = 20,
    int offset = 0,
  }) async {
    Query query = _firestore.collection('properties').where('isActive', isEqualTo: true);

    // Aplicar filtros
    if (action != null && action.isNotEmpty) {
      query = query.where('action', isEqualTo: action);
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

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isGreaterThanOrEqualTo: location)
                  .where('location', isLessThan: '${location}z');
    }

    // Aplicar límite y offset
    query = query.limit(limit);

    QuerySnapshot snapshot = await query.get();
    List<Property> properties = snapshot.docs
        .map((doc) => _mapFirestoreToProperty(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Filtrar por habitaciones si es necesario (no se puede hacer en Firestore con múltiples where)
    if (minBedrooms != null) {
      properties = properties.where((p) => p.bedrooms >= minBedrooms).toList();
    }
    if (maxBedrooms != null) {
      properties = properties.where((p) => p.bedrooms <= maxBedrooms).toList();
    }

    // Filtrar por búsqueda de texto si es necesario
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      properties = properties.where((p) =>
        p.title.toLowerCase().contains(queryLower) ||
        p.description.toLowerCase().contains(queryLower) ||
        p.location.toLowerCase().contains(queryLower)
      ).toList();
    }

    // Ordenar por fecha de creación (más recientes primero)
    properties.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return properties;
  }

  @override
  Future<Property?> getPropertyById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('properties')
          .doc(id)
          .get();

      if (doc.exists) {
        return _mapFirestoreToProperty(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener propiedad: $e');
    }
  }

  @override
  Future<List<Property>> getPropertiesByAgent(String agentId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('properties')
        .where('agentId', isEqualTo: agentId)
        .where('isActive', isEqualTo: true)
        .get();

    List<Property> properties = snapshot.docs
        .map((doc) => _mapFirestoreToProperty(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Ordenar por fecha de creación (más recientes primero)
    properties.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return properties;
  }

  @override
  Future<void> incrementViews(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).update({
        'viewsCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error al incrementar vistas: $e');
    }
  }

  @override
  Future<List<Property>> getRecentProperties({int limit = 10}) async {
    QuerySnapshot snapshot = await _firestore
        .collection('properties')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => _mapFirestoreToProperty(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<List<Property>> getFeaturedProperties({int limit = 5}) async {
    // Por ahora, las propiedades destacadas son las más recientes con más vistas
    QuerySnapshot snapshot = await _firestore
        .collection('properties')
        .where('isActive', isEqualTo: true)
        .orderBy('viewsCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => _mapFirestoreToProperty(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Property _mapFirestoreToProperty(Map<String, dynamic> data, String id) {
    return Property(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      action: data['action'] ?? '',
      type: data['type'] ?? '',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      area: (data['area'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      agentId: data['agentId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      viewsCount: data['viewsCount'] ?? 0,
      favoritesCount: data['favoritesCount'] ?? 0,
      features: Map<String, dynamic>.from(data['features'] ?? {}),
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}