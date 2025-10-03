import 'package:flutter/material.dart';
import '../models/app_models.dart';

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

  // Agente por defecto
  late Agent _currentAgent;
  Property? _property;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener argumentos de la ruta
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _property = arguments?['property'] as Property?;
    final agent = arguments?['agent'] as Agent?;
    
    _currentAgent = agent ?? Agent.defaultAgent();
    
    // Mensaje predeterminado si hay una propiedad
    if (_property != null && _messageController.text.isEmpty) {
      _messageController.text = 
          'Hola, estoy interesado en la propiedad "${_property!.title}" ubicada en ${_property!.location}. '
          'Me gustaría recibir más información y agendar una cita para visitarla.';
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/alquilamelologo.png',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home, size: 28, color: Colors.white);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Contactar Agente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
                    backgroundColor: primary.withOpacity(0.1),
                    backgroundImage: _currentAgent.photoUrl.isNotEmpty 
                        ? AssetImage(_currentAgent.photoUrl) 
                        : null,
                    child: _currentAgent.photoUrl.isEmpty 
                        ? Icon(Icons.person, size: 50, color: primary)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  
                  // Nombre del agente
                  Text(
                    _currentAgent.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Cargo
                  Text(
                    _currentAgent.position,
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
                      _buildAgentStat(Icons.star, '${_currentAgent.rating}', 'Rating'),
                      _buildAgentStat(Icons.home_work, '${_currentAgent.propertiesSold}', 'Vendidas'),
                      _buildAgentStat(Icons.access_time, '${_currentAgent.yearsExperience}', 'Años Exp.'),
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
                          child: Image.asset(
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
                    
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico *',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
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
                        onPressed: _acceptTerms ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text(
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

  Widget _buildContactButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF88245),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(15),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
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

  void _showContactDialog(String method, String contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$method del agente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Deseas contactar por $method?'),
            const SizedBox(height: 10),
            Text(
              contact,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF88245),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Abriendo $method...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF88245),
              foregroundColor: Colors.white,
            ),
            child: Text('Abrir $method'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simular envío del formulario
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
                'Tu solicitud ha sido enviada a ${_currentAgent.name}.',
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
  }
}

