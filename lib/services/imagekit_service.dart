import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../config/imagekit_config.dart';

class ImageKitService {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();

  ImageKitService() {
    // Verificar configuración al instanciar
    if (!ImageKitConfig.isConfigured) {
      throw Exception(ImageKitConfig.configurationInstructions);
    }
  }

  // Seleccionar imagen desde galería o cámara
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      return null;
    }
  }

  // Generar firma para autenticación
  String _generateSignature(String timestamp, String fileName) {
    final token = '$timestamp$fileName${ImageKitConfig.privateKey}';
    final bytes = utf8.encode(token);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // Subir imagen a ImageKit (GRATIS - 20GB/mes)
  Future<String> uploadImage(File imageFile) async {
    try {
      if (!ImageKitConfig.isConfigured) {
        throw Exception('ImageKit no configurado.\n\n${ImageKitConfig.configurationInstructions}');
      }

      // Verificar tamaño del archivo
      final fileSize = await imageFile.length();
      final fileSizeInMB = fileSize / (1024 * 1024);
      if (fileSizeInMB > ImageKitConfig.maxImageSize) {
        throw Exception('La imagen es muy grande. Máximo ${ImageKitConfig.maxImageSize}MB');
      }

      final fileName = 'alquilamelo_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateSignature(timestamp, fileName);

      print('📤 Subiendo imagen: $fileName');
      print('  Tamaño: ${fileSizeInMB.toStringAsFixed(2)}MB');
      
      // Preparar FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'fileName': fileName,
        'folder': '/alquilamelo_properties/',
        'publicKey': ImageKitConfig.publicKey,
        'signature': signature,
        'expire': timestamp,
      });

      // Subir a ImageKit
      final response = await _dio.post(
        ImageKitConfig.uploadEndpoint,
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final imageUrl = response.data['url'] as String;
        print('✅ Imagen subida exitosamente a ImageKit: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Error en respuesta de ImageKit: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception('Límite mensual excedido (${ImageKitConfig.monthlyStorage}GB)');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Error de autenticación. Verifica tu configuración de ImageKit');
      } else {
        throw Exception('Error de red al subir imagen: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen a ImageKit: $e');
    }
  }

  // Subir múltiples imágenes
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, {Function(int, int)? onProgress}) async {
    List<String> imageUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final imageUrl = await uploadImage(imageFiles[i]);
        imageUrls.add(imageUrl);
        
        // Callback de progreso
        if (onProgress != null) {
          onProgress(i + 1, imageFiles.length);
        }
        
        print('✅ Imagen ${i + 1}/${imageFiles.length} subida correctamente');
      } catch (e) {
        print('❌ Error subiendo imagen ${i + 1}: $e');
        // Continuar con las siguientes imágenes en caso de error
      }
    }
    
    return imageUrls;
  }

  // Mostrar diálogo para seleccionar fuente de imagen
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: const Text('¿De dónde quieres obtener la imagen?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final File? image = await pickImage(source: ImageSource.gallery);
                if (context.mounted) {
                  Navigator.pop(context, image);
                }
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final File? image = await pickImage(source: ImageSource.camera);
                if (context.mounted) {
                  Navigator.pop(context, image);
                }
              },
              child: const Text('Cámara'),
            ),
          ],
        );
      },
    );
  }
}