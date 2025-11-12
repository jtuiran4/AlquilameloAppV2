import 'package:get/get.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/entities.dart';
import 'package:alquilamelo_app/features/shared/domain/usecases/property_usecases.dart';

class PropertyController extends GetxController {
  // Use cases
  late final GetPropertiesUseCase _getPropertiesUseCase;
  late final GetPropertyByIdUseCase _getPropertyByIdUseCase;
  late final GetPropertiesByAgentUseCase _getPropertiesByAgentUseCase;
  late final GetFavoritePropertiesUseCase _getFavoritePropertiesUseCase;
  late final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  late final IsFavoriteUseCase _isFavoriteUseCase;
  late final IncrementPropertyViewsUseCase _incrementViewsUseCase;
  late final GetRecentPropertiesUseCase _getRecentPropertiesUseCase;
  late final GetFeaturedPropertiesUseCase _getFeaturedPropertiesUseCase;

  // Estado reactivo
  final RxList<Property> properties = <Property>[].obs;
  final RxList<Property> favoriteProperties = <Property>[].obs;
  final RxList<Property> recentProperties = <Property>[].obs;
  final RxList<Property> featuredProperties = <Property>[].obs;
  final Rx<Property?> currentProperty = Rx<Property?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingProperty = false.obs;
  final RxBool isLoadingFavorites = false.obs;
  final RxString error = ''.obs;

  // Filtros
  final RxString searchQuery = ''.obs;
  final RxString selectedAction = ''.obs;
  final RxString selectedType = ''.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = double.maxFinite.obs;
  final RxInt minBedrooms = 0.obs;
  final RxInt maxBedrooms = 10.obs;
  final RxString selectedLocation = ''.obs;

  // Inicializar use cases
  void init({
    required GetPropertiesUseCase getPropertiesUseCase,
    required GetPropertyByIdUseCase getPropertyByIdUseCase,
    required GetPropertiesByAgentUseCase getPropertiesByAgentUseCase,
    required GetFavoritePropertiesUseCase getFavoritePropertiesUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required IsFavoriteUseCase isFavoriteUseCase,
    required IncrementPropertyViewsUseCase incrementViewsUseCase,
    required GetRecentPropertiesUseCase getRecentPropertiesUseCase,
    required GetFeaturedPropertiesUseCase getFeaturedPropertiesUseCase,
  }) {
    _getPropertiesUseCase = getPropertiesUseCase;
    _getPropertyByIdUseCase = getPropertyByIdUseCase;
    _getPropertiesByAgentUseCase = getPropertiesByAgentUseCase;
    _getFavoritePropertiesUseCase = getFavoritePropertiesUseCase;
    _toggleFavoriteUseCase = toggleFavoriteUseCase;
    _isFavoriteUseCase = isFavoriteUseCase;
    _incrementViewsUseCase = incrementViewsUseCase;
    _getRecentPropertiesUseCase = getRecentPropertiesUseCase;
    _getFeaturedPropertiesUseCase = getFeaturedPropertiesUseCase;
  }

  // Cargar propiedades con filtros
  Future<void> loadProperties({
    bool showLoading = true,
    int limit = 20,
    int offset = 0,
  }) async {
    if (showLoading) {
      isLoading.value = true;
    }
    error.value = '';

    try {
      final result = await _getPropertiesUseCase.execute(
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        action: selectedAction.value.isEmpty ? null : selectedAction.value,
        type: selectedType.value.isEmpty ? null : selectedType.value,
        minPrice: minPrice.value == 0 ? null : minPrice.value,
        maxPrice: maxPrice.value == double.maxFinite ? null : maxPrice.value,
        minBedrooms: minBedrooms.value == 0 ? null : minBedrooms.value,
        maxBedrooms: maxBedrooms.value == 10 ? null : maxBedrooms.value,
        location: selectedLocation.value.isEmpty ? null : selectedLocation.value,
        limit: limit,
        offset: offset,
      );

      if (offset == 0) {
        properties.value = result;
      } else {
        properties.addAll(result);
      }
    } catch (e) {
      error.value = e.toString();
      properties.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Cargar propiedad específica
  Future<void> loadProperty(String propertyId) async {
    isLoadingProperty.value = true;
    error.value = '';

    try {
      final property = await _getPropertyByIdUseCase.execute(propertyId);
      currentProperty.value = property;

      // Incrementar vistas si la propiedad existe
      if (property != null) {
        await _incrementViewsUseCase.execute(propertyId);
      }
    } catch (e) {
      error.value = e.toString();
      currentProperty.value = null;
    } finally {
      isLoadingProperty.value = false;
    }
  }

  // Cargar propiedades por agente
  Future<void> loadPropertiesByAgent(String agentId) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _getPropertiesByAgentUseCase.execute(agentId);
      properties.value = result;
    } catch (e) {
      error.value = e.toString();
      properties.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Cargar propiedades favoritas
  Future<void> loadFavoriteProperties(String userId) async {
    isLoadingFavorites.value = true;
    error.value = '';

    try {
      final result = await _getFavoritePropertiesUseCase.execute(userId);
      favoriteProperties.value = result;
    } catch (e) {
      error.value = e.toString();
      favoriteProperties.clear();
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  // Toggle favorito
  Future<void> toggleFavorite(String userId, String propertyId, bool isCurrentlyFavorite) async {
    try {
      await _toggleFavoriteUseCase.execute(userId, propertyId, !isCurrentlyFavorite);

      // Actualizar la propiedad en la lista si existe
      final index = properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        final updatedProperty = properties[index].copyWith(isFavorite: !isCurrentlyFavorite);
        properties[index] = updatedProperty;
      }

      // Recargar favoritos si estamos viendo esa lista
      if (favoriteProperties.isNotEmpty) {
        await loadFavoriteProperties(userId);
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

  // Verificar si es favorito
  Future<bool> isPropertyFavorite(String userId, String propertyId) async {
    try {
      return await _isFavoriteUseCase.execute(userId, propertyId);
    } catch (e) {
      return false;
    }
  }

  // Cargar propiedades recientes
  Future<void> loadRecentProperties({int limit = 10}) async {
    try {
      final result = await _getRecentPropertiesUseCase.execute(limit: limit);
      recentProperties.value = result;
    } catch (e) {
      error.value = e.toString();
      recentProperties.clear();
    }
  }

  // Cargar propiedades destacadas
  Future<void> loadFeaturedProperties({int limit = 5}) async {
    try {
      final result = await _getFeaturedPropertiesUseCase.execute(limit: limit);
      featuredProperties.value = result;
    } catch (e) {
      error.value = e.toString();
      featuredProperties.clear();
    }
  }

  // Limpiar filtros
  void clearFilters() {
    searchQuery.value = '';
    selectedAction.value = '';
    selectedType.value = '';
    minPrice.value = 0.0;
    maxPrice.value = double.maxFinite;
    minBedrooms.value = 0;
    maxBedrooms.value = 10;
    selectedLocation.value = '';
  }

  // Aplicar filtros y recargar
  void applyFilters() {
    loadProperties();
  }

  // Limpiar estado
  void clearState() {
    properties.clear();
    favoriteProperties.clear();
    recentProperties.clear();
    featuredProperties.clear();
    currentProperty.value = null;
    error.value = '';
    clearFilters();
  }
}