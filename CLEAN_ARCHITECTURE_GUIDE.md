# Guía de Clean Architecture - AlquilameloApp

## 📋 Tabla de Contenidos
- [Introducción](#introducción)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Capas de la Arquitectura](#capas-de-la-arquitectura)
- [Flujo de Datos](#flujo-de-datos)
- [Implementación con GetX](#implementación-con-getx)
- [Ejemplos Prácticos](#ejemplos-prácticos)
- [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Introducción

**Clean Architecture** es un patrón de diseño que separa el código en capas independientes, facilitando el mantenimiento, testing y escalabilidad. En AlquilameloApp, implementamos una versión adaptada con **GetX** como gestor de estado.

### Principios Fundamentales

1. **Separación de responsabilidades**: Cada capa tiene un propósito específico
2. **Independencia de frameworks**: La lógica de negocio no depende de Flutter o GetX
3. **Testeable**: Cada capa puede probarse de forma aislada
4. **Independencia de la UI**: La lógica de negocio no conoce la presentación
5. **Independencia de la base de datos**: Los datos pueden cambiar sin afectar la lógica

---

## 📁 Estructura del Proyecto

```
lib/
├── core/                           # Configuración global
│   ├── routes.dart                # Rutas de la aplicación
│   └── theme/                     # Temas y estilos
│
├── features/                       # Features organizadas por funcionalidad
│   ├── agents/                    # Feature de Agentes
│   │   ├── data/                  # CAPA DE DATOS
│   │   │   └── datasources/
│   │   │       └── agent_service_legacy.dart
│   │   │
│   │   ├── domain/                # CAPA DE DOMINIO (No implementada actualmente)
│   │   │   ├── entities/          # Modelos puros de negocio
│   │   │   ├── repositories/      # Interfaces de repositorios
│   │   │   └── usecases/          # Casos de uso
│   │   │
│   │   └── presentation/          # CAPA DE PRESENTACIÓN
│   │       ├── bindings/          # Inyección de dependencias (GetX)
│   │       ├── controllers/       # Lógica de UI (GetX Controllers)
│   │       └── pages/             # Pantallas (Widgets)
│   │
│   ├── home/
│   ├── favorites/
│   └── shared/
│       └── domain/
│           └── entities/
│               └── app_models_legacy.dart  # Modelos compartidos
│
└── services/                       # Servicios globales (legacy)
```

---

## 🏗️ Capas de la Arquitectura

### 1️⃣ Capa de Presentación (Presentation Layer)

**Responsabilidad**: Mostrar la UI y capturar interacciones del usuario

#### Componentes:

**a) Pages/Screens** - `pages/`
- Widgets de Flutter que definen la UI
- No contienen lógica de negocio
- Escuchan cambios del Controller con `Obx`
- Ejemplo: `agent_inquiries_screen.dart`

```dart
class AgentInquiriesScreen extends GetView<AgentInquiriesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(
        itemCount: controller.filteredInquiries.length,
        itemBuilder: (context, index) => _buildCard(index),
      )),
    );
  }
}
```

**b) Controllers** - `controllers/`
- Gestionan el estado de la UI
- Llaman a los services/repositories
- Transforman datos para la vista
- Manejan la lógica de presentación
- Ejemplo: `agent_inquiries_controller.dart`

```dart
class AgentInquiriesController extends GetxController {
  final AgentService _agentService = AgentService();
  
  final RxList<PropertyInquiry> allInquiries = <PropertyInquiry>[].obs;
  final RxString selectedFilter = 'Todas'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadInquiries();
  }
  
  void _loadInquiries() {
    _agentService.getAgentInquiries().listen((inquiries) {
      allInquiries.value = inquiries;
      _applyFilter();
    });
  }
  
  Future<void> updateInquiryStatus(String id, String status) async {
    await _agentService.updateInquiryStatus(id, status);
  }
}
```

**c) Bindings** - `bindings/`
- Inyección de dependencias
- Inicializan controllers cuando se navega a una pantalla
- Ejemplo: `agent_inquiries_binding.dart`

```dart
class AgentInquiriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentInquiriesController>(
      () => AgentInquiriesController(),
      fenix: true, // Mantiene el controller en memoria
    );
  }
}
```

---

### 2️⃣ Capa de Dominio (Domain Layer)

**Responsabilidad**: Contiene la lógica de negocio pura, sin dependencias externas

#### Componentes:

**a) Entities** - `domain/entities/`
- Modelos de datos puros
- No dependen de nada (ni Firebase, ni Flutter)
- Representan conceptos del negocio
- Ejemplo: `app_models_legacy.dart`

```dart
class PropertyInquiry {
  final String id;
  final String propertyId;
  final String message;
  final String status;
  final DateTime createdAt;
  final String? resolutionNotes;
  final DateTime? completedAt;

  PropertyInquiry({
    required this.id,
    required this.propertyId,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.resolutionNotes,
    this.completedAt,
  });
}
```

**b) Use Cases** (No implementado actualmente)
- Orquesta la lógica de negocio
- Cada caso de uso = una acción del usuario
- Ejemplo conceptual:

