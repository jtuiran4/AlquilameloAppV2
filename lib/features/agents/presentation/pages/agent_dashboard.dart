import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alquilamelo_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_controller.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final agentController = Get.find<AgentController>();

    const primary = Color(0xFFF88245);

    return Obx(() {
      // Check if user is authenticated
      if (!authController.isAuthenticated.value) {
        return _buildLoginPrompt(primary);
      }

      // Check if user is agent
      return FutureBuilder<bool>(
        future: agentController.isCurrentUserAgent(),
        builder: (context, isAgentSnapshot) {
          if (isAgentSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen(primary);
          }

          if (isAgentSnapshot.data != true) {
            // If user is authenticated but not an agent, sign out
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await authController.signOut();
              Get.offAllNamed('/login');
            });

            return _buildLoadingScreen(primary);
          }

          return _buildAgentDashboard(agentController, primary);
        },
      );
    });
  }

  Widget _buildLoginPrompt(Color primary) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text('Panel de Agente'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Inicia sesión para acceder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Accede al panel de agentes para gestionar tus propiedades',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(Color primary) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text('Panel de Agente'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildAgentDashboard(AgentController agentController, Color primary) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Panel de Agente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final agent = agentController.currentAgent.value;
        final stats = agentController.agentStats.value;

        if (agent == null) {
          return const Center(
            child: Text('Error al cargar perfil del agente'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header del agente
              Container(
                color: primary,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: primary.withValues(alpha: 0.1),
                        child: Text(
                          agent.name.isNotEmpty
                              ? agent.name[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        agent.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.home_work,
                            value: stats.totalProperties.toString(),
                            label: 'Propiedades',
                            color: Colors.blue,
                          ),
                          _buildStatItem(
                            icon: Icons.message,
                            value: stats.totalInquiries.toString(),
                            label: 'Consultas',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Acciones rápidas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.add_home,
                            title: 'Agregar\nPropiedad',
                            color: primary,
                            onTap: () => Get.toNamed('/add-property'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.home_work,
                            title: 'Mis\nPropiedades',
                            color: Colors.blue,
                            onTap: () => Get.toNamed('/agent-properties'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.message,
                            title: 'Consultas',
                            color: Colors.green,
                            onTap: () => Get.toNamed('/agent-inquiries'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Gestión de cuenta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.manage_accounts,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text(
                          'Gestionar Cuenta',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Cambiar contraseña o eliminar cuenta'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showAccountManagementDialog(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                        ),
                        title: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Salir de tu cuenta de agente'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountManagementDialog() {
    Get.defaultDialog(
      title: 'Gestionar Cuenta',
      content: const Text('¿Qué acción deseas realizar?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            _showChangePasswordDialog();
          },
          child: const Text('Cambiar Contraseña'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            _showDeleteAccountDialog();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar Cuenta'),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.defaultDialog(
      title: 'Cambiar Contraseña',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña actual',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nueva contraseña',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar nueva contraseña',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (newPasswordController.text != confirmPasswordController.text) {
              Get.snackbar(
                'Error',
                'Las contraseñas no coinciden',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
            
            if (newPasswordController.text.length < 6) {
              Get.snackbar(
                'Error',
                'La contraseña debe tener al menos 6 caracteres',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            try {
              Get.back();
              // Reautenticar y cambiar contraseña
              final user = FirebaseAuth.instance.currentUser;
              final credential = EmailAuthProvider.credential(
                email: user!.email!,
                password: currentPasswordController.text,
              );
              await user.reauthenticateWithCredential(credential);
              await user.updatePassword(newPasswordController.text);

              Get.snackbar(
                'Éxito',
                'Contraseña cambiada exitosamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: const Text('Cambiar'),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();

    Get.defaultDialog(
      title: 'Eliminar Cuenta',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⚠️ Esta acción eliminará permanentemente tu cuenta y todos tus datos. Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirma tu contraseña',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              Get.back();
              final user = FirebaseAuth.instance.currentUser;
              final credential = EmailAuthProvider.credential(
                email: user!.email!,
                password: passwordController.text,
              );
              await user.reauthenticateWithCredential(credential);
              await user.delete();

              Get.offAllNamed('/login');
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar Cuenta', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'Cerrar Sesión',
      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            // Limpiar datos de usuario al cerrar sesión
            final authController = Get.find<AuthController>();
            await authController.signOut();
            Get.offAllNamed('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cerrar Sesión'),
        ),
      ],
    );
  }
}