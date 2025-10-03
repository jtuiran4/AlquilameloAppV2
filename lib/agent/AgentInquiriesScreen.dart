import 'package:flutter/material.dart';
import '../services/agent_service.dart';
import '../models/app_models.dart';

class AgentInquiriesScreen extends StatefulWidget {
  const AgentInquiriesScreen({super.key});

  @override
  State<AgentInquiriesScreen> createState() => _AgentInquiriesScreenState();
}

class _AgentInquiriesScreenState extends State<AgentInquiriesScreen> {
  final AgentService _agentService = AgentService();
  List<PropertyInquiry> _inquiries = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todas';

  final List<String> _filters = ['Todas', 'Pendientes', 'En Progreso', 'Completadas'];

  @override
  void initState() {
    super.initState();
    _loadInquiries();
  }

  Future<void> _loadInquiries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _agentService.getAgentInquiries().listen((inquiries) {
        if (mounted) {
          setState(() {
            _inquiries = inquiries;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar consultas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<PropertyInquiry> get _filteredInquiries {
    switch (_selectedFilter) {
      case 'Pendientes':
        return _inquiries.where((i) => i.status == 'pending').toList();
      case 'En Progreso':
        return _inquiries.where((i) => i.status == 'in_progress').toList();
      case 'Completadas':
        return _inquiries.where((i) => i.status == 'completed').toList();
      default:
        return _inquiries;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFF88245);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Consultas de Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _loadInquiries,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: primary.withValues(alpha: 0.2),
                      checkmarkColor: primary,
                      labelStyle: TextStyle(
                        color: isSelected ? primary : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Estadísticas rápidas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total', 
                    _inquiries.length.toString(),
                    Icons.message,
                    primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pendientes', 
                    _inquiries.where((i) => i.status == 'pending').length.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'En Progreso', 
                    _inquiries.where((i) => i.status == 'in_progress').length.toString(),
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completadas', 
                    _inquiries.where((i) => i.status == 'completed').length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de consultas
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primary),
                  )
                : _filteredInquiries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredInquiries.length,
                        itemBuilder: (context, index) {
                          final inquiry = _filteredInquiries[index];
                          return _buildInquiryCard(inquiry);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(PropertyInquiry inquiry) {
    const primary = Color(0xFFF88245);
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (inquiry.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'En Progreso';
        statusIcon = Icons.work;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completada';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con usuario y estado
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.1),
                  child: Text(
                    inquiry.userName.isNotEmpty 
                        ? inquiry.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry.userName.isNotEmpty 
                            ? inquiry.userName 
                            : 'Usuario',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        inquiry.userEmail.isNotEmpty 
                            ? inquiry.userEmail 
                            : 'Sin email',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (inquiry.userPhone.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              inquiry.userPhone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de la propiedad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Propiedad consultada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inquiry.propertyTitle.isNotEmpty 
                        ? inquiry.propertyTitle 
                        : 'Consulta general',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (inquiry.propertyLocation.isNotEmpty)
                    Text(
                      inquiry.propertyLocation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensaje del usuario
            if (inquiry.message.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.message_outlined, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Mensaje',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  inquiry.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            

            
            // Footer con fecha y acciones
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDate(inquiry.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (inquiry.status != 'completed')
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (action) => _handleInquiryAction(inquiry, action),
                    itemBuilder: (context) => [
                      if (inquiry.status == 'pending')
                        const PopupMenuItem(
                          value: 'in_progress',
                          child: Row(
                            children: [
                              Icon(Icons.work, size: 20, color: Colors.blue),
                              SizedBox(width: 12),
                              Text('Marcar en Progreso'),
                            ],
                          ),
                        ),
                      if (inquiry.status != 'completed')
                        const PopupMenuItem(
                          value: 'completed',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 20, color: Colors.green),
                              SizedBox(width: 12),
                              Text('Marcar Completada'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'contact',
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 20, color: primary),
                            const SizedBox(width: 12),
                            const Text('Contactar'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    const primary = Color(0xFFF88245);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.message_outlined,
              size: 64,
              color: primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'Todas' 
                ? 'No tienes consultas aún'
                : 'No hay consultas en esta categoría',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Todas' 
                ? 'Las consultas de los usuarios aparecerán aquí'
                : 'Intenta con otro filtro',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Ahora';
    }
  }

  Future<void> _handleInquiryAction(PropertyInquiry inquiry, String action) async {
    switch (action) {
      case 'in_progress':
        await _updateInquiryStatus(inquiry, 'in_progress');
        break;
      case 'completed':
        await _updateInquiryStatus(inquiry, 'completed');
        break;
      case 'contact':
        await _contactUser(inquiry);
        break;
    }
  }

  Future<void> _updateInquiryStatus(PropertyInquiry inquiry, String newStatus) async {
    try {
      await _agentService.updateInquiryStatus(inquiry.id, newStatus);
      
      String statusText;
      switch (newStatus) {
        case 'in_progress':
          statusText = 'marcada en progreso';
          break;
        case 'completed':
          statusText = 'marcada como completada';
          break;
        default:
          statusText = 'actualizada';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consulta $statusText'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar consulta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _contactUser(PropertyInquiry inquiry) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${inquiry.userName.isNotEmpty ? inquiry.userName : "Usuario"}'),
            const SizedBox(height: 8),
            Text('Email: ${inquiry.userEmail.isNotEmpty ? inquiry.userEmail : "No proporcionado"}'),
            if (inquiry.userPhone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Teléfono: ${inquiry.userPhone}'),
            ],
          ],
        ),
        actions: [
          if (inquiry.userPhone.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _makePhoneCall(inquiry.userPhone);
              },
              icon: const Icon(Icons.phone),
              label: const Text('Llamar'),
            ),
          if (inquiry.userEmail.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendEmail(inquiry.userEmail);
              },
              icon: const Icon(Icons.email),
              label: const Text('Email'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // En una implementación real, aquí usarías url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a $phoneNumber...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Copiar',
          textColor: Colors.white,
          onPressed: () {
            // Aquí podrías copiar al clipboard
          },
        ),
      ),
    );
  }

  void _sendEmail(String email) {
    // En una implementación real, aquí usarías url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviando email a $email...'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Copiar',
          textColor: Colors.white,
          onPressed: () {
            // Aquí podrías copiar al clipboard
          },
        ),
      ),
    );
  }
}