```dart
// features/agents/domain/usecases/complete_inquiry_usecase.dart
class CompleteInquiryUseCase {
  final InquiryRepository repository;
  
  CompleteInquiryUseCase(this.repository);
  
  Future<void> call({
    required String inquiryId,
    required String resolutionNotes,
    bool wasSuccessful = true,
  }) async {
    // Validaciones de negocio
    if (resolutionNotes.isEmpty) {
      throw Exception('Las notas de resolución son obligatorias');
    }
    
    // Ejecutar lógica
    await repository.updateInquiry(
      inquiryId,
      status: 'completed',
      resolutionNotes: resolutionNotes,
      completedAt: DateTime.now(),
    );
    
    // Si fue exitosa, incrementar contador
    if (wasSuccessful) {
      await repository.incrementAgentSales();
    }
  }
}
```

**c) Repositories** (Interfaces - No implementado actualmente)
- Contratos que define cómo acceder a los datos
- No implementa, solo define
- Ejemplo conceptual:

```dart
// features/agents/domain/repositories/inquiry_repository.dart
abstract class InquiryRepository {
  Stream<List<PropertyInquiry>> getInquiries();
  Future<void> updateInquiry(String id, {required String status});
  Future<void> incrementAgentSales();
}
```

---

### 3️⃣ Capa de Datos (Data Layer)

**Responsabilidad**: Obtener y guardar datos (Firebase, APIs, cache, etc.)

#### Componentes:

**a) Data Sources** - `data/datasources/`
- Implementación concreta de acceso a datos
- Interactúa con Firebase, APIs, local storage
- Transforma datos externos a entidades del dominio
- Ejemplo: `agent_service_legacy.dart`

```dart
class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener consultas del agente (Stream en tiempo real)
  Stream<List<PropertyInquiry>> getAgentInquiries() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('contacts')
        .where('agentId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<PropertyInquiry> inquiries = [];
          
          // Ordenar manualmente
          var docs = snapshot.docs.toList();
          docs.sort((a, b) {
            final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bTime.compareTo(aTime);
          });

          for (var doc in docs) {
            final data = doc.data();
            // Usar fromFirestore para parsear todos los campos
            inquiries.add(PropertyInquiry.fromFirestore(data, doc.id));
          }

          return inquiries;
        });
  }

  // Actualizar estado de consulta
  Future<void> updateInquiryStatus(
    String inquiryId, 
    String status, 
    {String? resolutionNotes}
  ) async {
    Map<String, dynamic> updateData = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'completed') {
      updateData['completedAt'] = FieldValue.serverTimestamp();
      if (resolutionNotes != null && resolutionNotes.isNotEmpty) {
        updateData['resolutionNotes'] = resolutionNotes;
      }
    }

    await _firestore
        .collection('contacts')
        .doc(inquiryId)
        .update(updateData);
  }

  // Incrementar ventas del agente
  Future<void> incrementAgentSales(String agentId) async {
    final agentRef = _firestore.collection('agents').doc(agentId);
    
    await _firestore.runTransaction((transaction) async {
      final agentDoc = await transaction.get(agentRef);
      
      if (!agentDoc.exists) {
        throw 'Agente no encontrado';
      }
      
      final currentSales = agentDoc.data()?['propertiesSold'] ?? 0;
      transaction.update(agentRef, {
        'propertiesSold': currentSales + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
```

