import 'package:flutter/material.dart';

import 'package:alquilamelo_app/core/alquilamelo_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart';
import 'core/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  await SharedPreferencesService.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed silently
  }

  // Inicializar inyección de dependencias
  await DependencyInjection.init();

  runApp(const AlquilameloApp());
}