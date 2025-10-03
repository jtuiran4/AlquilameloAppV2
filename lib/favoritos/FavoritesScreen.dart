import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/property_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService _propertyService = PropertyService();
  
  // Lista de propiedades favoritas (simulando datos guardados)
  List<Property> _favoriteProperties = [
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
      agentId: '1',
      isFavorite: true,
    ),
    Property(
      id: '5',
      title: 'Penthouse en Envigado',
      description: 'Lujoso penthouse con terraza privada y jacuzzi',
      price: 1200000000,
      action: 'Venta',
      type: 'Apartamento',
      bedrooms: 3,
      bathrooms: 3,
      area: 200,
      location: 'Envigado, Antioquia',
      imageUrl: 'assets/hotel_room.jpg',
      agentId: '2',
      isFavorite: true,
    ),
    Property(
      id: '7',
      title: 'Apartamento Vista al Mar',
      description: 'Hermoso apartamento con vista panorámica al océano',
      price: 650000000,
      action: 'Venta',
      type: 'Apartamento',
      bedrooms: 2,
      bathrooms: 2,
      area: 95,
      location: 'Cartagena, Bolívar',
      imageUrl: 'assets/hotel2.jpg',
      agentId: '3',
      isFavorite: true,
    ),
  ];

  String _selectedFilter = 'Todos';

  List<Property> get _filteredFavorites {
    if (_selectedFilter == 'Todos') {
      return _favoriteProperties;
    }
    return _favoriteProperties.where((property) => property.action == _selectedFilter).toList();
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
            Image.asset(
              'assets/alquilamelologo.png',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home, size: 28, color: Colors.white);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Mis Favoritos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            color: primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Tarjeta de estadísticas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        icon: Icons.favorite,
                        count: _favoriteProperties.length.toString(),
                        label: 'Total Favoritos',
                        color: Colors.red,
                      ),
                      _buildStatCard(
                        icon: Icons.home_work,
                        count: _favoriteProperties.where((p) => p.action == 'Venta').length.toString(),
                        label: 'En Venta',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        icon: Icons.key,
                        count: _favoriteProperties.where((p) => p.action == 'Arriendo').length.toString(),
                        label: 'En Arriendo',
                        color: primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                // Filtros
                if (_favoriteProperties.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip('Todos', _selectedFilter == 'Todos'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterChip('Venta', _selectedFilter == 'Venta'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterChip('Arriendo', _selectedFilter == 'Arriendo'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Lista de favoritos con Firebase
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: _propertyService.getFavoriteProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF88245),
                    ),
                  );
                }

                List<Property> favoriteProperties;
                bool isUsingFallback = false;

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  // Usar datos de fallback
                  favoriteProperties = _favoriteProperties;
                  isUsingFallback = true;
                } else {
                  favoriteProperties = snapshot.data!;
                }

                // Aplicar filtros
                List<Property> filteredFavorites = _selectedFilter == 'Todos'
                    ? favoriteProperties
                    : favoriteProperties.where((property) => property.action == _selectedFilter).toList();

                return Column(
                  children: [
                    if (isUsingFallback)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        color: Colors.orange.shade100,
                        child: Text(
                          '⚠️ Usando datos locales - Firebase no disponible',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Estadísticas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.favorite,
                              count: favoriteProperties.length.toString(),
                              label: 'Total',
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.sell,
                              count: favoriteProperties.where((p) => p.action == 'Venta').length.toString(),
                              label: 'Venta',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.home_work,
                              count: favoriteProperties.where((p) => p.action == 'Arriendo').length.toString(),
                              label: 'Arriendo',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lista de favoritos
                    Expanded(
                      child: favoriteProperties.isEmpty
                          ? _buildEmptyState()
                          : filteredFavorites.isEmpty
                              ? _buildEmptyFilterState()
                              : RefreshIndicator(
                                  onRefresh: _refreshFavorites,
                                  color: primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(20),
                                    itemCount: filteredFavorites.length,
                                    itemBuilder: (context, index) {
                                      final property = filteredFavorites[index];
                                      return _buildFavoriteCard(property, index);
                                    },
                                  ),
                                ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    const primary = Color(0xFFF88245);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: primary, width: 2) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? primary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Property property, int index) {
    const primary = Color(0xFFF88245);
    
    return Dismissible(
      key: Key(property.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              'Eliminar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) => _confirmRemoveFavorite(property),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Agregado hace ${index + 1} día${index == 0 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                  
                  // Precio y botones
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
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _shareProperty(property),
                            icon: const Icon(Icons.share, size: 16),
                            label: const Text('Compartir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.grey.shade700,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _contactAgent(property),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Contactar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Aún no tienes favoritos!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Explora nuestras propiedades y marca las que más te gusten como favoritas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Propiedades'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF88245),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              'No hay favoritos en "$_selectedFilter"',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Intenta con otros filtros para ver tus propiedades favoritas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
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

  Future<bool?> _confirmRemoveFavorite(Property property) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar de favoritos?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar "${property.title}" de tus favoritos?'),
            const SizedBox(height: 10),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              _removeFavorite(property);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _removeFavorite(Property property) {
    setState(() {
      _favoriteProperties.removeWhere((p) => p.id == property.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${property.title}" eliminado de favoritos'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _favoriteProperties.add(property);
            });
          },
        ),
      ),
    );
  }

  void _shareProperty(Property property) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo "${property.title}"...'),
        backgroundColor: const Color(0xFFF88245),
      ),
    );
  }

  void _contactAgent(Property property) {
    Navigator.pushNamed(
      context, 
      '/agent-contact',
      arguments: {'property': property},
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtrar por',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Todos'),
              trailing: _selectedFilter == 'Todos' ? const Icon(Icons.check, color: Color(0xFFF88245)) : null,
              onTap: () {
                setState(() => _selectedFilter = 'Todos');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_work),
              title: const Text('En Venta'),
              trailing: _selectedFilter == 'Venta' ? const Icon(Icons.check, color: Color(0xFFF88245)) : null,
              onTap: () {
                setState(() => _selectedFilter = 'Venta');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('En Arriendo'),
              trailing: _selectedFilter == 'Arriendo' ? const Icon(Icons.check, color: Color(0xFFF88245)) : null,
              onTap: () {
                setState(() => _selectedFilter = 'Arriendo');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshFavorites() async {
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favoritos actualizados'),
        backgroundColor: Color(0xFFF88245),
      ),
    );
  }
}