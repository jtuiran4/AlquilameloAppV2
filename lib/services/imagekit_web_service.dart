import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../config/imagekit_config.dart';

class ImageKitWebService {
  final Dio _dio = Dio();
  final ImagePicker _imagePicker = ImagePicker();

  ImageKitWebService() {
    // ✅ Verificar configuración al inicializar
    if (!ImageKitConfig.isConfigured) {
      throw Exception(ImageKitConfig.configurationInstructions);
    }
    
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Seleccionar imagen desde galería o cámara (WEB)
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('✅ Imagen seleccionada: ${pickedFile.name}');
        return pickedFile;
      }
      return null;
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
      throw Exception('Error al seleccionar imagen: $e');
    }
  }

  // Subir imagen a ImageKit (GRATIS - 20GB/mes) - VERSION WEB
  Future<String> uploadImage(XFile imageFile) async {
    try {
      // Validar configuración
      if (!ImageKitConfig.isConfigured) {
        throw Exception('ImageKit no configurado.\n\n${ImageKitConfig.configurationInstructions}');
      }

      // Leer bytes de la imagen (compatible con Web)
      final fileBytes = await imageFile.readAsBytes();
      final fileSizeInMB = fileBytes.length / (1024 * 1024);
      
      if (fileSizeInMB > ImageKitConfig.maxImageSize) {
        throw Exception('La imagen es muy grande. Máximo ${ImageKitConfig.maxImageSize}MB');
      }

      // Generar datos de autenticación según documentación oficial
      final currentTime = DateTime.now();
      final expireTime = currentTime.add(const Duration(minutes: 30)); 
      final expire = (expireTime.millisecondsSinceEpoch / 1000).round().toString(); // Unix en segundos
      final token = 'token_${currentTime.millisecondsSinceEpoch}'; // Token único
      final fileName = 'alquilamelo_${currentTime.millisecondsSinceEpoch}.jpg';
      final signature = _generateSignature(token, expire);

      print('🔧 DEBUG - Datos de autenticación:');
      print('  Token: $token');
      print('  Expire (Unix seconds): $expire');
      print('  FileName: $fileName');
      print('  PublicKey: ${ImageKitConfig.publicKey}');
      print('  Signature: $signature');

      // Preparar FormData según documentación de ImageKit
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
        'fileName': fileName,
        'publicKey': ImageKitConfig.publicKey,
        'signature': signature,
        'expire': expire,
        'token': token, // Ambos token y expire son necesarios
        'folder': '/alquilamelo_properties/',
      });

      print('📤 Subiendo imagen a ImageKit: $fileName');
      print('🌐 URL: ${ImageKitConfig.uploadEndpoint}');

      // Realizar upload
      final response = await _dio.post(
        ImageKitConfig.uploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['url'] != null) {
          final imageUrl = responseData['url'] as String;
          print('✅ Imagen subida exitosamente: $imageUrl');
          return imageUrl;
        }
      }

      throw Exception('Error en respuesta de ImageKit: ${response.statusCode}');
    } catch (e) {
      print('❌ Error al subir imagen: $e');
      
      // Si es un DioException, mostrar más detalles
      if (e is DioException) {
        print('🔍 DEBUG - Detalles del error:');
        print('  Status Code: ${e.response?.statusCode}');
        print('  Response Data: ${e.response?.data}');
        print('  Request Data: ${e.requestOptions.data}');
        print('  Headers: ${e.requestOptions.headers}');
      }
      
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Subir múltiples imágenes (WEB)
  Future<List<String>> uploadMultipleImages(List<XFile> imageFiles, {Function(int, int)? onProgress}) async {
    try {
      final List<String> imageUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        onProgress?.call(i + 1, imageFiles.length);
        
        final String imageUrl = await uploadImage(imageFiles[i]);
        imageUrls.add(imageUrl);
        
        // Pausa para no sobrecargar
        if (i < imageFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }
      
      print('✅ ${imageUrls.length} imágenes subidas exitosamente');
      return imageUrls;
    } catch (e) {
      throw Exception('Error al subir múltiples imágenes: $e');
    }
  }

  // Mostrar dialog para seleccionar fuente (WEB)
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, image);
                },
              ),
              // En Web, la cámara puede no estar disponible
              if (!kIsWeb) ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await pickImage(source: ImageSource.camera);
                  Navigator.pop(context, image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Seleccionar múltiples imágenes (WEB)
  Future<List<XFile>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (images.length > maxImages) {
        return images.take(maxImages).toList();
      }
      
      return images;
    } catch (e) {
      print('❌ Error al seleccionar múltiples imágenes: $e');
      throw Exception('Error al seleccionar imágenes: $e');
    }
  }

  // Generar firma HMAC-SHA1 según documentación oficial de ImageKit
  String _generateSignature(String token, String expire) {
    // Según documentación: HMAC-SHA1 digest de token+expire usando private key
    final stringToSign = '$token$expire';
    
    print('🔐 DEBUG - String para firma: $stringToSign');
    print('🔐 DEBUG - Private Key: ${ImageKitConfig.privateKey}');
    
    final key = utf8.encode(ImageKitConfig.privateKey);
    final bytes = utf8.encode(stringToSign);
    final hmacSha1 = Hmac(sha1, key);
    final digest = hmacSha1.convert(bytes);
    final signature = digest.toString();
    
    print('🔐 DEBUG - Firma generada: $signature');
    return signature;
  }
}