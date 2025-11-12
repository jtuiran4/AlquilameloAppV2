import 'package:image_picker/image_picker.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';

abstract class AgentRepository {
  Future<void> createAgentProfile({
    required String name,
    required String phone,
    required String position,
    String? photoUrl,
  });

  Stream<Agent?> getCurrentAgentProfile();

  Future<bool> isCurrentUserAgent();

  Future<String> addProperty(Property property);

  Stream<List<Property>> getAgentProperties();

  Future<AgentStats> getAgentStats();

  Stream<List<PropertyInquiry>> getAgentInquiries();

  Future<void> updateInquiryStatus(String inquiryId, String status);

  Future<void> togglePropertyActive(String propertyId, bool isActive);

  Future<void> updateProperty(String propertyId, Map<String, dynamic> data);

  Future<List<String>> uploadImages(List<XFile> images);

  Future<void> deleteProperty(String propertyId);
}