import 'package:flutter/material.dart';
import '../services/agent_service.dart';
import '../models/app_models.dart';
import 'AddPropertyScreen.dart';
import 'EditPropertyScreen.dart';

class AgentPropertiesScreen extends StatefulWidget {
  const AgentPropertiesScreen({super.key});

  @override
  State<AgentPropertiesScreen> createState() => _AgentPropertiesScreenState();
}

class _AgentPropertiesScreenState extends State<AgentPropertiesScreen> {
  final AgentService _agentService = AgentService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todas';

  final List<String> _filters = ['Todas', 'Arriendo', 'Venta', 'Activas', 'Inactivas'];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    _agentService.getAgentProperties().listen((properties) {
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar propiedades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  List<Property> get _filteredProperties {
    switch (_selectedFilter) {
      case 'Arriendo':
        return _properties.where((p) => p.action == 'Arriendo').toList();
      case 'Venta':
        return _properties.where((p) => p.action == 'Venta').toList();
      case 'Activas':
        return _properties.where((p) => p.isActive).toList();
      case 'Inactivas':
        return _properties.where((p) => !p.isActive).toList();
      default:
        return _properties;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _loadProperties(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProperty,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: primary.withValues(alpha: 0.2),
                      checkmarkColor: primary,
                      labelStyle: TextStyle(
                        color: isSelected ? primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Estadísticas rápidas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total', 
                    _properties.length.toString(),
                    Icons.home,
                    primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Activas', 
                    _properties.where((p) => p.isActive).length.toString(),
                    Icons.visibility,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Inactivas', 
                    _properties.where((p) => !p.isActive).length.toString(),
                    Icons.visibility_off,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de propiedades
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primary),
                  )
                : _filteredProperties.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredProperties.length,
                        itemBuilder: (context, index) {
                          final property = _filteredProperties[index];
                          return _buildPropertyCard(property);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    const primary = Color(0xFFF88245);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen y estado
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: property.imageUrl.startsWith('http') 
                    ? Image.network(
                        property.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      )
                    : Image.asset(
                        property.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: property.action == 'Arriendo' ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: property.isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.isActive ? 'Activa' : 'Inactiva',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Información
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  property.priceFormatted,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeature(Icons.bed, '${property.bedrooms}'),
                    const SizedBox(width: 12),
                    _buildFeature(Icons.bathtub, '${property.bathrooms}'),
                    const SizedBox(width: 12),
                    _buildFeature(Icons.square_foot, '${property.area}m²'),
                    const Spacer(),
                    _buildActionButtons(property),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Property property) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      onSelected: (action) => _handlePropertyAction(property, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                property.isActive ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: property.isActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(property.isActive ? 'Desactivar' : 'Activar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.blue),
              SizedBox(width: 12),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    const primary = Color(0xFFF88245);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_outlined,
              size: 64,
              color: primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'Todas' 
                ? 'No tienes propiedades aún'
                : 'No hay propiedades en esta categoría',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Todas' 
                ? 'Comienza agregando tu primera propiedad'
                : 'Intenta con otro filtro',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (_selectedFilter == 'Todas') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addProperty,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Propiedad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addProperty() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPropertyScreen(),
      ),
    );
    
    if (result == true) {
      _loadProperties(); // Recargar la lista
    }
  }

  Future<void> _handlePropertyAction(Property property, String action) async {
    switch (action) {
      case 'toggle':
        await _togglePropertyStatus(property);
        break;
      case 'edit':
        await _editProperty(property);
        break;
      case 'delete':
        await _deleteProperty(property);
        break;
    }
  }

  Future<void> _togglePropertyStatus(Property property) async {
    try {
      await _agentService.togglePropertyActive(property.id, !property.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              property.isActive 
                  ? 'Propiedad desactivada' 
                  : 'Propiedad activada',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar propiedad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editProperty(Property property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(property: property),
      ),
    );
    
    if (result == true) {
      _loadProperties(); // Recargar la lista si se actualizó la propiedad
    }
  }

  Future<void> _deleteProperty(Property property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _agentService.deleteProperty(property.id);
        _loadProperties(); // Recargar la lista
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Propiedad eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar propiedad: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}