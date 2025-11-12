// Interfaces de datasource para entidades compartidas
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';

export 'imagekit_datasource.dart';

abstract class PropertyRemoteDataSource {
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
  Future<void> incrementViews(String propertyId);
  Future<List<Property>> getRecentProperties({int limit = 10});
  Future<List<Property>> getFeaturedProperties({int limit = 5});
}

abstract class PropertyLocalDataSource {
  Future<List<Property>> getCachedProperties();
  Future<void> cacheProperties(List<Property> properties);
  Future<Property?> getCachedProperty(String id);
  Future<void> cacheProperty(Property property);
  Future<List<String>> getFavoritePropertyIds(String userId);
  Future<void> addToFavorites(String userId, String propertyId);
  Future<void> removeFromFavorites(String userId, String propertyId);
  Future<bool> isFavorite(String userId, String propertyId);
  Future<void> clearCache();
}

abstract class AgentRemoteDataSource {
  Future<List<Agent>> getAgents();
  Future<Agent?> getAgentById(String id);
  Future<List<Agent>> getAgentsByLocation(String location);
  Future<AgentStats> getAgentStats(String agentId);
}

abstract class AgentLocalDataSource {
  Future<List<Agent>> getCachedAgents();
  Future<void> cacheAgents(List<Agent> agents);
  Future<Agent?> getCachedAgent(String id);
  Future<void> cacheAgent(Agent agent);
  Future<void> clearCache();
}

abstract class UserRemoteDataSource {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile user);
  Future<UserStats> getUserStats(String userId);
}

abstract class UserLocalDataSource {
  Future<UserProfile?> getCachedUserProfile(String userId);
  Future<void> cacheUserProfile(UserProfile user);
  Future<UserStats?> getCachedUserStats(String userId);
  Future<void> cacheUserStats(String userId, UserStats stats);
  Future<void> clearCache();
}

abstract class PropertyInquiryRemoteDataSource {
  Future<List<PropertyInquiry>> getInquiriesByAgent(String agentId);
  Future<List<PropertyInquiry>> getInquiriesByUser(String userId);
  Future<PropertyInquiry?> getInquiryById(String id);
  Future<void> createInquiry(PropertyInquiry inquiry);
  Future<void> updateInquiryStatus(String inquiryId, String status);
  Future<int> getPendingInquiriesCount(String agentId);
  Future<List<PropertyInquiry>> getInquiriesByProperty(String propertyId);
}

abstract class PropertyInquiryLocalDataSource {
  Future<List<PropertyInquiry>> getCachedInquiries(String userId);
  Future<void> cacheInquiries(String userId, List<PropertyInquiry> inquiries);
  Future<PropertyInquiry?> getCachedInquiry(String id);
  Future<void> cacheInquiry(PropertyInquiry inquiry);
  Future<void> clearCache();
}

abstract class AuthRemoteDataSource {
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<AuthResult> signUpWithEmailAndPassword(String email, String password, String name);
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<UserProfile?> getCurrentUser();
  Future<bool> isUserLoggedIn();
  Future<String?> getCurrentUserId();
  Future<void> resetPassword(String email);
}

abstract class AuthLocalDataSource {
  Future<String?> getCachedUserId();
  Future<void> cacheUserId(String userId);
  Future<UserProfile?> getCachedUserProfile();
  Future<void> cacheUserProfile(UserProfile user);
  Future<void> clearAuthCache();
}