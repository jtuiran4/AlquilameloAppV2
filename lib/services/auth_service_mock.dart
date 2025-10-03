// Servicio de autenticación deshabilitado - versión simplificada
class AuthService {
  // Usuario mock para desarrollo sin autenticación
  static const String mockUserId = 'demo-user-123';
  static const Map<String, dynamic> mockUser = {
    'uid': mockUserId,
    'fullName': 'Usuario Demo',
    'email': 'demo@alquilamelo.com',
    'phone': '+57 300 123 4567',
    'profileImageUrl': '',
  };

  // Simular usuario actual
  get currentUser => mockUser;

  // Stream mock del estado de autenticación
  Stream<Map<String, dynamic>?> get authStateChanges => 
      Stream.value(mockUser);

  // Métodos mock que siempre retornan éxito
  Future<Map<String, dynamic>?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay
    return mockUser;
  }

  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return mockUser;
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 300));
    // No hacer nada, mantener sesión activa
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true; // Siempre exitoso
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    await Future.delayed(Duration(milliseconds: 300));
    return mockUser;
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }
}