**b) Models** (No implementado por separado actualmente)
- DTOs (Data Transfer Objects)
- Conversión entre formato de Firebase y entidades
- Ejemplo conceptual:

```dart
// data/models/inquiry_model.dart
class PropertyInquiryModel extends PropertyInquiry {
  PropertyInquiryModel({
    required super.id,
    required super.propertyId,
    required super.message,
    required super.status,
    required super.createdAt,
    super.resolutionNotes,
    super.completedAt,
  });

  // Desde Firestore
  factory PropertyInquiryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PropertyInquiryModel(
      id: id,
      propertyId: data['propertyId'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      resolutionNotes: data['resolutionNotes'],
      completedAt: data['completedAt']?.toDate(),
    );
  }

  // A Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolutionNotes': resolutionNotes,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
```

**c) Repositories Implementation** (No implementado actualmente)
- Implementa las interfaces definidas en el dominio
- Orquesta los data sources
- Ejemplo conceptual:

```dart
// data/repositories/inquiry_repository_impl.dart
class InquiryRepositoryImpl implements InquiryRepository {
  final AgentService _agentService;
  
  InquiryRepositoryImpl(this._agentService);
  
  @override
  Stream<List<PropertyInquiry>> getInquiries() {
    return _agentService.getAgentInquiries();
  }
  
  @override
  Future<void> updateInquiry(String id, {required String status}) async {
    await _agentService.updateInquiryStatus(id, status);
  }
  
  @override
  Future<void> incrementAgentSales() async {
    await _agentService.incrementAgentSales();
  }
}
```

---

## 🔄 Flujo de Datos

### Flujo Completo: Completar una Consulta

```
┌─────────────────────────────────────────────────────────────────┐
│                      1. INTERACCIÓN DEL USUARIO                  │
│                                                                   │
│  Usuario presiona "Completar" en agent_inquiries_screen.dart    │
│                         ↓                                         │
│             _updateInquiryStatus(inquiry, 'completed')           │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                    2. PRESENTACIÓN (UI Logic)                    │
│                                                                   │
│  AgentInquiriesScreen muestra diálogo con Get.dialog()          │
│  Usuario escribe: "Vendida: Se concretó la venta"               │
│  Presiona botón "Completar"                                      │
│                         ↓                                         │
│  controller.updateInquiryStatus(                                 │
│    inquiry.id,                                                   │
│    'completed',                                                  │
│    resolutionNotes: 'Vendida: Se concretó la venta'            │
│  )                                                               │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                   3. CONTROLLER (State Manager)                  │
│                                                                   │
│  AgentInquiriesController recibe el llamado                     │
│                         ↓                                         │
│  Future<void> updateInquiryStatus(                              │
│    String inquiryId,                                             │
│    String newStatus,                                             │
│    {String? resolutionNotes}                                     │
│  ) async {                                                       │
│    await _agentService.updateInquiryStatus(                     │
│      inquiryId, newStatus, resolutionNotes: resolutionNotes     │
│    );                                                            │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                   4. DATA SOURCE (Data Access)                   │
│                                                                   │
│  AgentService.updateInquiryStatus()                             │
│                         ↓                                         │
│  Map<String, dynamic> updateData = {                            │
│    'status': 'completed',                                        │
│    'updatedAt': FieldValue.serverTimestamp(),                   │
│    'completedAt': FieldValue.serverTimestamp(),                 │
│    'resolutionNotes': 'Vendida: Se concretó la venta'          │
│  };                                                              │
│                         ↓                                         │
│  await _firestore                                                │
│    .collection('contacts')                                       │
│    .doc(inquiryId)                                               │
│    .update(updateData);                                          │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                      5. FIREBASE FIRESTORE                       │
│                                                                   │
│  Documento actualizado en colección 'contacts':                 │
│  {                                                               │
│    id: "abc123",                                                 │
│    status: "completed",                                          │
│    resolutionNotes: "Vendida: Se concretó la venta",           │
│    completedAt: Timestamp(2025-01-13 10:30:00),                │
│    updatedAt: Timestamp(2025-01-13 10:30:00)                   │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│              6. ACTUALIZACIÓN REACTIVA (Real-time)               │
│                                                                   │
│  Firestore emite evento en el .snapshots() stream               │
│                         ↓                                         │
│  AgentService.getAgentInquiries() recibe la actualización       │
│                         ↓                                         │
│  Stream emite nueva lista con PropertyInquiry actualizado       │
│                         ↓                                         │
│  AgentInquiriesController.allInquiries.value se actualiza       │
│                         ↓                                         │
│  Obx() detecta cambio y reconstruye UI automáticamente          │
│                         ↓                                         │
│  UI muestra "Detalles de completado" con las notas             │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo con Incremento de Ventas

```
Usuario marca consulta como "Vendida"
         ↓
