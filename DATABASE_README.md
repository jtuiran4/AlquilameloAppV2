# Base de Datos Firebase - Alquílamelo App

## Estructura de la Base de Datos

### Colecciones Principales

#### 1. `users` - Información de usuarios
```json
{
  "uid": "string", // ID único del usuario
  "fullName": "string", // Nombre completo
  "email": "string", // Email del usuario
  "phone": "string", // Teléfono
  "profileImageUrl": "string", // URL de imagen de perfil
  "joinDate": "timestamp", // Fecha de registro
  "isActive": "boolean", // Usuario activo
  "lastLogin": "timestamp", // Último inicio de sesión
  "preferences": {
    "notifications": "boolean",
    "language": "string", // 'es', 'en'
    "currency": "string" // 'COP', 'USD'
  },
  "statistics": {
    "favoritesCount": "number", // Cantidad de favoritos
    "viewedProperties": "number", // Propiedades vistas
    "contactedAgents": "number" // Agentes contactados
  }
}
```

#### 2. `properties` - Propiedades inmobiliarias
```json
{
  "title": "string", // Título de la propiedad
  "description": "string", // Descripción detallada
  "price": "number", // Precio en COP
  "action": "string", // 'Venta' o 'Arriendo'
  "type": "string", // 'Casa', 'Apartamento', 'Penthouse', etc.
  "bedrooms": "number", // Número de habitaciones
  "bathrooms": "number", // Número de baños
  "area": "number", // Área en m²
  "location": "string", // Ubicación
  "imageUrl": "string", // Imagen principal
  "imageUrls": ["string"], // Array de URLs de imágenes
  "agentId": "string", // ID del agente responsable
  "isActive": "boolean", // Property activa
  "createdAt": "timestamp", // Fecha de creación
  "updatedAt": "timestamp", // Última actualización
  "viewsCount": "number", // Contador de vistas
  "favoritesCount": "number", // Contador de favoritos
  "features": {
    "parking": "boolean",
    "gym": "boolean",
    "pool": "boolean",
    "security": "boolean",
    "elevator": "boolean",
    "balcony": "boolean",
    "garden": "boolean",
    "oceanView": "boolean",
    "jacuzzi": "boolean",
    "terrace": "boolean"
  }
}
```

#### 3. `agents` - Agentes inmobiliarios
```json
{
  "name": "string", // Nombre del agente
  "position": "string", // Cargo/posición
  "email": "string", // Email de contacto
  "phone": "string", // Teléfono
  "whatsapp": "string", // WhatsApp
  "photoUrl": "string", // URL de foto
  "rating": "number", // Calificación (1-5)
  "propertiesSold": "number", // Propiedades vendidas
  "yearsExperience": "number", // Años de experiencia
  "isActive": "boolean", // Agente activo
  "createdAt": "timestamp", // Fecha de registro
  "specialties": ["string"], // Especialidades
  "description": "string" // Descripción del agente
}
```

#### 4. `contacts` - Contactos con agentes
```json
{
  "userId": "string", // ID del usuario
  "propertyId": "string", // ID de la propiedad
  "agentId": "string", // ID del agente
  "message": "string", // Mensaje del usuario
  "contactMethod": "string", // 'whatsapp', 'phone', 'email'
  "createdAt": "timestamp", // Fecha del contacto
  "status": "string" // 'pending', 'contacted', 'completed'
}
```

### Subcolecciones

#### `users/{userId}/favorites` - Favoritos del usuario
```json
{
  "propertyId": "string", // ID de la propiedad
  "addedAt": "timestamp" // Fecha cuando se agregó a favoritos
}
```

## Servicios Implementados

### 1. `AuthService` - Autenticación
- Registro de usuarios
- Inicio de sesión
- Cierre de sesión
- Cambio de contraseña
- Recuperación de contraseña
- Gestión de datos del usuario

### 2. `PropertyService` - Gestión de Propiedades
- Obtener todas las propiedades
- Filtrar por tipo
- Búsqueda avanzada
- Agregar/quitar favoritos
- Incrementar vistas
- Contactar agente

### 3. `DatabaseInitService` - Inicialización
- Poblado inicial de datos
- Creación de agentes de ejemplo
- Creación de propiedades de ejemplo
- Limpieza de base de datos (desarrollo)

### 4. `AppStateService` - Estado Global
- Manejo del estado de autenticación
- Inicialización de la base de datos
- Estados de carga
- Notificaciones de cambios

## Índices Recomendados en Firestore

Para optimizar las consultas, crear los siguientes índices compuestos:

### Properties
- `isActive` (ASC) + `createdAt` (DESC)
- `isActive` (ASC) + `type` (ASC) + `createdAt` (DESC)
- `isActive` (ASC) + `location` (ASC) + `price` (ASC)

### Contacts
- `userId` (ASC) + `createdAt` (DESC)
- `agentId` (ASC) + `status` (ASC) + `createdAt` (DESC)

## Reglas de Seguridad Sugeridas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden leer/escribir sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Favoritos del usuario
      match /favorites/{favoriteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Propiedades - lectura pública, escritura para administradores
    match /properties/{propertyId} {
      allow read: if true;
      allow write: if request.auth != null; // Ajustar según roles
    }
    
    // Agentes - lectura pública
    match /agents/{agentId} {
      allow read: if true;
      allow write: if request.auth != null; // Ajustar según roles
    }
    
    // Contactos - solo el usuario puede crear y leer los suyos
    match /contacts/{contactId} {
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || request.auth.uid == resource.data.agentId);
    }
  }
}
```

## Uso de los Servicios

```dart
// Ejemplo de uso en un Widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateService>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (!appState.isLoggedIn) {
          return LoginScreen();
        }
        
        return HomeScreen();
      },
    );
  }
}

// Usar PropertyService
PropertyService propertyService = PropertyService();

// Obtener propiedades
Stream<List<Property>> properties = propertyService.getProperties();

// Agregar a favoritos
bool success = await propertyService.addToFavorites(propertyId);
```

## Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

# Construir para producción
flutter build apk --release
```

## Configuración Adicional

1. **Firebase Console**: Configurar autenticación por email
2. **Firestore**: Crear la base de datos en modo de prueba
3. **Storage**: Configurar para subida de imágenes (futuro)
4. **Analytics**: Configurar Firebase Analytics (opcional)

## Estado Actual

✅ Servicios de autenticación implementados
✅ Servicios de propiedades implementados  
✅ Modelos de datos actualizados para Firestore
✅ Inicialización de base de datos con datos de ejemplo
✅ Manejo de estado global con Provider
✅ Integración con las pantallas existentes

### Próximos Pasos Sugeridos

1. Integrar los servicios con las pantallas existentes
2. Implementar subida de imágenes a Firebase Storage
3. Agregar notificaciones push
4. Implementar chat en tiempo real
5. Agregar mapas para ubicaciones
6. Sistema de calificaciones y reseñas