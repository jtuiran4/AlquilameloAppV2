import 'package:flutter/material.dart';
import '../models/app_models.dart';

class PropertyImageCarousel extends StatefulWidget {
  final Property property;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? overlayWidget;

  const PropertyImageCarousel({
    super.key,
    required this.property,
    this.height = 200,
    this.borderRadius,
    this.overlayWidget,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  int _currentImageIndex = 0;

  List<String> get _allImages {
    List<String> images = [];
    
    // Agregar imagen principal si existe
    if (widget.property.imageUrl.isNotEmpty) {
      images.add(widget.property.imageUrl);
    }
    
    // Agregar imágenes adicionales
    images.addAll(widget.property.imageUrls);
    
    // Remover duplicados y URLs vacías
    return images.where((url) => url.isNotEmpty).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    
    // Si no hay imágenes, mostrar placeholder
    if (images.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: widget.borderRadius,
        ),
        child: const Center(
          child: Icon(
            Icons.home,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Si solo hay una imagen, mostrarla directamente
    if (images.length == 1) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: _buildSingleImage(images.first),
          ),
          if (widget.overlayWidget != null) widget.overlayWidget!,
        ],
      );
    }
    
    // Si hay múltiples imágenes, mostrar carrusel
    return Stack(
      children: [
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: _buildSingleImage(images[_currentImageIndex]),
        ),
        
        // Flechas de navegación (más pequeñas para las tarjetas)
        if (_currentImageIndex > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex--;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        
        if (_currentImageIndex < images.length - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex++;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        
        // Puntos indicadores (solo si hay múltiples imágenes)
        if (images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        
        // Overlay widget si se proporciona
        if (widget.overlayWidget != null) widget.overlayWidget!,
      ],
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: widget.height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: widget.height,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: widget.height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.home,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }
}