import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;
  
  // Inicializar SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Verificar si está inicializado
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferences no ha sido inicializado. Llama a SharedPreferencesService.init() primero.');
    }
    return _preferences!;
  }

  // === MÉTODOS PARA STRINGS ===
  static Future<bool> setString(String key, String value) async {
    return await instance.setString(key, value);
  }
  
  static String? getString(String key, {String? defaultValue}) {
    return instance.getString(key) ?? defaultValue;
  }

  // === MÉTODOS PARA INTEGERS ===
  static Future<bool> setInt(String key, int value) async {
    return await instance.setInt(key, value);
  }
  
  static int? getInt(String key, {int? defaultValue}) {
    return instance.getInt(key) ?? defaultValue;
  }

  // === MÉTODOS PARA BOOLEANS ===
  static Future<bool> setBool(String key, bool value) async {
    return await instance.setBool(key, value);
  }
  
  static bool? getBool(String key, {bool? defaultValue}) {
    return instance.getBool(key) ?? defaultValue;
  }

  // === MÉTODOS PARA DOUBLES ===
  static Future<bool> setDouble(String key, double value) async {
    return await instance.setDouble(key, value);
  }
  
  static double? getDouble(String key, {double? defaultValue}) {
    return instance.getDouble(key) ?? defaultValue;
  }

  // === MÉTODOS PARA LISTAS DE STRINGS ===
  static Future<bool> setStringList(String key, List<String> value) async {
    return await instance.setStringList(key, value);
  }
  
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return instance.getStringList(key) ?? defaultValue;
  }

  // === MÉTODOS GENERALES ===
  // Verificar si existe una key
  static bool containsKey(String key) {
    return instance.containsKey(key);
  }
  
  // Eliminar una key específica
  static Future<bool> remove(String key) async {
    return await instance.remove(key);
  }
  
  // Limpiar todas las preferencias
  static Future<bool> clear() async {
    return await instance.clear();
  }
  
  // Obtener todas las keys
  static Set<String> getKeys() {
    return instance.getKeys();
  }

  // === MÉTODOS ESPECÍFICOS PARA LA APP ===
  
  // Configuración de usuario
  static const String _keyUserRememberLogin = 'user_remember_login';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserTheme = 'user_theme';
  static const String _keyUserLanguage = 'user_language';
  
  // Preferencias de agente
  static const String _keyAgentDashboardView = 'agent_dashboard_view';
  
  // Cache de datos
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyOfflineMode = 'offline_mode';

  // === MÉTODOS ESPECÍFICOS PARA CONFIGURACIÓN DE USUARIO ===
  
  // Recordar login
  static Future<bool> setRememberLogin(bool remember) async {
    return await setBool(_keyUserRememberLogin, remember);
  }
  
  static bool getRememberLogin() {
    return getBool(_keyUserRememberLogin, defaultValue: false) ?? false;
  }
  
  // Email del usuario
  static Future<bool> setUserEmail(String email) async {
    return await setString(_keyUserEmail, email);
  }
  
  static String? getUserEmail() {
    return getString(_keyUserEmail);
  }
  
  // Nombre del usuario
  static Future<bool> setUserName(String name) async {
    return await setString(_keyUserName, name);
  }
  
  static String? getUserName() {
    return getString(_keyUserName);
  }
  
  // Tema de la app
  static Future<bool> setUserTheme(String theme) async {
    return await setString(_keyUserTheme, theme);
  }
  
  static String getUserTheme() {
    return getString(_keyUserTheme, defaultValue: 'light') ?? 'light';
  }
  
  // === MÉTODOS PARA AGENTES ===
  
  // Vista del dashboard del agente
  static Future<bool> setAgentDashboardView(String view) async {
    return await setString(_keyAgentDashboardView, view);
  }
  
  static String getAgentDashboardView() {
    return getString(_keyAgentDashboardView, defaultValue: 'grid') ?? 'grid';
  }
  
  // === MÉTODOS PARA SINCRONIZACIÓN ===
  
  // Última vez que se sincronizó
  static Future<bool> setLastSyncTime(DateTime time) async {
    return await setString(_keyLastSyncTime, time.toIso8601String());
  }
  
  static DateTime? getLastSyncTime() {
    final timeString = getString(_keyLastSyncTime);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }
  
  // Modo offline
  static Future<bool> setOfflineMode(bool offline) async {
    return await setBool(_keyOfflineMode, offline);
  }
  
  static bool getOfflineMode() {
    return getBool(_keyOfflineMode, defaultValue: false) ?? false;
  }

  // === MÉTODOS DE UTILIDAD ===
  
  // Limpiar solo datos de usuario (mantener configuraciones)
  static Future<void> clearUserData() async {
    await remove(_keyUserEmail);
    await remove(_keyUserName);
    await remove(_keyUserRememberLogin);
  }
  
  // Limpiar solo configuraciones (mantener datos de usuario)
  static Future<void> clearSettings() async {
    await remove(_keyUserTheme);
    await remove(_keyUserLanguage);
    await remove(_keyAgentDashboardView);
  }
  
  // Debug: Imprimir todas las preferencias
  static void printAllPreferences() {
    final keys = getKeys();
    print('📱 SharedPreferences contenido:');
    for (String key in keys) {
      final value = instance.get(key);
      print('  $key: $value');
    }
  }
}