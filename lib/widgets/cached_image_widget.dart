import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: DefaultCacheManager(),
      placeholder: (context, url) => placeholder ?? 
        Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ?? 
        Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          ),
        ),
      memCacheWidth: 800, // Giới hạn kích thước cache để tiết kiệm RAM
      memCacheHeight: 600,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class CachedImageListWidget extends StatelessWidget {
  final List<String> imageUrls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showPageIndicator;

  const CachedImageListWidget({
    super.key,
    required this.imageUrls,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showPageIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return CachedImageWidget(
              imageUrl: imageUrls[index],
              width: width,
              height: height,
              fit: fit,
              borderRadius: borderRadius,
            );
          },
        ),
        if (showPageIndicator && imageUrls.length > 1)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1 / ${imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
