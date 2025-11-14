import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alquilamelo_app/core/routes.dart';
import 'package:alquilamelo_app/features/agents/data/datasources/agent_service_legacy.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  final AgentService _agentService = AgentService();
  bool _isLoading = true;
  bool _isAgent = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.agentLogin);
      });
      return;
    }

    // Verificar si es agente
    final isAgent = await _agentService.isCurrentUserAgent();
    
    if (!isAgent) {
      await FirebaseAuth.instance.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.agentLogin);
      });
      return;
    }

    setState(() {
      _isAgent = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF88245);

    if (_isLoading) {
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

    if (!_isAgent) {
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
                  'Acceso denegado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No tienes permisos de agente',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.agentLogin),
                  icon: const Icon(Icons.login),
                  label: const Text('Ir a Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Información del agente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
                    if (user == null) return const SizedBox.shrink();
                    
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFF88245).withOpacity(0.1),
                          child: Text(
                            user.displayName?.isNotEmpty == true
                                ? user.displayName![0].toUpperCase()
                                : user.email![0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF88245),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.displayName ?? 'Agente',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  },
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
                  const Text(
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
                          onTap: () => Get.toNamed(AppRoutes.addProperty),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.home_work,
                          title: 'Mis\nPropiedades',
                          color: Colors.blue,
                          onTap: () => Get.toNamed(AppRoutes.agentProperties),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.message,
                          title: 'Consultas',
                          color: Colors.green,
                          onTap: () => Get.toNamed(AppRoutes.agentInquiries),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
              color: Colors.black.withOpacity(0.05),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
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
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.agentLogin);
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
