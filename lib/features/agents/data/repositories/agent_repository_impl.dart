import 'package:image_picker/image_picker.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/domain/repositories/agent_repository.dart';
import 'package:alquilamelo_app/features/agents/data/datasources/agent_remote_datasource.dart';

class AgentRepositoryImpl implements AgentRepository {
  final AgentRemoteDataSource _remoteDataSource;

  AgentRepositoryImpl({
    required AgentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> createAgentProfile({
    required String name,
    required String phone,
    required String position,
    String? photoUrl,
  }) async {
    return await _remoteDataSource.createAgentProfile(
      name: name,
      phone: phone,
      position: position,
      photoUrl: photoUrl,
    );
  }

  @override
  Stream<Agent?> getCurrentAgentProfile() {
    return _remoteDataSource.getCurrentAgentProfile();
  }

  @override
  Future<bool> isCurrentUserAgent() async {
    return await _remoteDataSource.isCurrentUserAgent();
  }

  @override
  Future<String> addProperty(Property property) async {
    return await _remoteDataSource.addProperty(property);
  }

  @override
  Stream<List<Property>> getAgentProperties() {
    return _remoteDataSource.getAgentProperties();
  }

  @override
  Future<AgentStats> getAgentStats() async {
    return await _remoteDataSource.getAgentStats();
  }

  @override
  Stream<List<PropertyInquiry>> getAgentInquiries() {
    return _remoteDataSource.getAgentInquiries();
  }

  @override
  Future<void> updateInquiryStatus(String inquiryId, String status) async {
    return await _remoteDataSource.updateInquiryStatus(inquiryId, status);
  }

  @override
  Future<void> togglePropertyActive(String propertyId, bool isActive) async {
    return await _remoteDataSource.togglePropertyActive(propertyId, isActive);
  }

  @override
  Future<void> updateProperty(String propertyId, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateProperty(propertyId, data);
  }

  @override
  Future<List<String>> uploadImages(List<XFile> images) async {
    return await _remoteDataSource.uploadImages(images);
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    return await _remoteDataSource.deleteProperty(propertyId);
  }
}