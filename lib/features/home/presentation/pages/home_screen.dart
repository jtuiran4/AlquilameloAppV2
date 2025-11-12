import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart';
import 'package:alquilamelo_app/features/shared/presentation/widgets/property_image_carousel.dart';
import 'package:alquilamelo_app/features/home/presentation/controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    const primary = Color(0xFFF88245);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de Alquílamelo con llave blanca
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/alquilamelologo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sección de búsqueda y filtros
          Container(
            color: primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Barra de búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ubicación o nombre...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Filtros horizontales
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        controller, 
                        'Acción', 
                        controller.selectedAction.value, 
                        ['Todos', 'Venta', 'Arriendo'], 
                        controller.setAction,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        controller,
                        'Tipo', 
                        controller.selectedPropertyType.value, 
                        ['Todos', 'Casa', 'Apartamento'], 
                        controller.setPropertyType,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        controller,
                        'Precio', 
                        controller.selectedPriceRange.value, 
                        ['Todos', 'Bajo', 'Medio', 'Alto'], 
                        controller.setPriceRange,
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          // Lista de propiedades
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFFF88245),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cargando propiedades...',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🔥 Conectando con Firebase',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return _buildEmptyState(
                  'Error de conexión',
                  'No se pudieron cargar las propiedades desde Firebase. Verifica tu conexión a internet.',
                  Icons.error_outline,
                  Colors.red,
                );
              }

              if (controller.allProperties.isEmpty) {
                return _buildEmptyState(
                  'No hay propiedades disponibles',
                  'Aún no hay propiedades registradas en la plataforma. ¡Pronto tendremos muchas opciones para ti!',
                  Icons.home_outlined,
                  const Color(0xFFF88245),
                );
              }

              if (controller.filteredProperties.isEmpty) {
                return _buildEmptyState(
                  'No se encontraron resultados',
                  'No hay propiedades que coincidan con tus filtros de búsqueda. Intenta ajustar los criterios.',
                  Icons.search_off,
                  Colors.grey,
                );
              }
              
              return _buildPropertiesList(controller, controller.filteredProperties);
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentNavIndex.value,
        onTap: controller.changeNavIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      )),
    );
  }

  Widget _buildFilterChip(
    HomeController controller,
    String label, 
    String selectedValue, 
    List<String> options, 
    Function(String) onSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: (value) => onSelected(value!),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          dropdownColor: Colors.white,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$label: $option',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(HomeController controller, Property property) {
    const primary = Color(0xFFF88245);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la propiedad con carrusel
          Stack(
            children: [
              PropertyImageCarousel(
                property: property,
                height: 200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              // Etiqueta de acción (Venta/Arriendo)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: property.action == 'Venta' ? Colors.green : primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Botón de favoritos
              Positioned(
                top: 10,
                left: 10,
                child: FutureBuilder<bool>(
                  future: controller.isFavorite(property.id),
                  builder: (context, snapshot) {
                    bool isFavorite = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => controller.toggleFavorite(property.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Información de la propiedad
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Características
                Row(
                  children: [
                    _buildFeature(Icons.bed, '${property.bedrooms}'),
                    const SizedBox(width: 16),
                    _buildFeature(Icons.bathroom, '${property.bathrooms}'),
                    const SizedBox(width: 16),
                    _buildFeature(Icons.square_foot, '${property.area}m²'),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Precio y botón
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrice(property.price),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        if (property.action == 'Arriendo')
                          Text(
                            '/mes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () {
                          // Navegar a detalles de la propiedad
                          _showPropertyDetails(context, property);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Ver más'),
                      ),
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

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  void _showPropertyDetails(BuildContext context, Property property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PropertyImageCarousel(
                        property: property,
                        height: 250,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatPrice(property.price) + (property.action == 'Arriendo' ? '/mes' : ''),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF88245),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailFeature(Icons.bed, 'Habitaciones', '${property.bedrooms}'),
                          _buildDetailFeature(Icons.bathroom, 'Baños', '${property.bathrooms}'),
                          _buildDetailFeature(Icons.square_foot, 'Área', '${property.area}m²'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFF88245)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context, 
                              '/agent-contact',
                              arguments: {'property': property},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF88245),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Contactar Agente',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailFeature(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: const Color(0xFFF88245)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesList(HomeController controller, List<Property> properties) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(controller, properties[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Método para toggle de favoritos
}

