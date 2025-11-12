# Arquitectura Limpia - AlquilaMeLo App

Este proyecto ha sido reestructurado siguiendo los principios de **Clean Architecture** con organización basada en features.

## 📁 Estructura del Proyecto

```
lib/
├── core/                          # Infraestructura compartida
│   └── dependency_injection.dart   # Configuración de dependencias
├── features/                      # Features organizados por dominio
│   ├── shared/                    # Entidades y lógica compartida
│   │   ├── domain/
│   │   │   ├── entities/          # Entidades de dominio (Property, Agent, User, etc.)
│   │   │   ├── repositories/      # Interfaces de repositorios
│   │   │   ├── datasources/       # Interfaces de datasources
│   │   │   └── usecases/          # Casos de uso
│   │   ├── data/
│   │   │   ├── datasources/       # Implementaciones de datasources
│   │   │   └── repositories/      # Implementaciones de repositorios
│   │   └── presentation/
│   │       └── controllers/       # Controladores GetX
│   ├── home/                      # Feature de inicio
│   ├── auth/                      # Feature de autenticación
│   ├── properties/                # Feature de propiedades
│   ├── agents/                    # Feature de agentes
│   ├── user/                      # Feature de usuario
│   └── favorites/                 # Feature de favoritos
└── main.dart                      # Punto de entrada actualizado
```

## 🏗️ Capas de Clean Architecture

### 1. **Domain Layer** (Dominio)
- **Entities**: Modelos de datos puros sin dependencias externas
- **Repositories**: Interfaces que definen contratos de datos
- **Use Cases**: Lógica de negocio independiente de frameworks

### 2. **Data Layer** (Datos)
- **Repositories**: Implementaciones de las interfaces de repositorio
- **Data Sources**: Manejo de datos remotos (Firebase) y locales (SharedPreferences)

### 3. **Presentation Layer** (Presentación)
- **Controllers**: Controladores GetX para manejo de estado
- **Pages**: Pantallas de la UI
- **Widgets**: Componentes reutilizables

## 🔧 Dependencias Agregadas

```yaml
dependencies:
  equatable: ^2.0.5    # Para comparación de objetos
  get: ^4.6.6          # Para manejo de estado y navegación
```

## 🚀 Cómo Usar

### 1. Inicialización
La inyección de dependencias se inicializa automáticamente en `main.dart`:

```dart
void main() async {
  // ... inicializaciones previas
  await DependencyInjection.init();
  runApp(const AlquilameloApp());
}
```

### 2. Usar Controladores
Los controladores están registrados globalmente con GetX:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final propertyController = Get.find<PropertyController>();

    return Obx(() {
      if (propertyController.isLoading.value) {
        return CircularProgressIndicator();
      }

      return ListView.builder(
        itemCount: propertyController.properties.length,
        itemBuilder: (context, index) {
          final property = propertyController.properties[index];
          return Text(property.title);
        },
      );
    });
  }
}
```

### 3. Ejecutar Casos de Uso
```dart
// Cargar propiedades
await propertyController.loadProperties();

// Aplicar filtros
propertyController.searchQuery.value = 'apartamento';
propertyController.selectedAction.value = 'Venta';
propertyController.applyFilters();

// Toggle favorito
await propertyController.toggleFavorite(userId, propertyId, isFavorite);
```

## 📋 Features Implementados

### ✅ Shared (Compartido)
- **Entities**: Property, Agent, UserProfile, PropertyInquiry, AgentStats, UserStats, AuthResult
- **Property Use Cases**: GetProperties, GetPropertyById, ToggleFavorite, etc.
- **Data Sources**: Firebase (remoto) + SharedPreferences (local)
- **Controller**: PropertyController con GetX

### 🔄 Pendiente
- **Auth Feature**: Login, registro, manejo de sesión
- **Agent Feature**: Dashboard de agentes, gestión de propiedades
- **User Feature**: Perfil de usuario, configuración
- **Favorites Feature**: Gestión de favoritos
- **Properties Feature**: Detalles de propiedad, creación/edición

## 🔄 Migración en Progreso

### Completado:
1. ✅ Estructura de carpetas creada
2. ✅ Entidades de dominio definidas
3. ✅ Interfaces de repositorio y datasource
4. ✅ Casos de uso implementados
5. ✅ Datasources implementados (Property)
6. ✅ Repositorio implementado (Property)
7. ✅ Controlador GetX implementado (Property)
8. ✅ Inyección de dependencias configurada
9. ✅ HomeScreen actualizado con nueva arquitectura

### Próximos Pasos:
1. Migrar servicios existentes a datasources
2. Implementar features de autenticación
3. Actualizar todas las pantallas para usar controladores
4. Migrar widgets existentes
5. Actualizar todas las importaciones
6. Testing y validación

## 🎯 Beneficios de la Nueva Arquitectura

- **Separación de responsabilidades**: Cada capa tiene una responsabilidad clara
- **Testabilidad**: Lógica de negocio independiente de UI y datos
- **Mantenibilidad**: Cambios en una capa no afectan otras
- **Reutilización**: Use cases pueden ser reutilizados en diferentes contextos
- **Escalabilidad**: Fácil agregar nuevas features siguiendo la estructura
- **Inyección de dependencias**: Acoplamiento bajo entre componentes

## 📖 Guías de Implementación

### Crear un Nuevo Use Case:
1. Definir interfaz en `domain/usecases/`
2. Implementar en `domain/usecases/[feature]_usecases.dart`
3. Inyectar en controlador correspondiente

### Crear un Nuevo Controller:
1. Extender `GetxController`
2. Definir estado reactivo con `.obs`
3. Implementar métodos que llamen use cases
4. Registrar en `DependencyInjection`

### Agregar Nueva Feature:
1. Crear estructura de carpetas en `features/[feature]/`
2. Implementar entities, repositories, use cases
3. Crear datasources y repositories
4. Implementar controller y páginas
5. Registrar dependencias en `DependencyInjection`