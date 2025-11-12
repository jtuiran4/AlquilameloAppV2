import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class AddPropertyController extends GetxController {
  final AgentController agentController = Get.find<AgentController>();

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final areaController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();

  // Estado observable
  final RxString selectedType = 'Casa'.obs;
  final RxString selectedAction = 'Venta'.obs;
  final RxList<String> selectedImages = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    areaController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    super.onClose();
  }

  /// Cambiar tipo de propiedad
  void setPropertyType(String type) {
    selectedType.value = type;
  }

  /// Cambiar acción (Venta/Arriendo)
  void setAction(String action) {
    selectedAction.value = action;
  }

  /// Agregar imagen
  void addImage(String imageUrl) {
    selectedImages.add(imageUrl);
  }

  /// Remover imagen
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  /// Validar formulario
  bool validateForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El título es requerido');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'La descripción es requerida');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El precio es requerido');
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      Get.snackbar('Error', 'La ubicación es requerida');
      return false;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar('Error', 'Debes agregar al menos una imagen');
      return false;
    }
    return true;
  }

  /// Guardar propiedad
  Future<void> saveProperty() async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      final property = Property(
        id: '', // Se generará en el repositorio
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text.trim()),
        location: locationController.text.trim(),
        area: double.tryParse(areaController.text.trim()) ?? 0.0,
        bedrooms: int.tryParse(bedroomsController.text.trim()) ?? 0,
        bathrooms: int.tryParse(bathroomsController.text.trim()) ?? 0,
        type: selectedType.value,
        action: selectedAction.value,
        imageUrl: selectedImages.first,
        imageUrls: selectedImages.toList(),
        agentId: '', // Se obtendrá del usuario actual
      );

      await agentController.addProperty(property);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Propiedad agregada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar la propiedad: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar formulario
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    locationController.clear();
    areaController.clear();
    bedroomsController.clear();
    bathroomsController.clear();
    selectedType.value = 'Casa';
    selectedAction.value = 'Venta';
    selectedImages.clear();
  }
}
