import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/datasources.dart';

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  final SharedPreferences _prefs;
  static const String _propertiesKey = 'cached_properties';
  static const String _favoritesKey = 'favorite_properties';

  PropertyLocalDataSourceImpl(this._prefs);

  @override
  Future<List<Property>> getCachedProperties() async {
    final propertiesJson = _prefs.getStringList(_propertiesKey) ?? [];
    return propertiesJson.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return _mapJsonToProperty(data);
    }).toList();
  }

  @override
  Future<void> cacheProperties(List<Property> properties) async {
    final propertiesJson = properties.map((property) => jsonEncode(_mapPropertyToJson(property))).toList();
    await _prefs.setStringList(_propertiesKey, propertiesJson);
  }

  @override
  Future<Property?> getCachedProperty(String id) async {
    final properties = await getCachedProperties();
    return properties.where((property) => property.id == id).firstOrNull;
  }

  @override
  Future<void> cacheProperty(Property property) async {
    final properties = await getCachedProperties();
    final existingIndex = properties.indexWhere((p) => p.id == property.id);

    if (existingIndex != -1) {
      properties[existingIndex] = property;
    } else {
      properties.add(property);
    }

    await cacheProperties(properties);
  }

  @override
  Future<List<String>> getFavoritePropertyIds(String userId) async {
    final favoritesKey = '${_favoritesKey}_$userId';
    return _prefs.getStringList(favoritesKey) ?? [];
  }

  @override
  Future<void> addToFavorites(String userId, String propertyId) async {
    final favoritesKey = '${_favoritesKey}_$userId';
    final favorites = await getFavoritePropertyIds(userId);

    if (!favorites.contains(propertyId)) {
      favorites.add(propertyId);
      await _prefs.setStringList(favoritesKey, favorites);
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String propertyId) async {
    final favoritesKey = '${_favoritesKey}_$userId';
    final favorites = await getFavoritePropertyIds(userId);
    favorites.remove(propertyId);
    await _prefs.setStringList(favoritesKey, favorites);
  }

  @override
  Future<bool> isFavorite(String userId, String propertyId) async {
    final favorites = await getFavoritePropertyIds(userId);
    return favorites.contains(propertyId);
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_propertiesKey);

    // Limpiar todos los favoritos (esto es simplificado, en producción podrías mantenerlos)
    final keys = _prefs.getKeys().where((key) => key.startsWith(_favoritesKey));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  Map<String, dynamic> _mapPropertyToJson(Property property) {
    return {
      'id': property.id,
      'title': property.title,
      'description': property.description,
      'price': property.price,
      'action': property.action,
      'type': property.type,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'area': property.area,
      'location': property.location,
      'imageUrl': property.imageUrl,
      'imageUrls': property.imageUrls,
      'agentId': property.agentId,
      'isActive': property.isActive,
      'createdAt': property.createdAt?.toIso8601String(),
      'updatedAt': property.updatedAt?.toIso8601String(),
      'viewsCount': property.viewsCount,
      'favoritesCount': property.favoritesCount,
      'features': property.features,
      'isFavorite': property.isFavorite,
    };
  }

  Property _mapJsonToProperty(Map<String, dynamic> data) {
    return Property(
      id: data['id'] ?? '',
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
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      viewsCount: data['viewsCount'] ?? 0,
      favoritesCount: data['favoritesCount'] ?? 0,
      features: Map<String, dynamic>.from(data['features'] ?? {}),
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}