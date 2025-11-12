import 'package:get/get.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class AgentInquiriesController extends GetxController {
  final AgentController agentController = Get.find<AgentController>();

  // Estado observable
  final RxList<PropertyInquiry> inquiries = <PropertyInquiry>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'Todos'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInquiries();
  }

  /// Cargar consultas
  void _loadInquiries() {
    isLoading.value = true;
    // Observar cambios en las consultas del agente
    ever(agentController.agentInquiries, (_) {
      _applyFilter();
    });
    _applyFilter();
    isLoading.value = false;
  }

  /// Aplicar filtro
  void _applyFilter() {
    if (selectedFilter.value == 'Todos') {
      inquiries.value = agentController.agentInquiries.toList();
    } else {
      inquiries.value = agentController.agentInquiries
          .where((inquiry) => inquiry.status == selectedFilter.value)
          .toList();
    }
  }

  /// Cambiar filtro
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  /// Actualizar estado de consulta
  Future<void> updateInquiryStatus(String inquiryId, String newStatus) async {
    try {
      await agentController.updateInquiryStatus(inquiryId, newStatus);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Obtener color según estado
  String getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return '#FFA726';
      case 'En proceso':
        return '#42A5F5';
      case 'Completada':
        return '#66BB6A';
      case 'Cancelada':
        return '#EF5350';
      default:
        return '#9E9E9E';
    }
  }

  /// Obtener ícono según estado
  String getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return '⏳';
      case 'En proceso':
        return '🔄';
      case 'Completada':
        return '✅';
      case 'Cancelada':
        return '❌';
      default:
        return '📋';
    }
  }
}
