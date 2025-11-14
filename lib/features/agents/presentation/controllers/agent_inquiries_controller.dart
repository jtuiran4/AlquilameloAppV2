import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart';
import 'package:alquilamelo_app/features/agents/data/datasources/agent_service_legacy.dart';

class AgentInquiriesController extends GetxController {
  final AgentService _agentService = AgentService();
  StreamSubscription<List<PropertyInquiry>>? _inquiriesSubscription;

  // Estado observable
  final RxList<PropertyInquiry> allInquiries = <PropertyInquiry>[].obs;
  final RxList<PropertyInquiry> filteredInquiries = <PropertyInquiry>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'Todas'.obs;

  final List<String> filters = ['Todas', 'Pendientes', 'En Progreso', 'Completadas'];

  @override
  void onInit() {
    super.onInit();
    _loadInquiries();
  }

  @override
  void onClose() {
    _inquiriesSubscription?.cancel();
    super.onClose();
  }

  /// Cargar consultas
  void _loadInquiries() {
    isLoading.value = true;
    
    _inquiriesSubscription = _agentService.getAgentInquiries().listen(
      (inquiries) {
        if (!isClosed) {
          allInquiries.value = inquiries;
          _applyFilter();
          isLoading.value = false;
        }
      },
      onError: (e) {
        if (!isClosed) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Error al cargar consultas: $e',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
    );
  }

  /// Aplicar filtro
  void _applyFilter() {
    switch (selectedFilter.value) {
      case 'Pendientes':
        filteredInquiries.value = allInquiries.where((i) => i.status == 'pending').toList();
        break;
      case 'En Progreso':
        filteredInquiries.value = allInquiries.where((i) => i.status == 'in_progress').toList();
        break;
      case 'Completadas':
        filteredInquiries.value = allInquiries.where((i) => i.status == 'completed').toList();
        break;
      default:
        filteredInquiries.value = allInquiries.toList();
    }
  }

  /// Cambiar filtro
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  /// Actualizar estado de consulta
  Future<void> updateInquiryStatus(String inquiryId, String newStatus, {String? resolutionNotes}) async {
    try {
      await _agentService.updateInquiryStatus(inquiryId, newStatus, resolutionNotes: resolutionNotes);
      Get.snackbar(
        'Éxito',
        'Estado actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Incrementar contador de ventas del agente
  Future<void> incrementAgentSales(String agentId) async {
    try {
      await _agentService.incrementAgentSales(agentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Refrescar consultas
  @override
  void refresh() {
    _loadInquiries();
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
