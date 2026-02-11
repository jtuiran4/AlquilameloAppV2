// Configuración de ImageKit para AlquilameloApp
// INSTRUCCIONES:
// 1. Ve a https://imagekit.io/registration
// 2. Regístrate gratis (sin tarjeta de crédito)
// 3. En el dashboard, ve a "Developer options" → "API Keys"
// 4. Copia los datos y pégalos aquí:

class ImageKitConfig {
  // 🔧 Reemplaza con tus datos de ImageKit
  static const String publicKey = '';
  static const String urlEndpoint = '';
  static const String privateKey = '';
  
  // URLs de la API
  static const String uploadEndpoint = 'https://upload.imagekit.io/api/v1/files/upload';
  
  // ✅ Validar configuración
  static bool get isConfigured {
    return publicKey != 'TU_PUBLIC_KEY_AQUI' && 
           privateKey != 'TU_PRIVATE_KEY_AQUI' &&
           urlEndpoint != 'https://ik.imagekit.io/TU_ID_AQUI/';
  }
  
  // 📝 Instrucciones de configuración
  static String get configurationInstructions {
    return '''
Para configurar ImageKit:
1. Ve a https://imagekit.io/registration
2. Regístrate gratis (sin tarjeta de crédito)
3. En el dashboard, ve a "Developer options" → "API Keys"
4. Copia los datos y actualiza los valores en imagekit_config.dart
''';
  }
  
  // 📊 Límites (plan gratuito)
  static const int monthlyStorage = 20; // GB por mes
  static const int monthlyBandwidth = 10; // GB por mes
  static const int maxImageSize = 25; // MB por imagen
  
}
