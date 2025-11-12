// Casos de uso para propiedades
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';

class GetPropertiesUseCase {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  Future<List<Property>> execute({
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
  }) {
    return repository.getProperties(
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
  }
}

class GetPropertyByIdUseCase {
  final PropertyRepository repository;

  GetPropertyByIdUseCase(this.repository);

  Future<Property?> execute(String id) {
    return repository.getPropertyById(id);
  }
}

class GetPropertiesByAgentUseCase {
  final PropertyRepository repository;

  GetPropertiesByAgentUseCase(this.repository);

  Future<List<Property>> execute(String agentId) {
    return repository.getPropertiesByAgent(agentId);
  }
}

class GetFavoritePropertiesUseCase {
  final PropertyRepository repository;

  GetFavoritePropertiesUseCase(this.repository);

  Future<List<Property>> execute(String userId) {
    return repository.getFavoriteProperties(userId);
  }
}

class ToggleFavoriteUseCase {
  final PropertyRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String userId, String propertyId, bool isFavorite) async {
    if (isFavorite) {
      await repository.addToFavorites(userId, propertyId);
    } else {
      await repository.removeFromFavorites(userId, propertyId);
    }
  }
}

class IsFavoriteUseCase {
  final PropertyRepository repository;

  IsFavoriteUseCase(this.repository);

  Future<bool> execute(String userId, String propertyId) {
    return repository.isFavorite(userId, propertyId);
  }
}

class IncrementPropertyViewsUseCase {
  final PropertyRepository repository;

  IncrementPropertyViewsUseCase(this.repository);

  Future<void> execute(String propertyId) {
    return repository.incrementViews(propertyId);
  }
}

class GetRecentPropertiesUseCase {
  final PropertyRepository repository;

  GetRecentPropertiesUseCase(this.repository);

  Future<List<Property>> execute({int limit = 10}) {
    return repository.getRecentProperties(limit: limit);
  }
}

class GetFeaturedPropertiesUseCase {
  final PropertyRepository repository;

  GetFeaturedPropertiesUseCase(this.repository);

  Future<List<Property>> execute({int limit = 5}) {
    return repository.getFeaturedProperties(limit: limit);
  }
}