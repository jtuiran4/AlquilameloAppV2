# 🔥 Configuración de Índices de Firebase para Alquílamelo

## ❌ Error Encontrado
```
[cloud_firestore/failed-precondition] The query requires an index.
```

## 🛠️ Solución Implementada

### ✅ **Solución Temporal (Ya aplicada)**
Modificamos las consultas de Firestore para evitar índices compuestos:
- Removimos `orderBy` de las consultas con `where`
- Ordenamos los resultados en el cliente (Flutter)
- Creamos método `getAllPropertiesSimple()` sin filtros complejos

### 📋 **Índices Requeridos (Para optimización futura)**

#### 1. Índice para consulta principal de propiedades:
- **Colección**: `properties`
- **Campos**:
  - `isActive` (Ascending)
  - `createdAt` (Descending)
  - `__name__` (Ascending)

#### 2. Índice para consulta por tipo:
- **Colección**: `properties`
- **Campos**:
  - `isActive` (Ascending)
  - `type` (Ascending)
  - `createdAt` (Descending)
  - `__name__` (Ascending)

## 🔗 Enlaces para Crear Índices

### Crear Índice Principal:
```
https://console.firebase.google.com/v1/r/project/alquilamelo-app/firestore/indexes?create_composite=ClJwcm9qZWN0cy9hbHF1aWxhbWVsby1hcHAvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Byb3BlcnRpZXMvaW5kZXhlcy9fEAEaDAoIaXNBY3RpdmUQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

## 📝 Pasos para Crear Índices Manualmente:

1. **Ir a Firebase Console**: https://console.firebase.google.com/
2. **Seleccionar proyecto**: `alquilamelo-app`
3. **Ir a Firestore Database**
4. **Hacer clic en "Indexes"**
5. **Crear índice compuesto**:
   - Colección: `properties`
   - Campo 1: `isActive` (Ascending)
   - Campo 2: `createdAt` (Descending)
6. **Crear segundo índice**:
   - Colección: `properties`
   - Campo 1: `isActive` (Ascending)
   - Campo 2: `type` (Ascending)
   - Campo 3: `createdAt` (Descending)

## ⚡ Ventajas de la Solución Actual:

### ✅ **Pros**:
- No requiere configuración adicional en Firebase
- Funciona inmediatamente
- Menos dependencia de configuración externa

### ⚠️ **Contras**:
- Transferencia de más datos (todos los documentos)
- Ordenamiento en el cliente consume más recursos
- Menos eficiente para colecciones muy grandes

## 🚀 Recomendación:

**Para desarrollo**: Usar la solución actual (ya implementada)
**Para producción**: Crear los índices en Firebase Console usando los enlaces proporcionados

## 🔄 Cómo Cambiar de Vuelta a Consultas Optimizadas:

Una vez creados los índices, cambiar en `PropertyService`:

```dart
// Cambiar de:
stream: _propertyService.getAllPropertiesSimple(),

// A:
stream: _propertyService.getProperties(),
```

Los índices tardan unos minutos en crearse. Firebase enviará una notificación cuando estén listos.