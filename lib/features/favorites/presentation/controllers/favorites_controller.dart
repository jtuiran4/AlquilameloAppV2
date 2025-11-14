import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/property_service_legacy.dart';

class FavoritesController extends GetxController {
  final PropertyService _propertyService = PropertyService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<List<Property>>? _favoritesSubscription;

  // Estado observable
  final RxList<Property> favoriteProperties = <Property>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // Getters
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  @override
  void onInit() {
    super.onInit();
    if (isAuthenticated) {
      _loadFavorites();
    }
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    super.onClose();
  }

  /// Cargar propiedades favoritas
  void _loadFavorites() {
    isLoading.value = true;
    error.value = '';
    
    _favoritesSubscription = _propertyService.getFavoriteProperties().listen(
      (properties) {
        if (!isClosed) {
          favoriteProperties.value = properties;
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

  /// Remover propiedad de favoritos
  Future<void> removeFromFavorites(String propertyId) async {
    try {
      await _propertyService.removeFromFavorites(propertyId);
      // La lista se actualiza automáticamente por el stream
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar de favoritos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Incrementar contador de vistas
  void incrementViewCount(String propertyId) {
    _propertyService.incrementViewCount(propertyId);
  }

  /// Navegar a detalle de propiedad
  /// Nota: La navegación se maneja directamente en la vista usando Get.to()

  /// Volver atrás
  void goBack() {
    Get.back();
  }

  /// Navegar al login
  void navigateToLogin() {
    Get.toNamed('/login');
  }
}
