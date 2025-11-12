import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:alquilamelo_app/features/shared/domain/datasources/imagekit_datasource.dart';
import 'package:alquilamelo_app/core/imagekit_config.dart';

class ImageKitDataSourceImpl implements ImageKitDataSource {
  final Dio _dio;

  ImageKitDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio() {
    // ? Verificar configuración al inicializar
    if (!ImageKitConfig.isConfigured) {
      throw Exception(ImageKitConfig.configurationInstructions);
    }

    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  String _generateSignature(String token, String expire) {
    final signatureString = '${ImageKitConfig.privateKey}$token$expire';
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  @override
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
        final imageUrl = responseData['url'];

        if (imageUrl != null) {
          print('? Imagen subida exitosamente: $imageUrl');
          return imageUrl;
        } else {
          throw Exception('URL de imagen no encontrada en respuesta');
        }
      } else {
        throw Exception('Error en upload: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('? Error subiendo imagen: $e');
      throw Exception('Error subiendo imagen: $e');
    }
  }
}