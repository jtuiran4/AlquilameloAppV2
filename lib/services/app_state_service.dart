import 'package:flutter/foundation.dart';
import 'auth_service_mock.dart';

class AppStateService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  bool _isDatabaseInitialized = false;
  
  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isDatabaseInitialized => _isDatabaseInitialized;

  AppStateService() {
    _init();
  }

  // Inicializar el servicio
  Future<void> _init() async {
    _setLoading(true);
    
    // Escuchar cambios de autenticación (mock)
    _authService.authStateChanges.listen((Map<String, dynamic>? user) {
      _currentUser = user;
      notifyListeners();
    });
    
    _setLoading(false);
  }



  // Cambiar estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Métodos de autenticación
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _setLoading(true);
    
    Map<String, dynamic>? user = await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    
    _setLoading(false);
    return user != null;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    Map<String, dynamic>? user = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    _setLoading(false);
    return user != null;
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    
    bool success = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    
    _setLoading(false);
    return success;
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    
    bool success = await _authService.resetPassword(email);
    
    _setLoading(false);
    return success;
  }

  // Obtener datos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    return await _authService.getUserData();
  }

  // Actualizar datos del usuario
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    _setLoading(true);
    
    bool success = await _authService.updateUserData(data);
    
    _setLoading(false);
    return success;
  }


}