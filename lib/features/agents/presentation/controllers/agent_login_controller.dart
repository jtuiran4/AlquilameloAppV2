import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgentLoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Estado observable
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle visibilidad de contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validar formulario
  bool validateForm() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El email es requerido');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Email inválido');
      return false;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'La contraseña es requerida');
      return false;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    return true;
  }

  /// Iniciar sesión
  Future<void> login() async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.offAllNamed('/agent-dashboard');
      Get.snackbar(
        'Éxito',
        'Bienvenido de vuelta',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        message = 'No existe una cuenta con este email';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else if (e.code == 'user-disabled') {
        message = 'Esta cuenta ha sido deshabilitada';
      }
      
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navegar a registro
  void navigateToRegister() {
    Get.toNamed('/agent-register');
  }

  /// Recuperar contraseña
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingresa tu email para recuperar la contraseña');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Email inválido');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar(
        'Éxito',
        'Se ha enviado un email para restablecer tu contraseña',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar el email: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
