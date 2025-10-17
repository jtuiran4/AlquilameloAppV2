// Modelos de datos compartidos para la aplicación Alquílamelo
import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String action; // 'Venta' o 'Arriendo'
  final String type; // 'Casa', 'Apartamento', etc.
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String location;
  final String imageUrl;
  final List<String> imageUrls; // Múltiples imágenes
  final String agentId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int viewsCount;
  final int favoritesCount;
  final Map<String, dynamic> features; // Características adicionales
  bool isFavorite;

  // Getter para compatibilidad con código existente
  int get rooms => bedrooms;
  
  // Getter para precio formateado
  String get priceFormatted {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.action,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.location,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.agentId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.viewsCount = 0,
    this.favoritesCount = 0,
    this.features = const {},
    this.isFavorite = false,
  });

  // Convertir desde Firestore
  factory Property.fromFirestore(Map<String, dynamic> data, String id) {
    return Property(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      action: data['action'] ?? 'Arriendo',
      type: data['type'] ?? 'Apartamento',
      bedrooms: data['bedrooms'] ?? 1,
      bathrooms: data['bathrooms'] ?? 1,
      area: (data['area'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      agentId: data['agentId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      viewsCount: data['viewsCount'] ?? 0,
      favoritesCount: data['favoritesCount'] ?? 0,
      features: Map<String, dynamic>.from(data['features'] ?? {}),
      isFavorite: false, // Se actualizará según el usuario
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'action': action,
      'type': type,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'location': location,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'agentId': agentId,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'viewsCount': viewsCount,
      'favoritesCount': favoritesCount,
      'features': features,
    };
  }
}

class Agent {
  final String id;
  final String name;
  final String position;
  final String email;
  final String phone;
  final String whatsapp;
  final String photoUrl;
  final double rating;
  final int propertiesSold;
  final int yearsExperience;
  final bool isActive;
  final DateTime? createdAt;
  final List<String> specialties;
  final String description;

  Agent({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.photoUrl,
    required this.rating,
    required this.propertiesSold,
    required this.yearsExperience,
    this.isActive = true,
    this.createdAt,
    this.specialties = const [],
    this.description = '',
  });

  // Convertir desde Firestore
  factory Agent.fromFirestore(Map<String, dynamic> data, String id) {
    return Agent(
      id: id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      propertiesSold: data['propertiesSold'] ?? 0,
      yearsExperience: data['yearsExperience'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      specialties: List<String>.from(data['specialties'] ?? []),
      description: data['description'] ?? '',
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'position': position,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'photoUrl': photoUrl,
      'rating': rating,
      'propertiesSold': propertiesSold,
      'yearsExperience': yearsExperience,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'specialties': specialties,
      'description': description,
    };
  }

  static Agent defaultAgent() {
    return Agent(
      id: '1',
      name: 'María González',
      position: 'Agente Inmobiliario Senior',
      email: 'maria.gonzalez@alquilamelo.com',
      phone: '+57 300 123 4567',
      whatsapp: '+57 300 123 4567',
      photoUrl: '', // Se puede agregar una imagen del agente
      rating: 4.8,
      propertiesSold: 127,
      yearsExperience: 8,
      specialties: ['Apartamentos', 'Casas', 'Oficinas'],
      description: 'Agente especializada en propiedades residenciales y comerciales con más de 8 años de experiencia.',
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde documento de Firestore
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class PropertyInquiry {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String agentId;
  final String message;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  PropertyInquiry({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.agentId,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  // Convertir desde Firestore
  factory PropertyInquiry.fromFirestore(Map<String, dynamic> data, String id) {
    return PropertyInquiry(
      id: id,
      propertyId: data['propertyId'] ?? '',
      propertyTitle: data['propertyTitle'] ?? '',
      propertyLocation: data['propertyLocation'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      agentId: data['agentId'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'propertyLocation': propertyLocation,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'agentId': agentId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AgentStats {
  final int totalProperties;
  final int activeProperties;
  final int totalInquiries;
  final int pendingInquiries;
  final int completedInquiries;
  final double averageRating;
  final int totalViews;

  AgentStats({
    this.totalProperties = 0,
    this.activeProperties = 0,
    this.totalInquiries = 0,
    this.pendingInquiries = 0,
    this.completedInquiries = 0,
    this.averageRating = 0.0,
    this.totalViews = 0,
  });
}