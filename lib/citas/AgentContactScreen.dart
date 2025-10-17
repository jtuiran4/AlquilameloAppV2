import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import '../services/user_service.dart';

class AgentContactScreen extends StatefulWidget {
  const AgentContactScreen({super.key});

  @override
  State<AgentContactScreen> createState() => _AgentContactScreenState();
}

class _AgentContactScreenState extends State<AgentContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedContactMethod = 'WhatsApp';
  String _selectedTimePreference = 'Mañana';
  bool _acceptTerms = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Agente y servicios
  Agent? _currentAgent;
  Property? _property;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // Obtener argumentos de la ruta
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _property = arguments?['property'] as Property?;
    
    // Pre-llenar datos del usuario autenticado
    await _prefillUserData();
    
    if (_property != null) {
      await _loadAgentData(_property!.agentId);
      
      // Mensaje predeterminado si hay una propiedad
      if (_messageController.text.isEmpty) {
        _messageController.text = 
            'Hola, estoy interesado en la propiedad "${_property!.title}" ubicada en ${_property!.location}. '
            'Me gustaría recibir más información y agendar una cita para visitarla.';
      }
    } else {
      // Si no hay propiedad, mostrar mensaje de error
      setState(() {
        _currentAgent = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _prefillUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userProfileStream = _userService.getUserProfile();
        final userProfile = await userProfileStream.first;
        if (userProfile != null) {
          setState(() {
            if (userProfile.name.isNotEmpty && _nameController.text.isEmpty) {
              _nameController.text = userProfile.name;
            }
            if (userProfile.email.isNotEmpty && _emailController.text.isEmpty) {
              _emailController.text = userProfile.email;
            }
            if (userProfile.phone.isNotEmpty && _phoneController.text.isEmpty) {
              _phoneController.text = userProfile.phone;
            }
          });
        }
      } catch (e) {
        // Error silenciado
      }
    }
  }

  Future<void> _loadAgentData(String agentId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final agentDoc = await _firestore
          .collection('agents')
          .doc(agentId)
          .get();

      if (agentDoc.exists) {
        setState(() {
          _currentAgent = Agent.fromFirestore(agentDoc.data()!, agentDoc.id);
          _isLoading = false;
        });
      } else {
        // Si no se encuentra el agente, mostrar error
        setState(() {
          _currentAgent = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error al cargar agente
      setState(() {
        _currentAgent = null;
        _isLoading = false;
      });
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
          'Contactar Agente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : _currentAgent == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Agente no disponible',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No se pudo cargar la información del agente para esta propiedad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Información del agente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Foto del agente
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 50, color: primary),
                  ),
                  const SizedBox(height: 15),
                  
                  // Nombre del agente
                  Text(
                    _currentAgent!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Cargo
                  Text(
                    _currentAgent!.position,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Estadísticas del agente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAgentStat(Icons.person, _currentAgent!.name, 'Nombre'),
                      _buildAgentStat(Icons.home_work, '${_currentAgent!.propertiesSold}', 'Vendidas'),
                      _buildAgentStat(Icons.work, _currentAgent!.position, 'Cargo'),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Información de la propiedad (si existe)
            if (_property != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Propiedad de Interés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _property!.imageUrl.startsWith('http')
                              ? Image.network(
                                  _property!.imageUrl,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.asset(
                                  _property!.imageUrl,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _property!.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _property!.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(_property!.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Formulario de contacto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitar Información',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Método de contacto preferido
                    const Text(
                      'Método de contacto preferido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ['WhatsApp', 'Llamada', 'Email'].map((method) {
                        return ChoiceChip(
                          label: Text(method),
                          selected: _selectedContactMethod == method,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedContactMethod = method);
                            }
                          },
                          selectedColor: primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedContactMethod == method ? primary : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    
                    // Horario preferido
                    const Text(
                      'Horario preferido para contacto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ['Mañana', 'Tarde', 'Noche'].map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          selected: _selectedTimePreference == time,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedTimePreference = time);
                            }
                          },
                          selectedColor: primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedTimePreference == time ? primary : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    
                    // Mensaje
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mensaje adicional',
                        hintText: 'Cuéntanos sobre tu interés en la propiedad...',
                        prefixIcon: const Icon(Icons.message_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Checkbox términos
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() => _acceptTerms = value ?? false);
                          },
                          activeColor: primary,
                        ),
                        const Expanded(
                          child: Text(
                            'Acepto los términos y condiciones y autorizo el tratamiento de mis datos personales.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Botón enviar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_acceptTerms && !_isSubmitting) ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Enviar Solicitud',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                ],
              ),
            ),
    );
  }

  Widget _buildAgentStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF88245), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        String userId = currentUser?.uid ?? 'anonymous';
        String userName = _nameController.text.trim();
        String userEmail = _emailController.text.trim();
        String userPhone = _phoneController.text.trim();

        // Si hay usuario autenticado, obtener su información
        if (currentUser != null) {
          try {
            final userProfileStream = _userService.getUserProfile();
            final userProfile = await userProfileStream.first;
            if (userProfile != null) {
              userName = userProfile.name.isNotEmpty ? userProfile.name : userName;
              userEmail = userProfile.email.isNotEmpty ? userProfile.email : userEmail;
              userPhone = userProfile.phone.isNotEmpty ? userProfile.phone : userPhone;
            }
          } catch (e) {
            // Error silenciado
          }
        }

        // Crear consulta en Firestore
        final inquiry = PropertyInquiry(
          id: '', // Se asignará automáticamente
          propertyId: _property?.id ?? '',
          propertyTitle: _property?.title ?? 'Consulta general',
          propertyLocation: _property?.location ?? '',
          userId: userId,
          userName: userName,
          userEmail: userEmail,
          userPhone: userPhone,
          agentId: _currentAgent!.id,
          message: _messageController.text.trim(),
          status: 'pending',
          createdAt: DateTime.now(),
        );

        await _firestore.collection('contacts').add(inquiry.toFirestore());

        // Incrementar contador de propiedades contactadas en el perfil del usuario
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            await _firestore.collection('users').doc(currentUser.uid).update({
              'statistics.contactedAgents': FieldValue.increment(1),
            });
          }
        } catch (e) {
          // No bloquear la experiencia de usuario si falla la actualización de estadísticas
        }

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          // Mostrar diálogo de éxito
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¡Solicitud Enviada!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Tu solicitud ha sido enviada a ${_currentAgent!.name}.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Te contactaremos por $_selectedContactMethod en el horario $_selectedTimePreference.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a la pantalla anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF88245),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar la solicitud: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

