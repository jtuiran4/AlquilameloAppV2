import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';

class AgentPropertiesScreen extends StatelessWidget {
  const AgentPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agentController = Get.find<AgentController>();
    const primary = Color(0xFFF88245);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Propiedades',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/add-property'),
            icon: const Icon(Icons.add),
            tooltip: 'Agregar Propiedad',
          ),
        ],
      ),
      body: Obx(() => _buildContent(agentController)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-property'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(AgentController agentController) {
    if (agentController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final properties = agentController.agentProperties;

    if (properties.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(property, agentController);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getFilters().map((filter) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _isFilterSelected(filter),
                      onSelected: (selected) {
                        // TODO: Implement filter logic in controller
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getFilters() {
    return ['Todas', 'Activas', 'Inactivas', 'Alquiladas'];
  }

  bool _isFilterSelected(String filter) {
    // TODO: Implement filter selection logic
    return filter == 'Todas';
  }

  Widget _buildPropertyCard(Property property, AgentController agentController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property.allImages.isNotEmpty ? property.allImages.first : '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),

          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.isActive ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property.isActive ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          color: property.isActive ? Colors.green.shade800 : Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${property.price.toStringAsFixed(0)} / mes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF88245),
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed('/edit-property', arguments: property),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFF88245),
                          side: BorderSide(color: Color(0xFFF88245)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _togglePropertyStatus(property, agentController),
                        icon: Icon(property.isActive ? Icons.visibility_off : Icons.visibility),
                        label: Text(property.isActive ? 'Desactivar' : 'Activar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: property.isActive ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteProperty(property, agentController),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes propiedades registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera propiedad para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/add-property'),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Propiedad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF88245),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePropertyStatus(Property property, AgentController agentController) async {
    try {
      await agentController.togglePropertyActive(property.id, !property.isActive);
      Get.snackbar(
        'Éxito',
        'Estado de la propiedad actualizado correctamente',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado de la propiedad',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _deleteProperty(Property property, AgentController agentController) async {
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Eliminar Propiedad',
      middleText: '¿Estás seguro de que deseas eliminar esta propiedad? Esta acción no se puede deshacer.',
      textConfirm: 'Eliminar',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirmed == true) {
      try {
        await agentController.deleteProperty(property.id);
        Get.snackbar(
          'Éxito',
          'Propiedad eliminada correctamente',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'No se pudo eliminar la propiedad',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    }
  }
}
