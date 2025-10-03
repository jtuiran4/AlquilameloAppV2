import 'package:alquilamelo_app/auth/LoginScreen.dart';
import 'package:alquilamelo_app/auth/RegisterScreen.dart';
import 'package:alquilamelo_app/citas/AgentContactScreen.dart';
import 'package:alquilamelo_app/favoritos/FavoritesScreen.dart';
import 'package:alquilamelo_app/home/HomeScreen.dart';
import 'package:alquilamelo_app/user/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:alquilamelo_app/SplashScreen.dart';

class AlquilameloApp extends StatelessWidget {
  const AlquilameloApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF88245); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alquílamelo',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        fontFamily: 'Roboto', 
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/agent-contact': (context) => const AgentContactScreen(),
        },
    );

  }
  }
