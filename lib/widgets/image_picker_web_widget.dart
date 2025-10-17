import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/imagekit_web_service.dart';

class ImagePickerWebWidget extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;
  final int maxImages;
  final String title;

  const ImagePickerWebWidget({
    super.key,
    required this.onImagesSelected,
    this.maxImages = 5,
    this.title = 'Seleccionar imágenes',
  });

  @override
  State<ImagePickerWebWidget> createState() => _ImagePickerWebWidgetState();
}

class _ImagePickerWebWidgetState extends State<ImagePickerWebWidget> {
  final ImageKitWebService _imageService = ImageKitWebService();
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_selectedImages.length}/${widget.maxImages}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Grid de imágenes seleccionadas
        if (_selectedImages.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: _selectedImages[index].readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 100,
                                  height: 120,
                                  fit: BoxFit.cover,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading || _selectedImages.length >= widget.maxImages
                    ? null
                    : _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_selectedImages.isEmpty 
                    ? 'Seleccionar imágenes' 
                    : 'Agregar más'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _clearImages,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),

        // Indicador de carga
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),

        // Información adicional
        if (_selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '✅ ${_selectedImages.length} imagen${_selectedImages.length > 1 ? 'es' : ''} seleccionada${_selectedImages.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  // Seleccionar múltiples imágenes
  Future<void> _pickImages() async {
    if (_selectedImages.length >= widget.maxImages) {
      _showSnackBar('Máximo ${widget.maxImages} imágenes permitidas');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final int remainingSlots = widget.maxImages - _selectedImages.length;
      final List<XFile> newImages = await _imageService.pickMultipleImages(
        maxImages: remainingSlots,
      );

      if (newImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(newImages);
        });
        
        widget.onImagesSelected(_selectedImages);
        _showSnackBar('${newImages.length} imagen${newImages.length > 1 ? 'es' : ''} agregada${newImages.length > 1 ? 's' : ''}');
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar imágenes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Remover imagen específica
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
    _showSnackBar('Imagen eliminada');
  }

  // Limpiar todas las imágenes
  void _clearImages() {
    setState(() {
      _selectedImages.clear();
    });
    widget.onImagesSelected(_selectedImages);
    _showSnackBar('Todas las imágenes eliminadas');
  }

  // Mostrar mensaje
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}