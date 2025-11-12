// Casos de uso para usuarios
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile?> execute(String userId) {
    return repository.getUserProfile(userId);
  }
}

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> execute(UserProfile user) {
    return repository.updateUserProfile(user);
  }
}

class GetUserStatsUseCase {
  final UserRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<UserStats> execute(String userId) {
    return repository.getUserStats(userId);
  }
}

class GetUserFavoritesUseCase {
  final UserRepository repository;

  GetUserFavoritesUseCase(this.repository);

  Future<List<Property>> execute(String userId) {
    return repository.getUserFavorites(userId);
  }
}

class GetUserInquiriesUseCase {
  final UserRepository repository;

  GetUserInquiriesUseCase(this.repository);

  Future<List<PropertyInquiry>> execute(String userId) {
    return repository.getUserInquiries(userId);
  }
}