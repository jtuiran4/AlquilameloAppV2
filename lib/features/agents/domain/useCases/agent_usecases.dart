import 'package:image_picker/image_picker.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/domain/repositories/agent_repository.dart';

class CreateAgentProfileUseCase {
  final AgentRepository _repository;

  CreateAgentProfileUseCase(this._repository);

  Future<void> call({
    required String name,
    required String phone,
    required String position,
    String? photoUrl,
  }) async {
    return await _repository.createAgentProfile(
      name: name,
      phone: phone,
      position: position,
      photoUrl: photoUrl,
    );
  }
}

class GetCurrentAgentProfileUseCase {
  final AgentRepository _repository;

  GetCurrentAgentProfileUseCase(this._repository);

  Stream<Agent?> call() {
    return _repository.getCurrentAgentProfile();
  }
}

class IsCurrentUserAgentUseCase {
  final AgentRepository _repository;

  IsCurrentUserAgentUseCase(this._repository);

  Future<bool> call() async {
    return await _repository.isCurrentUserAgent();
  }
}

class AddPropertyUseCase {
  final AgentRepository _repository;

  AddPropertyUseCase(this._repository);

  Future<String> call(Property property) async {
    return await _repository.addProperty(property);
  }
}

class GetAgentPropertiesUseCase {
  final AgentRepository _repository;

  GetAgentPropertiesUseCase(this._repository);

  Stream<List<Property>> call() {
    return _repository.getAgentProperties();
  }
}

class GetAgentStatsUseCase {
  final AgentRepository _repository;

  GetAgentStatsUseCase(this._repository);

  Future<AgentStats> call() async {
    return await _repository.getAgentStats();
  }
}

class GetAgentInquiriesUseCase {
  final AgentRepository _repository;

  GetAgentInquiriesUseCase(this._repository);

  Stream<List<PropertyInquiry>> call() {
    return _repository.getAgentInquiries();
  }
}

class UpdateInquiryStatusUseCase {
  final AgentRepository _repository;

  UpdateInquiryStatusUseCase(this._repository);

  Future<void> call(String inquiryId, String status) async {
    return await _repository.updateInquiryStatus(inquiryId, status);
  }
}

class TogglePropertyActiveUseCase {
  final AgentRepository _repository;

  TogglePropertyActiveUseCase(this._repository);

  Future<void> call(String propertyId, bool isActive) async {
    return await _repository.togglePropertyActive(propertyId, isActive);
  }
}

class UpdatePropertyUseCase {
  final AgentRepository _repository;

  UpdatePropertyUseCase(this._repository);

  Future<void> call(String propertyId, Map<String, dynamic> data) async {
    return await _repository.updateProperty(propertyId, data);
  }
}

class UploadImagesUseCase {
  final AgentRepository _repository;

  UploadImagesUseCase(this._repository);

  Future<List<String>> call(List<XFile> images) async {
    return await _repository.uploadImages(images);
  }
}

class DeletePropertyUseCase {
  final AgentRepository _repository;

  DeletePropertyUseCase(this._repository);

  Future<void> call(String propertyId) async {
    return await _repository.deleteProperty(propertyId);
  }
}