Screen captura el tipo de resolución
         ↓
if (outcome == 'Vendida') {
  await _incrementAgentSales(inquiry.agentId);
}
         ↓
controller.incrementAgentSales(agentId)
         ↓
_agentService.incrementAgentSales(agentId)
         ↓
Firestore Transaction:
  1. Lee documento del agente
  2. Obtiene currentSales = propertiesSold actual
  3. Actualiza propertiesSold = currentSales + 1
         ↓
Dashboard del agente muestra contador actualizado
```

---

## 🎯 Implementación con GetX

### Gestión de Estado

**Patrón GetView + Controller**

```dart
// Controller
class AgentInquiriesController extends GetxController {
  // Estados observables
  final RxList<PropertyInquiry> allInquiries = <PropertyInquiry>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'Todas'.obs;

  // Stream subscription
  StreamSubscription<List<PropertyInquiry>>? _inquiriesSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadInquiries();
  }

  @override
  void onClose() {
    _inquiriesSubscription?.cancel(); // Limpiar recursos
    super.onClose();
  }

  void _loadInquiries() {
    _inquiriesSubscription = _agentService.getAgentInquiries().listen(
      (inquiries) {
        if (!isClosed) {
          allInquiries.value = inquiries;
          isLoading.value = false;
        }
      },
    );
  }
}

// Screen
class AgentInquiriesScreen extends GetView<AgentInquiriesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: controller.filteredInquiries.length,
          itemBuilder: (context, index) {
            final inquiry = controller.filteredInquiries[index];
            return InquiryCard(inquiry: inquiry);
          },
        );
      }),
    );
  }
}
```

### Navegación con Bindings

```dart
// routes.dart
class AppRoutes {
  static const agentInquiries = '/agent-inquiries';
  
  static List<GetPage> routes = [
    GetPage(
      name: agentInquiries,
      page: () => const AgentInquiriesScreen(),
      binding: AgentInquiriesBinding(), // Inyecta controller
    ),
  ];
}

// Para navegar
Get.toNamed(AppRoutes.agentInquiries);
```

### Prevención de Disposal con fenix

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true, // Mantiene el controller en memoria
    );
  }
}
```

**¿Cuándo usar `fenix: true`?**
- Pantallas con formularios que no deben perder datos
- Pantallas que se visitan frecuentemente
- Pantallas con TextEditingControllers

---

## 📚 Ejemplos Prácticos

### Ejemplo 1: Crear un Nuevo Feature

Vamos a crear un feature de "Citas" (Appointments)

**1. Estructura de carpetas**

```
lib/features/appointments/
├── data/
│   └── datasources/
│       └── appointment_service.dart
├── domain/
│   ├── entities/
│   │   └── appointment.dart
│   ├── repositories/
│   │   └── appointment_repository.dart
│   └── usecases/
│       ├── get_appointments_usecase.dart
│       └── create_appointment_usecase.dart
└── presentation/
    ├── bindings/
    │   └── appointments_binding.dart
    ├── controllers/
    │   └── appointments_controller.dart
    └── pages/
        └── appointments_screen.dart
```

