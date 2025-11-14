import 'package:get/get.dart';
import 'package:alquilamelo_app/features/favorites/presentation/controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
  }
}
