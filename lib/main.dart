import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alquilamelo_app/AlquilameloApp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/app_state_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kDebugMode) {
      print('🔥 Inicializando Firebase para plataforma: ${kIsWeb ? 'Web' : 'Mobile'}');
    }
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      print('✅ Firebase inicializado correctamente');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error al inicializar Firebase: $e');
    }
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStateService(),
      child: const AlquilameloApp(),
    ),
  );
}