**2. Entity (Dominio)**

```dart
// domain/entities/appointment.dart
class Appointment {
  final String id;
  final String propertyId;
  final String agentId;
  final String userId;
  final DateTime scheduledDate;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;

  Appointment({
    required this.id,
    required this.propertyId,
    required this.agentId,
    required this.userId,
    required this.scheduledDate,
    this.status = 'pending',
    this.notes,
  });
}
```

**3. Repository Interface (Dominio)**

```dart
// domain/repositories/appointment_repository.dart
abstract class AppointmentRepository {
  Stream<List<Appointment>> getAgentAppointments();
  Future<void> createAppointment(Appointment appointment);
  Future<void> updateAppointmentStatus(String id, String status);
  Future<void> cancelAppointment(String id, String reason);
}
```

**4. Use Case (Dominio)**

```dart
// domain/usecases/create_appointment_usecase.dart
class CreateAppointmentUseCase {
  final AppointmentRepository repository;
  
  CreateAppointmentUseCase(this.repository);
  
  Future<void> call(Appointment appointment) async {
    // Validaciones de negocio
    if (appointment.scheduledDate.isBefore(DateTime.now())) {
      throw Exception('No se puede agendar en el pasado');
    }
    
    final now = DateTime.now();
    if (appointment.scheduledDate.difference(now).inHours < 2) {
      throw Exception('Debe agendar con al menos 2 horas de anticipación');
    }
    
    // Ejecutar
    await repository.createAppointment(appointment);
  }
}
```

**5. Data Source (Data)**

```dart
// data/datasources/appointment_service.dart
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Appointment>> getAgentAppointments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('appointments')
        .where('agentId', isEqualTo: currentUser.uid)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createAppointment(Appointment appointment) async {
    await _firestore
        .collection('appointments')
        .add(appointment.toFirestore());
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore
        .collection('appointments')
        .doc(id)
        .update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
```

**6. Controller (Presentación)**

```dart
// presentation/controllers/appointments_controller.dart
class AppointmentsController extends GetxController {
  final AppointmentService _service = AppointmentService();
  
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxBool isLoading = true.obs;
  
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _loadAppointments();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _loadAppointments() {
    isLoading.value = true;
    
    _subscription = _service.getAgentAppointments().listen(
      (data) {
        if (!isClosed) {
          appointments.value = data;
          isLoading.value = false;
        }
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'No se pudieron cargar las citas');
      },
    );
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      // Aquí usarías el use case en una implementación completa
      await _service.createAppointment(appointment);
      Get.snackbar('Éxito', 'Cita agendada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo agendar la cita');
    }
  }

  Future<void> confirmAppointment(String id) async {
    await _service.updateAppointmentStatus(id, 'confirmed');
  }
}
```

**7. Binding (Presentación)**

```dart
// presentation/bindings/appointments_binding.dart
class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentsController>(
      () => AppointmentsController(),
    );
  }
}
```

**8. Screen (Presentación)**

```dart
// presentation/pages/appointments_screen.dart
class AppointmentsScreen extends GetView<AppointmentsController> {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.appointments.isEmpty) {
          return const Center(child: Text('No hay citas agendadas'));
        }

        return ListView.builder(
          itemCount: controller.appointments.length,
          itemBuilder: (context, index) {
            final appointment = controller.appointments[index];
            return AppointmentCard(
              appointment: appointment,
              onConfirm: () => controller.confirmAppointment(appointment.id),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog() {
    // Diálogo para crear nueva cita
  }
}
```

**9. Registrar Route**

```dart
// core/routes.dart
class AppRoutes {
  static const appointments = '/appointments';
  
  static List<GetPage> routes = [
    GetPage(
      name: appointments,
      page: () => const AppointmentsScreen(),
      binding: AppointmentsBinding(),
    ),
  ];
}
```

---

### Ejemplo 2: Agregar Campo a un Feature Existente

**Escenario**: Agregar `priority` a las consultas (PropertyInquiry)

**1. Actualizar Entity**

