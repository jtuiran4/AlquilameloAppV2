import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para poblar Firebase con datos de ejemplo
  Future<void> seedInitialData() async {
    try {
      // Verificar si ya existen propiedades
      QuerySnapshot existing = await _firestore.collection('properties').limit(1).get();
      
      if (existing.docs.isNotEmpty) {
        print('🏠 Las propiedades ya existen en Firebase');
        return;
      }

      print('📝 Creando propiedades de ejemplo en Firebase...');
      
      // Crear propiedades de ejemplo
      await _createProperties();
      await _createAgents();
      
      print('✅ Datos de ejemplo creados exitosamente en Firebase');
    } catch (e) {
      print('❌ Error al crear datos de ejemplo: $e');
    }
  }

  Future<void> _createProperties() async {
    final properties = [
      {
        'title': 'Apartamento Moderno en El Poblado',
        'description': 'Hermoso apartamento de 2 habitaciones con vista panorámica de la ciudad. Ubicado en el corazón de El Poblado, cerca de restaurantes y centros comerciales.',
        'price': 450000000,
        'action': 'Venta',
        'type': 'Apartamento',
        'bedrooms': 2,
        'bathrooms': 2,
        'area': 85.5,
        'location': 'El Poblado, Medellín',
        'imageUrl': 'assets/hotel_room.jpg',
        'imageUrls': ['assets/hotel_room.jpg', 'assets/hotel.png'],
        'agentId': 'agent1',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewsCount': 45,
        'favoritesCount': 12,
        'features': {
          'balcon': true,
          'parqueadero': true,
          'gimnasio': true,
          'piscina': true,
          'vigilancia': true,
          'ascensor': true,
        }
      },
      {
        'title': 'Casa Familiar en Laureles',
        'description': 'Casa de 3 pisos con jardín privado y garaje para 2 carros. Perfecta para familias grandes, con amplios espacios y excelente ubicación.',
        'price': 2500000,
        'action': 'Arriendo',
        'type': 'Casa',
        'bedrooms': 4,
        'bathrooms': 3,
        'area': 180.0,
        'location': 'Laureles, Medellín',
        'imageUrl': 'assets/hotel.png',
        'imageUrls': ['assets/hotel.png', 'assets/hotel_room.jpg'],
        'agentId': 'agent2',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewsCount': 67,
        'favoritesCount': 23,
        'features': {
          'jardin': true,
          'parqueadero': true,
          'cuarto_servicio': true,
          'terraza': true,
          'vigilancia': false,
          'chimenea': true,
        }
      },
      {
        'title': 'Penthouse de Lujo en Envigado',
        'description': 'Espectacular penthouse con terraza privada y jacuzzi. Vista 360° de la ciudad, acabados de primera calidad y ubicación premium.',
        'price': 950000000,
        'action': 'Venta',
        'type': 'Apartamento',
        'bedrooms': 3,
        'bathrooms': 3,
        'area': 220.0,
        'location': 'Envigado, Antioquia',
        'imageUrl': 'assets/hotel2.jpg',
        'imageUrls': ['assets/hotel2.jpg', 'assets/hotel_room.jpg'],
        'agentId': 'agent1',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewsCount': 89,
        'favoritesCount': 34,
        'features': {
          'jacuzzi': true,
          'terraza': true,
          'parqueadero': true,
          'cuarto_servicio': true,
          'gimnasio': true,
          'piscina': true,
          'vigilancia': true,
          'ascensor': true,
        }
      },
      {
        'title': 'Casa Campestre en La Ceja',
        'description': 'Hermosa casa campestre con amplio lote, ideal para descansar los fines de semana. Rodeada de naturaleza y con clima perfecto.',
        'price': 850000000,
        'action': 'Venta',
        'type': 'Casa',
        'bedrooms': 5,
        'bathrooms': 4,
        'area': 350.0,
        'location': 'La Ceja, Antioquia',
        'imageUrl': 'assets/hotel_room.jpg',
        'imageUrls': ['assets/hotel_room.jpg', 'assets/hotel.png'],
        'agentId': 'agent2',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewsCount': 156,
        'favoritesCount': 67,
        'features': {
          'jardin': true,
          'piscina': true,
          'barbacoa': true,
          'parqueadero': true,
          'cuarto_servicio': true,
          'chimenea': true,
          'zona_verde': true,
        }
      },
      {
        'title': 'Apartaestudio en Sabaneta',
        'description': 'Moderno apartaestudio perfecto para jóvenes profesionales. Completamente amoblado y en excelente ubicación.',
        'price': 1200000,
        'action': 'Arriendo',
        'type': 'Apartamento',
        'bedrooms': 1,
        'bathrooms': 1,
        'area': 45.0,
        'location': 'Sabaneta, Antioquia',
        'imageUrl': 'assets/hotel.png',
        'imageUrls': ['assets/hotel.png'],
        'agentId': 'agent1',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewsCount': 234,
        'favoritesCount': 45,
        'features': {
          'amoblado': true,
          'parqueadero': true,
          'gimnasio': true,
          'vigilancia': true,
          'ascensor': true,
        }
      },
    ];

    // Crear cada propiedad en Firebase
    for (int i = 0; i < properties.length; i++) {
      await _firestore.collection('properties').add(properties[i]);
      print('✅ Propiedad ${i + 1} creada: ${properties[i]['title']}');
    }
  }

  Future<void> _createAgents() async {
    final agents = [
      {
        'name': 'María González',
        'position': 'Agente Inmobiliario Senior',
        'phone': '+57 300 123 4567',
        'email': 'maria.gonzalez@alquilamelo.com',
        'imageUrl': 'assets/hotel_room.jpg',
        'experience': '8 años de experiencia',
        'specialties': ['Apartamentos', 'Ventas de lujo'],
        'rating': 4.8,
        'totalSales': 145,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Carlos Rodríguez',
        'position': 'Especialista en Arriendos',
        'phone': '+57 310 987 6543',
        'email': 'carlos.rodriguez@alquilamelo.com',
        'imageUrl': 'assets/hotel.png',
        'experience': '5 años de experiencia',
        'specialties': ['Casas', 'Arriendos familiares'],
        'rating': 4.6,
        'totalSales': 98,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Crear cada agente con ID específico
    await _firestore.collection('agents').doc('agent1').set(agents[0]);
    await _firestore.collection('agents').doc('agent2').set(agents[1]);
    
    print('✅ Agentes creados exitosamente');
  }
}