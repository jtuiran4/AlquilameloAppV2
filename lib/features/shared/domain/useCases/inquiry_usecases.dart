// Casos de uso para consultas de propiedades
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';

class GetInquiriesByAgentUseCase {
  final PropertyInquiryRepository repository;

  GetInquiriesByAgentUseCase(this.repository);

  Future<List<PropertyInquiry>> execute(String agentId) {
    return repository.getInquiriesByAgent(agentId);
  }
}

class GetInquiriesByUserUseCase {
  final PropertyInquiryRepository repository;

  GetInquiriesByUserUseCase(this.repository);

  Future<List<PropertyInquiry>> execute(String userId) {
    return repository.getInquiriesByUser(userId);
  }
}

class GetInquiryByIdUseCase {
  final PropertyInquiryRepository repository;

  GetInquiryByIdUseCase(this.repository);

  Future<PropertyInquiry?> execute(String id) {
    return repository.getInquiryById(id);
  }
}

class CreateInquiryUseCase {
  final PropertyInquiryRepository repository;

  CreateInquiryUseCase(this.repository);

  Future<void> execute(PropertyInquiry inquiry) {
    return repository.createInquiry(inquiry);
  }
}

class UpdateInquiryStatusUseCase {
  final PropertyInquiryRepository repository;

  UpdateInquiryStatusUseCase(this.repository);

  Future<void> execute(String inquiryId, String status) {
    return repository.updateInquiryStatus(inquiryId, status);
  }
}

class GetPendingInquiriesCountUseCase {
  final PropertyInquiryRepository repository;

  GetPendingInquiriesCountUseCase(this.repository);

  Future<int> execute(String agentId) {
    return repository.getPendingInquiriesCount(agentId);
  }
}

class GetInquiriesByPropertyUseCase {
  final PropertyInquiryRepository repository;

  GetInquiriesByPropertyUseCase(this.repository);

  Future<List<PropertyInquiry>> execute(String propertyId) {
    return repository.getInquiriesByProperty(propertyId);
  }
}