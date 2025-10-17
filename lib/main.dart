import 'package:flutter/material.dart';

import 'package:alquilamelo_app/AlquilameloApp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed silently
  }
  
  runApp(const AlquilameloApp());
}
