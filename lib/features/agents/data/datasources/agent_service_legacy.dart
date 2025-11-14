import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alquilamelo_app/features/shared/domain/entities/app_models_legacy.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/shared_preferences_service_legacy.dart';
import 'package:alquilamelo_app/features/shared/data/datasources/imagekit_web_service_legacy.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageKitWebService _imageService = ImageKitWebService();

  // Crear perfil de agente
  Future<void> createAgentProfile({
    required String name,
    required String phone,
    required String position,
    String? photoUrl,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado';
      }

      final agent = Agent(
        id: currentUser.uid,
        name: name,
        email: currentUser.email ?? '',
        phone: phone,
        position: position,
        propertiesSold: 0,
        createdAt: DateTime.now(),
        whatsapp: phone,
      );

      await _firestore
          .collection('agents')
          .doc(currentUser.uid)
          .set(agent.toFirestore());

      // Marcar sincronización después de crear perfil
      await SharedPreferencesService.setLastSyncTime(DateTime.now());

      print('✅ Perfil de agente creado: ${agent.name}');
    } catch (e) {
      print('❌ Error creando perfil de agente: $e');
      rethrow;
    }
  }

  // Obtener perfil del agente actual
  Stream<Agent?> getCurrentAgentProfile() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('agents')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Agent.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Verificar si el usuario actual es agente
  Future<bool> isCurrentUserAgent() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot doc = await _firestore
          .collection('agents')
          .doc(currentUser.uid)
          .get();

      return doc.exists;
    } catch (e) {
      print('❌ Error verificando si es agente: $e');
      return false;
    }
  }

  // Agregar nueva propiedad
  Future<String> addProperty(Property property) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Usuario no autenticado';
      }

      // Asignar el agente a la propiedad
      final propertyWithAgent = Property(
        id: '', // Se asignará automáticamente
        title: property.title,
        description: property.description,
        price: property.price,
        action: property.action,
        type: property.type,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        area: property.area,
        location: property.location,
        imageUrl: property.imageUrl,
        imageUrls: property.imageUrls,
        agentId: currentUser.uid, // ID del agente actual
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        viewsCount: 0,
        favoritesCount: 0,
        features: property.features,
      );

      DocumentReference docRef = await _firestore
          .collection('properties')
          .add(propertyWithAgent.toFirestore());

      print('✅ Propiedad agregada: ${property.title}');
      return docRef.id;
    } catch (e) {
      print('❌ Error agregando propiedad: $e');
      rethrow;
    }
  }

  // Obtener propiedades del agente actual
  Stream<List<Property>> getAgentProperties() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('properties')
        .where('agentId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      List<Property> properties = snapshot.docs
          .map((doc) => Property.fromFirestore(doc.data(), doc.id))
          .toList();

      // Ordenar por fecha de creación (más recientes primero)
      properties.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return properties;
    });
  }

  // Obtener estadísticas del agente
  Future<AgentStats> getAgentStats() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return AgentStats();
      }

      // Obtener información del agente
      final agentDoc = await _firestore
          .collection('agents')
          .doc(currentUser.uid)
          .get();
      
      int propertiesSold = 0;
      if (agentDoc.exists) {
        propertiesSold = agentDoc.data()?['propertiesSold'] ?? 0;
      }

      // Obtener todas las propiedades del agente
      final propertiesSnapshot = await _firestore
          .collection('properties')
          .where('agentId', isEqualTo: currentUser.uid)
          .get();

      int totalProperties = propertiesSnapshot.docs.length;
      int activeProperties = propertiesSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length;

      // Obtener consultas del agente
      final inquiriesSnapshot = await _firestore
          .collection('contacts')
          .where('agentId', isEqualTo: currentUser.uid)
          .get();

      int totalInquiries = inquiriesSnapshot.docs.length;
      int pendingInquiries = inquiriesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      int completedInquiries = inquiriesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      return AgentStats(
        totalProperties: totalProperties,
        activeProperties: activeProperties,
        totalInquiries: totalInquiries,
        pendingInquiries: pendingInquiries,
        completedInquiries: completedInquiries,
        propertiesSold: propertiesSold,
      );
    } catch (e) {
      return AgentStats();
    }
  }

  // Obtener consultas del agente
  Stream<List<PropertyInquiry>> getAgentInquiries() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('contacts')
        .where('agentId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<PropertyInquiry> inquiries = [];
      
      // Ordenar manualmente en memoria después de obtener los datos
      var docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime); // descendente
      });

      for (var doc in docs) {
        final data = doc.data();
        
        // Usar fromFirestore para incluir todos los campos (resolutionNotes, completedAt, etc.)
        inquiries.add(PropertyInquiry.fromFirestore(data, doc.id));
      }

      return inquiries;
    });
  }

  // Actualizar estado de consulta
  Future<void> updateInquiryStatus(String inquiryId, String status, {String? resolutionNotes}) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Si se marca como completada y hay notas, agregarlas
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
    } catch (e) {
      print('❌ Error actualizando estado de consulta: $e');
      rethrow;
    }
  }

  // Activar/desactivar propiedad
  Future<void> togglePropertyActive(String propertyId, bool isActive) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Propiedad ${isActive ? 'activada' : 'desactivada'}');
    } catch (e) {
      print('❌ Error actualizando propiedad: $e');
      rethrow;
    }
  }

  // Actualizar propiedad
  Future<void> updateProperty(String propertyId, Map<String, dynamic> data) async {
    try {
      // Agregar timestamp de actualización
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .update(data);

      print('✅ Propiedad actualizada');
    } catch (e) {
      print('❌ Error actualizando propiedad: $e');
      rethrow;
    }
  }

  // Subir múltiples imágenes
  Future<List<String>> uploadImages(List<XFile> images) async {
    try {
      List<String> imageUrls = [];
      
      for (XFile image in images) {
        String imageUrl = await _imageService.uploadImage(image);
        imageUrls.add(imageUrl);
      }
      
      print('✅ ${imageUrls.length} imágenes subidas exitosamente');
      return imageUrls;
    } catch (e) {
      print('❌ Error subiendo imágenes: $e');
      rethrow;
    }
  }

  // Incrementar contador de ventas del agente
  Future<void> incrementAgentSales(String agentId) async {
    try {
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

    } catch (e) {
      rethrow;
    }
  }

  // Eliminar propiedad
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .delete();

      print('✅ Propiedad eliminada');
    } catch (e) {
      print('❌ Error eliminando propiedad: $e');
      rethrow;
    }
  }
}



