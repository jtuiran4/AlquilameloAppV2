import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/domain/usecases/agent_usecases.dart';

class AgentController extends GetxController {
  // Use cases
  late CreateAgentProfileUseCase _createAgentProfileUseCase;
  late GetCurrentAgentProfileUseCase _getCurrentAgentProfileUseCase;
  late IsCurrentUserAgentUseCase _isCurrentUserAgentUseCase;
  late AddPropertyUseCase _addPropertyUseCase;
  late GetAgentPropertiesUseCase _getAgentPropertiesUseCase;
  late GetAgentStatsUseCase _getAgentStatsUseCase;
  late GetAgentInquiriesUseCase _getAgentInquiriesUseCase;
  late UpdateInquiryStatusUseCase _updateInquiryStatusUseCase;
  late TogglePropertyActiveUseCase _togglePropertyActiveUseCase;
  late UpdatePropertyUseCase _updatePropertyUseCase;
  late UploadImagesUseCase _uploadImagesUseCase;
  late DeletePropertyUseCase _deletePropertyUseCase;

  // Reactive variables
  final Rx<Agent?> currentAgent = Rx<Agent?>(null);
  final RxList<Property> agentProperties = <Property>[].obs;
  final RxList<PropertyInquiry> agentInquiries = <PropertyInquiry>[].obs;
  final Rx<AgentStats> agentStats = AgentStats(
    totalProperties: 0,
    activeProperties: 0,
    totalInquiries: 0,
  ).obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Initialize use cases
  void init({
    required CreateAgentProfileUseCase createAgentProfileUseCase,
    required GetCurrentAgentProfileUseCase getCurrentAgentProfileUseCase,
    required IsCurrentUserAgentUseCase isCurrentUserAgentUseCase,
    required AddPropertyUseCase addPropertyUseCase,
    required GetAgentPropertiesUseCase getAgentPropertiesUseCase,
    required GetAgentStatsUseCase getAgentStatsUseCase,
    required GetAgentInquiriesUseCase getAgentInquiriesUseCase,
    required UpdateInquiryStatusUseCase updateInquiryStatusUseCase,
    required TogglePropertyActiveUseCase togglePropertyActiveUseCase,
    required UpdatePropertyUseCase updatePropertyUseCase,
    required UploadImagesUseCase uploadImagesUseCase,
    required DeletePropertyUseCase deletePropertyUseCase,
  }) {
    _createAgentProfileUseCase = createAgentProfileUseCase;
    _getCurrentAgentProfileUseCase = getCurrentAgentProfileUseCase;
    _isCurrentUserAgentUseCase = isCurrentUserAgentUseCase;
    _addPropertyUseCase = addPropertyUseCase;
    _getAgentPropertiesUseCase = getAgentPropertiesUseCase;
    _getAgentStatsUseCase = getAgentStatsUseCase;
    _getAgentInquiriesUseCase = getAgentInquiriesUseCase;
    _updateInquiryStatusUseCase = updateInquiryStatusUseCase;
    _togglePropertyActiveUseCase = togglePropertyActiveUseCase;
    _updatePropertyUseCase = updatePropertyUseCase;
    _uploadImagesUseCase = uploadImagesUseCase;
    _deletePropertyUseCase = deletePropertyUseCase;

    // Load initial data
    loadAgentData();
  }

  // Load agent data
  void loadAgentData() {
    _loadCurrentAgentProfile();
    _loadAgentProperties();
    _loadAgentStats();
    _loadAgentInquiries();
  }

  // Create agent profile
  Future<void> createAgentProfile({
    required String name,
    required String phone,
    required String position,
    String? photoUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _createAgentProfileUseCase.call(
        name: name,
        phone: phone,
        position: position,
        photoUrl: photoUrl,
      );

      // Reload agent data after creation
      loadAgentData();
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error creando perfil de agente: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load current agent profile
  void _loadCurrentAgentProfile() {
    _getCurrentAgentProfileUseCase.call().listen((agent) {
      currentAgent.value = agent;
    });
  }

  // Check if current user is agent
  Future<bool> isCurrentUserAgent() async {
    try {
      return await _isCurrentUserAgentUseCase.call();
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  // Add property
  Future<String?> addProperty(Property property) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final propertyId = await _addPropertyUseCase.call(property);
      return propertyId;
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error agregando propiedad: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Load agent properties
  void _loadAgentProperties() {
    _getAgentPropertiesUseCase.call().listen((properties) {
      agentProperties.value = properties;
    });
  }

  // Load agent stats
  void _loadAgentStats() async {
    try {
      final stats = await _getAgentStatsUseCase.call();
      agentStats.value = stats;
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error cargando estadísticas: $e');
    }
  }

  // Load agent inquiries
  void _loadAgentInquiries() {
    _getAgentInquiriesUseCase.call().listen((inquiries) {
      agentInquiries.value = inquiries;
    });
  }

  // Update inquiry status
  Future<void> updateInquiryStatus(String inquiryId, String status) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _updateInquiryStatusUseCase.call(inquiryId, status);
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error actualizando estado de consulta: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle property active status
  Future<void> togglePropertyActive(String propertyId, bool isActive) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _togglePropertyActiveUseCase.call(propertyId, isActive);
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error cambiando estado de propiedad: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update property
  Future<void> updateProperty(String propertyId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _updatePropertyUseCase.call(propertyId, data);
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error actualizando propiedad: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Upload images
  Future<List<String>> uploadImages(List<XFile> images) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final imageUrls = await _uploadImagesUseCase.call(images);
      return imageUrls;
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error subiendo imágenes: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _deletePropertyUseCase.call(propertyId);
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error eliminando propiedad: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}