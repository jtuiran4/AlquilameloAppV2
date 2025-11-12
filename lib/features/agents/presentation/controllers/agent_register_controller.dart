import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class AgentRegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AgentController agentController = Get.find<AgentController>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final licenseController = TextEditingController();

  // Estado observable
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool acceptedTerms = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    licenseController.dispose();
    super.onClose();
  }

  /// Toggle visibilidad de contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle visibilidad de confirmar contraseña
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Toggle aceptar términos
  void toggleAcceptTerms() {
    acceptedTerms.value = !acceptedTerms.value;
  }

  /// Validar formulario
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre es requerido');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El email es requerido');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Email inválido');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El teléfono es requerido');
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
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Las contraseñas no coinciden');
      return false;
    }
    if (!acceptedTerms.value) {
      Get.snackbar('Error', 'Debes aceptar los términos y condiciones');
      return false;
    }
    return true;
  }

  /// Registrar agente
  Future<void> register() async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      // Crear usuario en Firebase Auth
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Crear perfil de agente
      await agentController.createAgentProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        position: licenseController.text.trim(), // Licencia como posición
      );

      Get.offAllNamed('/agent-dashboard');
      Get.snackbar(
        'Éxito',
        '¡Bienvenido! Tu cuenta ha sido creada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrar';
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ya existe una cuenta con este email';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
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

  /// Navegar a login
  void navigateToLogin() {
    Get.back();
  }
}