```dart
// shared/domain/entities/app_models_legacy.dart
class PropertyInquiry {
  final String priority; // NUEVO CAMPO
  
  PropertyInquiry({
    // ... campos existentes
    this.priority = 'normal', // 'low', 'normal', 'high', 'urgent'
  });

  factory PropertyInquiry.fromFirestore(Map<String, dynamic> data, String id) {
    return PropertyInquiry(
      // ... campos existentes
      priority: data['priority'] ?? 'normal', // PARSEAR NUEVO CAMPO
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // ... campos existentes
      'priority': priority, // SERIALIZAR NUEVO CAMPO
    };
  }
}
```

**2. Actualizar Data Source**

```dart
// agents/data/datasources/agent_service_legacy.dart
Future<void> updateInquiryPriority(String inquiryId, String priority) async {
  await _firestore
      .collection('contacts')
      .doc(inquiryId)
      .update({
        'priority': priority,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
```

**3. Actualizar Controller**

```dart
// agents/presentation/controllers/agent_inquiries_controller.dart
Future<void> updatePriority(String inquiryId, String priority) async {
  try {
    await _agentService.updateInquiryPriority(inquiryId, priority);
    Get.snackbar('Éxito', 'Prioridad actualizada');
  } catch (e) {
    Get.snackbar('Error', 'No se pudo actualizar');
  }
}
```

**4. Actualizar UI**

```dart
// agents/presentation/pages/agent_inquiries_screen.dart
PopupMenuButton(
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'high',
      child: Text('Alta prioridad'),
      onTap: () => controller.updatePriority(inquiry.id, 'high'),
    ),
    PopupMenuItem(
      value: 'normal',
      child: Text('Prioridad normal'),
      onTap: () => controller.updatePriority(inquiry.id, 'normal'),
    ),
  ],
)
```

---

## ✅ Mejores Prácticas

### 1. Separación de Responsabilidades

❌ **INCORRECTO**
```dart
// Todo mezclado en el Screen
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Property> properties = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Lógica de Firebase directamente en el widget
    final snapshot = await FirebaseFirestore.instance
        .collection('properties')
        .get();
    setState(() {
      properties = snapshot.docs.map((doc) => Property.fromDoc(doc)).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(...);
  }
}
```

✅ **CORRECTO**
```dart
// Controller maneja la lógica
class PropertiesController extends GetxController {
  final PropertyService _service = PropertyService();
  final RxList<Property> properties = <Property>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadProperties();
  }
  
  void _loadProperties() {
    _service.getProperties().listen((data) {
      properties.value = data;
    });
  }
}

// Screen solo UI
class PropertiesScreen extends GetView<PropertiesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.properties.length,
      itemBuilder: (context, index) => PropertyCard(
        property: controller.properties[index],
      ),
    ));
  }
}
```

### 2. Usar Streams para Datos en Tiempo Real

✅ **Stream en Data Source**
```dart
Stream<List<Property>> getProperties() {
  return _firestore
      .collection('properties')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Property.fromFirestore(doc.data(), doc.id))
          .toList());
}
```

✅ **Escuchar en Controller**
```dart
void _loadProperties() {
  _subscription = _service.getProperties().listen(
    (properties) {
      if (!isClosed) {
        this.properties.value = properties;
      }
    },
  );
}

@override
void onClose() {
  _subscription?.cancel(); // IMPORTANTE: Limpiar
  super.onClose();
}
```

### 3. Manejo de Errores

