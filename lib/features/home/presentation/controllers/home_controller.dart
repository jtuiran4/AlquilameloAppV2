import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/property_service_legacy.dart';

class HomeController extends GetxController {
  final PropertyService _propertyService = PropertyService();
  StreamSubscription<List<Property>>? _propertiesSubscription;
  
  // Controladores de texto
  final searchController = TextEditingController();
  
  // Estado observable
  final RxList<Property> allProperties = <Property>[].obs;
  final RxList<Property> filteredProperties = <Property>[].obs;
  final RxString selectedPropertyType = 'Todos'.obs;
  final RxString selectedPriceRange = 'Todos'.obs;
  final RxString selectedAction = 'Todos'.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt currentNavIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadProperties();
    
    // Escuchar cambios en la búsqueda
    searchController.addListener(_applyFilters);
  }

  @override
  void onClose() {
    _propertiesSubscription?.cancel();
    super.onClose();
  }

  /// Cargar propiedades desde Firestore
  void _loadProperties() {
    isLoading.value = true;
    error.value = '';
    
    _propertiesSubscription = _propertyService.getAllPropertiesSimple().listen(
      (properties) {
        if (!isClosed) {
          allProperties.value = properties;
          _applyFilters();
          isLoading.value = false;
        }
      },
      onError: (e) {
        if (!isClosed) {
          error.value = e.toString();
          isLoading.value = false;
        }
      },
    );
  }

  /// Aplicar filtros a las propiedades
  void _applyFilters() {
    final searchText = searchController.text.toLowerCase();
    
    filteredProperties.value = allProperties.where((property) {
      final matchesSearch = property.title.toLowerCase().contains(searchText) ||
                           property.location.toLowerCase().contains(searchText);
      final matchesType = selectedPropertyType.value == 'Todos' || 
                         property.type == selectedPropertyType.value;
      final matchesAction = selectedAction.value == 'Todos' || 
                           property.action == selectedAction.value;
      
      return matchesSearch && matchesType && matchesAction;
    }).toList();
  }

  /// Cambiar tipo de propiedad
  void setPropertyType(String type) {
    selectedPropertyType.value = type;
    _applyFilters();
  }

  /// Cambiar rango de precio
  void setPriceRange(String range) {
    selectedPriceRange.value = range;
    _applyFilters();
  }

  /// Cambiar acción (Venta/Arriendo)
  void setAction(String action) {
    selectedAction.value = action;
    _applyFilters();
  }

  /// Verificar si una propiedad es favorita
  Future<bool> isFavorite(String propertyId) async {
    return await _propertyService.isFavorite(propertyId);
  }

  /// Toggle favorito
  Future<void> toggleFavorite(String propertyId) async {
    try {
      await _propertyService.toggleFavorite(propertyId);
      final isFav = await _propertyService.isFavorite(propertyId);
      
      Get.snackbar(
        isFav ? 'Agregado a favoritos' : 'Removido de favoritos',
        '',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: isFav ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar favoritos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Cambiar índice de navegación
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        Get.toNamed('/favorites');
        break;
      case 2:
        Get.toNamed('/profile');
        break;
    }
  }

  /// Navegar a detalle de propiedad
  void navigateToPropertyDetail(Property property) {
    // La navegación se maneja directamente en la vista
  }
}
