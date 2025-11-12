// Casos de uso para agentes
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/repositories/repositories.dart';

class GetAgentsUseCase {
  final AgentRepository repository;

  GetAgentsUseCase(this.repository);

  Future<List<Agent>> execute() {
    return repository.getAgents();
  }
}

class GetAgentByIdUseCase {
  final AgentRepository repository;

  GetAgentByIdUseCase(this.repository);

  Future<Agent?> execute(String id) {
    return repository.getAgentById(id);
  }
}

class GetAgentsByLocationUseCase {
  final AgentRepository repository;

  GetAgentsByLocationUseCase(this.repository);

  Future<List<Agent>> execute(String location) {
    return repository.getAgentsByLocation(location);
  }
}

class GetAgentStatsUseCase {
  final AgentRepository repository;

  GetAgentStatsUseCase(this.repository);

  Future<AgentStats> execute(String agentId) {
    return repository.getAgentStats(agentId);
  }
}

class GetAgentPropertiesUseCase {
  final AgentRepository repository;

  GetAgentPropertiesUseCase(this.repository);

  Future<List<Property>> execute(String agentId) {
    return repository.getAgentProperties(agentId);
  }
}