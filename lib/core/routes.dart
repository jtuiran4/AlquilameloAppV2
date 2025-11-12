import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alquilamelo_app/features/home/presentation/pages/home_screen.dart';
import 'package:alquilamelo_app/features/auth/presentation/pages/login_screen.dart';
import 'package:alquilamelo_app/features/auth/presentation/pages/register_screen.dart';
import 'package:alquilamelo_app/features/agents/presentation/pages/add_property_screen.dart';
import 'package:alquilamelo_app/features/agents/presentation/pages/edit_property_screen.dart';
import 'package:alquilamelo_app/features/agents/presentation/pages/agent_properties_screen.dart';
import 'package:alquilamelo_app/features/favorites/presentation/pages/favorites_screen.dart';
import 'package:alquilamelo_app/features/user/presentation/pages/profile_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String addProperty = '/add-property';
  static const String editProperty = '/edit-property';
  static const String agentProperties = '/agent-properties';

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: addProperty,
      page: () => const AddPropertyScreen(),
    ),
    GetPage(
      name: editProperty,
      page: () => EditPropertyScreen(property: Get.arguments),
    ),
    GetPage(
      name: agentProperties,
      page: () => const AgentPropertiesScreen(),
    ),
  ];
}

// Pantalla de splash temporal
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí iría la lógica para determinar si el usuario está logueado
    // Por ahora, vamos directo al home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(AppRoutes.home);
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}