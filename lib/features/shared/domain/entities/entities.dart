// Entidades de dominio compartidas
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Property extends Equatable {
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
  final bool isFavorite;

  const Property({
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

  // Getter para obtener todas las imágenes disponibles
  List<String> get allImages {
    List<String> images = [];

    // Agregar imagen principal si existe
    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }

    // Agregar imágenes adicionales
    images.addAll(imageUrls);

    // Remover duplicados y URLs vacías
    return images.where((url) => url.isNotEmpty).toSet().toList();
  }

  // Getter para obtener la primera imagen disponible
  String get firstAvailableImage {
    final images = allImages;
    return images.isNotEmpty ? images.first : '';
  }

  @override
  List<Object?> get props => [
    id, title, description, price, action, type, bedrooms, bathrooms,
    area, location, imageUrl, imageUrls, agentId, isActive, createdAt,
    updatedAt, viewsCount, favoritesCount, features, isFavorite
  ];

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? action,
    String? type,
    int? bedrooms,
    int? bathrooms,
    double? area,
    String? location,
    String? imageUrl,
    List<String>? imageUrls,
    String? agentId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewsCount,
    int? favoritesCount,
    Map<String, dynamic>? features,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      action: action ?? this.action,
      type: type ?? this.type,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      agentId: agentId ?? this.agentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewsCount: viewsCount ?? this.viewsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      features: features ?? this.features,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Convertir desde Firestore
  factory Property.fromFirestore(Map<String, dynamic> data, String id) {
    return Property(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      action: data['action'] ?? '',
      type: data['type'] ?? '',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      area: (data['area'] ?? 0.0).toDouble(),
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

class Agent extends Equatable {
  final String id;
  final String name;
  final String position;
  final String email;
  final String phone;
  final String whatsapp;
  final int propertiesSold;
  final DateTime? createdAt;

  const Agent({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.propertiesSold,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, name, position, email, phone, whatsapp, propertiesSold, createdAt
  ];

  Agent copyWith({
    String? id,
    String? name,
    String? position,
    String? email,
    String? phone,
    String? whatsapp,
    int? propertiesSold,
    DateTime? createdAt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      propertiesSold: propertiesSold ?? this.propertiesSold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convertir desde Firestore
  factory Agent.fromFirestore(Map<String, dynamic> data, String id) {
    return Agent(
      id: id,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      propertiesSold: data['propertiesSold'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
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
      'propertiesSold': propertiesSold,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, name, email, phone, profileImage, createdAt, updatedAt
  ];

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convertir desde Firestore
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
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class PropertyInquiry extends Equatable {
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

  const PropertyInquiry({
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

  @override
  List<Object?> get props => [
    id, propertyId, propertyTitle, propertyLocation, userId, userName,
    userEmail, userPhone, agentId, message, status, createdAt, updatedAt
  ];

  PropertyInquiry copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? propertyLocation,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? agentId,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyInquiry(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyLocation: propertyLocation ?? this.propertyLocation,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      agentId: agentId ?? this.agentId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AgentStats extends Equatable {
  final int totalProperties;
  final int activeProperties;
  final int totalInquiries;
  final int pendingInquiries;
  final int completedInquiries;
  final double averageRating;

  const AgentStats({
    this.totalProperties = 0,
    this.activeProperties = 0,
    this.totalInquiries = 0,
    this.pendingInquiries = 0,
    this.completedInquiries = 0,
    this.averageRating = 0.0,
  });

  @override
  List<Object> get props => [
    totalProperties, activeProperties, totalInquiries,
    pendingInquiries, completedInquiries, averageRating
  ];

  AgentStats copyWith({
    int? totalProperties,
    int? activeProperties,
    int? totalInquiries,
    int? pendingInquiries,
    int? completedInquiries,
    double? averageRating,
  }) {
    return AgentStats(
      totalProperties: totalProperties ?? this.totalProperties,
      activeProperties: activeProperties ?? this.activeProperties,
      totalInquiries: totalInquiries ?? this.totalInquiries,
      pendingInquiries: pendingInquiries ?? this.pendingInquiries,
      completedInquiries: completedInquiries ?? this.completedInquiries,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

class UserStats extends Equatable {
  final int favoriteCount;
  final int viewedCount;
  final int contactedAgents;

  const UserStats({
    required this.favoriteCount,
    required this.viewedCount,
    required this.contactedAgents,
  });

  @override
  List<Object> get props => [favoriteCount, viewedCount, contactedAgents];

  UserStats copyWith({
    int? favoriteCount,
    int? viewedCount,
    int? contactedAgents,
  }) {
    return UserStats(
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewedCount: viewedCount ?? this.viewedCount,
      contactedAgents: contactedAgents ?? this.contactedAgents,
    );
  }
}

class AuthResult extends Equatable {
  final bool success;
  final String? error;
  final UserProfile? user;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.success(UserProfile user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult(success: false, error: error);
  }

  @override
  List<Object?> get props => [success, error, user];
}