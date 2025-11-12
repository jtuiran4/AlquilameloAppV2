import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alquilamelo_app/core/routes.dart';

class AlquilameloApp extends StatelessWidget {
  const AlquilameloApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF88245);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alquílamelo',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
    );
  }
}
