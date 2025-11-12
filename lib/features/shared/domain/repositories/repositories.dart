// Interfaces de repositorio para entidades compartidas
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';

abstract class PropertyRepository {
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
  });

  Future<Property?> getPropertyById(String id);
  Future<List<Property>> getPropertiesByAgent(String agentId);
  Future<List<Property>> getFavoriteProperties(String userId);
  Future<void> addToFavorites(String userId, String propertyId);
  Future<void> removeFromFavorites(String userId, String propertyId);
  Future<bool> isFavorite(String userId, String propertyId);
  Future<void> incrementViews(String propertyId);
  Future<List<Property>> getRecentProperties({int limit = 10});
  Future<List<Property>> getFeaturedProperties({int limit = 5});
}

abstract class AgentRepository {
  Future<List<Agent>> getAgents();
  Future<Agent?> getAgentById(String id);
  Future<List<Agent>> getAgentsByLocation(String location);
  Future<AgentStats> getAgentStats(String agentId);
  Future<List<Property>> getAgentProperties(String agentId);
}

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile user);
  Future<UserStats> getUserStats(String userId);
  Future<List<Property>> getUserFavorites(String userId);
  Future<List<PropertyInquiry>> getUserInquiries(String userId);
}

abstract class PropertyInquiryRepository {
  Future<List<PropertyInquiry>> getInquiriesByAgent(String agentId);
  Future<List<PropertyInquiry>> getInquiriesByUser(String userId);
  Future<PropertyInquiry?> getInquiryById(String id);
  Future<void> createInquiry(PropertyInquiry inquiry);
  Future<void> updateInquiryStatus(String inquiryId, String status);
  Future<int> getPendingInquiriesCount(String agentId);
  Future<List<PropertyInquiry>> getInquiriesByProperty(String propertyId);
}

abstract class AuthRepository {
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password, String name);
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<UserProfile?> getCurrentUser();
  Future<bool> isUserLoggedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
}