import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        return AgentStats(
          totalProperties: 0,
          activeProperties: 0,
          totalInquiries: 0,
        );
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

      return AgentStats(
        totalProperties: totalProperties,
        activeProperties: activeProperties,
        totalInquiries: totalInquiries,
      );
    } catch (e) {
      print('❌ Error obteniendo estadísticas del agente: $e');
      return AgentStats(
        totalProperties: 0,
        activeProperties: 0,
        totalInquiries: 0,
      );
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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<PropertyInquiry> inquiries = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Obtener información de la propiedad
        Property? property;
        try {
          final propertyDoc = await _firestore
              .collection('properties')
              .doc(data['propertyId'])
              .get();
          
          if (propertyDoc.exists) {
            property = Property.fromFirestore(
              propertyDoc.data() as Map<String, dynamic>, 
              propertyDoc.id
            );
          }
        } catch (e) {
          print('Error obteniendo propiedad: $e');
        }

        // Obtener información del usuario
        UserProfile? user;
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();
          
          if (userDoc.exists) {
            user = UserProfile.fromFirestore(userDoc);
          }
        } catch (e) {
          print('Error obteniendo usuario: $e');
        }

        inquiries.add(PropertyInquiry(
          id: doc.id,
          propertyId: data['propertyId'] ?? '',
          propertyTitle: property?.title ?? data['propertyTitle'] ?? '',
          propertyLocation: property?.location ?? data['propertyLocation'] ?? '',
          userId: data['userId'] ?? '',
          userName: user?.name ?? data['userName'] ?? '',
          userEmail: user?.email ?? data['userEmail'] ?? '',
          userPhone: user?.phone ?? data['userPhone'] ?? '',
          agentId: data['agentId'] ?? '',
          message: data['message'] ?? '',
          status: data['status'] ?? 'pending',
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
        ));
      }

      return inquiries;
    });
  }

  // Actualizar estado de consulta
  Future<void> updateInquiryStatus(String inquiryId, String status) async {
    try {
      await _firestore
          .collection('contacts')
          .doc(inquiryId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Estado de consulta actualizado: $status');
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