✅ **En todos los niveles**
```dart
// Data Source
Future<void> createProperty(Property property) async {
  try {
    await _firestore.collection('properties').add(property.toFirestore());
  } on FirebaseException catch (e) {
    throw Exception('Error de Firebase: ${e.message}');
  } catch (e) {
    throw Exception('Error inesperado: $e');
  }
}

// Controller
Future<void> createProperty(Property property) async {
  try {
    await _service.createProperty(property);
    Get.snackbar('Éxito', 'Propiedad creada');
    Get.back();
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

### 4. Validaciones en el Dominio

```dart
// Use Case con validaciones
class CreatePropertyUseCase {
  Future<void> call(Property property) async {
    // Validaciones de negocio
    if (property.title.isEmpty) {
      throw Exception('El título es obligatorio');
    }
    
    if (property.price <= 0) {
      throw Exception('El precio debe ser mayor a 0');
    }
    
    if (property.bedrooms < 1) {
      throw Exception('Debe tener al menos 1 habitación');
    }
    
    // Si pasa validaciones, ejecutar
    await repository.createProperty(property);
  }
}
```

### 5. Usar Transacciones para Operaciones Atómicas

✅ **Incrementar contador con transacción**
```dart
Future<void> incrementAgentSales(String agentId) async {
  final agentRef = _firestore.collection('agents').doc(agentId);
  
  await _firestore.runTransaction((transaction) async {
    final agentDoc = await transaction.get(agentRef);
    
    if (!agentDoc.exists) {
      throw 'Agente no encontrado';
    }
    
    final currentSales = agentDoc.data()?['propertiesSold'] ?? 0;
    transaction.update(agentRef, {
      'propertiesSold': currentSales + 1,
    });
  });
}
```

### 6. Lazy Loading de Controllers

```dart
// Binding con lazy loading
class MyBinding extends Bindings {
  @override
  void dependencies() {
    // Solo se crea cuando se necesita
    Get.lazyPut<MyController>(() => MyController());
    
    // Para mantener en memoria después del dispose
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );
  }
}
```

### 7. Naming Conventions

```
- Screens: [Feature]Screen (ej: AgentInquiriesScreen)
- Controllers: [Feature]Controller (ej: AgentInquiriesController)
- Bindings: [Feature]Binding (ej: AgentInquiriesBinding)
- Services: [Feature]Service (ej: AgentService)
- Models/Entities: [Concept] (ej: PropertyInquiry, Agent)
- Use Cases: [Action][Entity]UseCase (ej: CreatePropertyUseCase)
```

### 8. Testing

```dart
// test/features/agents/domain/usecases/complete_inquiry_usecase_test.dart
void main() {
  late CompleteInquiryUseCase useCase;
  late MockInquiryRepository mockRepository;

  setUp(() {
    mockRepository = MockInquiryRepository();
    useCase = CompleteInquiryUseCase(mockRepository);
  });

  test('debe completar inquiry con notas válidas', () async {
    // Arrange
    const inquiryId = '123';
    const notes = 'Vendida exitosamente';

    // Act
    await useCase(inquiryId: inquiryId, resolutionNotes: notes);

    // Assert
    verify(mockRepository.updateInquiry(
      inquiryId,
      status: 'completed',
      resolutionNotes: notes,
    )).called(1);
  });

  test('debe lanzar excepción si notas están vacías', () {
    // Arrange
    const inquiryId = '123';
    const notes = '';

    // Act & Assert
    expect(
      () => useCase(inquiryId: inquiryId, resolutionNotes: notes),
      throwsA(isA<Exception>()),
    );
  });
}
```

---

## 🎓 Conclusión

La **Clean Architecture** te permite:

1. ✅ **Código mantenible**: Cada parte tiene su lugar
2. ✅ **Fácil de testear**: Cada capa es independiente
3. ✅ **Escalable**: Agregar features no rompe lo existente
4. ✅ **Cambiar tecnologías**: Puedes cambiar Firebase por otra DB sin tocar la lógica
5. ✅ **Trabajo en equipo**: Varios devs pueden trabajar en paralelo

### Reglas de Oro

1. **Las dependencias siempre apuntan hacia adentro**: Presentación → Dominio ← Data
2. **El dominio no conoce nada externo**: Ni Flutter, ni GetX, ni Firebase
3. **Los datos fluyen en círculos**: UI → Controller → Service → Firebase → Stream → Controller → UI
4. **Un controller por pantalla**: No reutilices controllers entre pantallas
5. **Usa Bindings siempre**: No instancies controllers manualmente

---

**Recursos Adicionales:**
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetX Documentation](https://pub.dev/packages/get)
- [Firebase Best Practices](https://firebase.google.com/docs/firestore/best-practices)
