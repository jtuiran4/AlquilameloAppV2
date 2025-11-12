import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/datasources.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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
    try {
      // Intentar obtener desde remoto primero
      final properties = await remoteDataSource.getProperties(
        searchQuery: searchQuery,
        action: action,
        type: type,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        location: location,
        limit: limit,
        offset: offset,
      );

      // Cachear las propiedades obtenidas
      await localDataSource.cacheProperties(properties);

      return properties;
    } catch (e) {
      // Si falla el remoto, intentar obtener desde cache local
      try {
        return await localDataSource.getCachedProperties();
      } catch (cacheError) {
        throw Exception('Error al obtener propiedades: $e. Error de cache: $cacheError');
      }
    }
  }

  @override
  Future<Property?> getPropertyById(String id) async {
    try {
      // Intentar obtener desde remoto primero
      final property = await remoteDataSource.getPropertyById(id);
      if (property != null) {
        await localDataSource.cacheProperty(property);
      }
      return property;
    } catch (e) {
      // Si falla el remoto, intentar obtener desde cache local
      try {
        return await localDataSource.getCachedProperty(id);
      } catch (cacheError) {
        throw Exception('Error al obtener propiedad: $e. Error de cache: $cacheError');
      }
    }
  }

  @override
  Future<List<Property>> getPropertiesByAgent(String agentId) async {
    try {
      return await remoteDataSource.getPropertiesByAgent(agentId);
    } catch (e) {
      throw Exception('Error al obtener propiedades del agente: $e');
    }
  }

  @override
  Future<List<Property>> getFavoriteProperties(String userId) async {
    try {
      // Obtener IDs de favoritos desde local
      final favoriteIds = await localDataSource.getFavoritePropertyIds(userId);

      if (favoriteIds.isEmpty) {
        return [];
      }

      // Obtener propiedades desde remoto (podríamos optimizar esto)
      final allProperties = await remoteDataSource.getProperties(limit: 1000);

      // Filtrar solo las favoritas
      final favoriteProperties = allProperties
          .where((property) => favoriteIds.contains(property.id))
          .map((property) => property.copyWith(isFavorite: true))
          .toList();

      return favoriteProperties;
    } catch (e) {
      throw Exception('Error al obtener propiedades favoritas: $e');
    }
  }

  @override
  Future<void> addToFavorites(String userId, String propertyId) async {
    try {
      await localDataSource.addToFavorites(userId, propertyId);
    } catch (e) {
      throw Exception('Error al agregar a favoritos: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String propertyId) async {
    try {
      await localDataSource.removeFromFavorites(userId, propertyId);
    } catch (e) {
      throw Exception('Error al remover de favoritos: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String propertyId) async {
    try {
      return await localDataSource.isFavorite(userId, propertyId);
    } catch (e) {
      throw Exception('Error al verificar favorito: $e');
    }
  }

  @override
  Future<void> incrementViews(String propertyId) async {
    try {
      await remoteDataSource.incrementViews(propertyId);
    } catch (e) {
      // No lanzar error si falla incrementar vistas, es secundario
      print('Error al incrementar vistas: $e');
    }
  }

  @override
  Future<List<Property>> getRecentProperties({int limit = 10}) async {
    try {
      return await remoteDataSource.getRecentProperties(limit: limit);
    } catch (e) {
      throw Exception('Error al obtener propiedades recientes: $e');
    }
  }

  @override
  Future<List<Property>> getFeaturedProperties({int limit = 5}) async {
    try {
      return await remoteDataSource.getFeaturedProperties(limit: limit);
    } catch (e) {
      throw Exception('Error al obtener propiedades destacadas: $e');
    }
  }
}