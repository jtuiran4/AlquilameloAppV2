import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/property_service.dart';
import '../services/firebase_data_seeder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPropertyType = 'Todos';
  String _selectedPriceRange = 'Todos';
  String _selectedAction = 'Todos';
  final PropertyService _propertyService = PropertyService();
  final FirebaseDataSeeder _dataSeeder = FirebaseDataSeeder();

  @override
  void initState() {
    super.initState();
    // Inicializar datos de Firebase si es necesario
    _initializeFirebaseData();
  }

  Future<void> _initializeFirebaseData() async {
    try {
      await _dataSeeder.seedInitialData();
    } catch (e) {
      print('Error al inicializar datos de Firebase: $e');
    }
  }

  // Datos de ejemplo de propiedades (como fallback)
  final List<Property> _fallbackProperties = [
    Property(
      id: '1',
      title: 'Apartamento Moderno en El Poblado',
      description: 'Hermoso apartamento de 2 habitaciones con vista panorámica',
      price: 450000000,
      action: 'Venta',
      type: 'Apartamento',
      bedrooms: 2,
      bathrooms: 2,
      area: 85,
      location: 'El Poblado, Medellín',
      imageUrl: 'assets/hotel_room.jpg',
      agentId: '1',
      isFavorite: false,
    ),
    Property(
      id: '2',
      title: 'Casa Familiar en Laureles',
      description: 'Casa de 3 pisos con jardín privado y garaje para 2 carros',
      price: 2500000,
      action: 'Arriendo',
      type: 'Casa',
      bedrooms: 4,
      bathrooms: 3,
      area: 180,
      location: 'Laureles, Medellín',
      imageUrl: 'assets/hotel.png',
      agentId: '2',
      isFavorite: true,
    ),
    Property(
      id: '3',
      title: 'Apartaestudio en Sabaneta',
      description: 'Moderno apartaestudio completamente amoblado',
      price: 1800000,
      action: 'Arriendo',
      type: 'Apartamento',
      bedrooms: 1,
      bathrooms: 1,
      area: 45,
      location: 'Sabaneta, Antioquia',
      imageUrl: 'assets/hotel2.jpg',
      agentId: '3',
      isFavorite: false,
    ),
    Property(
      id: '4',
      title: 'Casa Campestre en La Ceja',
      description: 'Hermosa casa campestre con piscina y zona verde',
      price: 850000000,
      action: 'Venta',
      type: 'Casa',
      bedrooms: 5,
      bathrooms: 4,
      area: 350,
      location: 'La Ceja, Antioquia',
      imageUrl: 'assets/hotel_room.jpg',
      agentId: '1',
      isFavorite: false,
    ),
  ];

  List<Property> _filterProperties(List<Property> properties) {
    return properties.where((property) {
      bool matchesSearch = property.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                          property.location.toLowerCase().contains(_searchController.text.toLowerCase());
      bool matchesType = _selectedPropertyType == 'Todos' || property.type == _selectedPropertyType;
      bool matchesAction = _selectedAction == 'Todos' || property.action == _selectedAction;
      
      return matchesSearch && matchesType && matchesAction;
    }).toList();
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            const Text(
              'Alquílamelo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
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
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Acción', _selectedAction, ['Todos', 'Venta', 'Arriendo'], (value) {
                        setState(() => _selectedAction = value);
                      }),
                      const SizedBox(width: 10),
                      _buildFilterChip('Tipo', _selectedPropertyType, ['Todos', 'Casa', 'Apartamento'], (value) {
                        setState(() => _selectedPropertyType = value);
                      }),
                      const SizedBox(width: 10),
                      _buildFilterChip('Precio', _selectedPriceRange, ['Todos', 'Bajo', 'Medio', 'Alto'], (value) {
                        setState(() => _selectedPriceRange = value);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de propiedades
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: _propertyService.getAllPropertiesSimple(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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

                if (snapshot.hasError) {
                  print('Error en Firebase: ${snapshot.error}');
                  // Usar datos de fallback en caso de error
                  final filteredProperties = _filterProperties(_fallbackProperties);
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error de conexión con Firebase. Mostrando datos de ejemplo.',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildPropertiesList(filteredProperties, true)),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Mostrar datos de fallback mientras se cargan los datos de Firebase
                  final filteredProperties = _filterProperties(_fallbackProperties);
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No hay propiedades en Firebase. Inicializando datos...',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildPropertiesList(filteredProperties, true)),
                    ],
                  );
                }

                // Usar datos de Firebase exitosamente
                final filteredProperties = _filterProperties(snapshot.data!);
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_done, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '🔥 Conectado a Firebase - ${snapshot.data!.length} propiedades',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _buildPropertiesList(filteredProperties, false)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en Home
              break;
            case 1:
              // Navegar a Favoritos
              Navigator.of(context).pushNamed('/favorites');
              break;
            case 2:
              // Navegar a Perfil
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
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
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, List<String> options, Function(String) onSelected) {
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

  Widget _buildPropertyCard(Property property) {
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
          // Imagen de la propiedad
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  property.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
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
              Positioned(
                top: 10,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      property.isFavorite = !property.isFavorite;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      property.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: property.isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
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
                    ElevatedButton(
                      onPressed: () {
                        // Navegar a detalles de la propiedad
                        _showPropertyDetails(property);
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

  void _showPropertyDetails(Property property) {
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          property.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            );
                          },
                        ),
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

  Widget _buildPropertiesList(List<Property> properties, bool isUsingFallback) {
    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron propiedades',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (isUsingFallback) ...[
              const SizedBox(height: 8),
              Text(
                'Usando datos de ejemplo (sin conexión a Firebase)',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isUsingFallback)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.orange.shade100,
            child: Text(
              '⚠️ Usando datos de ejemplo - Firebase no disponible',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(property);
            },
          ),
        ),
      ],
    );
  }
}

