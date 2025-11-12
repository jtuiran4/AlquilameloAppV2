import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class EditPropertyController extends GetxController {
  final AgentController agentController = Get.find<AgentController>();
  late Property property;

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
  void onInit() {
    super.onInit();
    // Obtener la propiedad de los argumentos
    property = Get.arguments as Property;
    _loadPropertyData();
  }

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

  /// Cargar datos de la propiedad
  void _loadPropertyData() {
    titleController.text = property.title;
    descriptionController.text = property.description;
    priceController.text = property.price.toString();
    locationController.text = property.location;
    areaController.text = property.area.toString();
    bedroomsController.text = property.bedrooms.toString();
    bathroomsController.text = property.bathrooms.toString();
    selectedType.value = property.type;
    selectedAction.value = property.action;
    selectedImages.value = property.imageUrls.isNotEmpty 
        ? property.imageUrls.toList() 
        : [property.imageUrl];
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

  /// Actualizar propiedad
  Future<void> updateProperty() async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      final updatedData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'location': locationController.text.trim(),
        'area': double.tryParse(areaController.text.trim()) ?? 0.0,
        'bedrooms': int.tryParse(bedroomsController.text.trim()) ?? 0,
        'bathrooms': int.tryParse(bathroomsController.text.trim()) ?? 0,
        'type': selectedType.value,
        'action': selectedAction.value,
        'imageUrl': selectedImages.first,
        'imageUrls': selectedImages.toList(),
      };

      await agentController.updateProperty(property.id, updatedData);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Propiedad actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la propiedad: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
