import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gara.dart';

class GaraDetailView extends StatefulWidget {
  final Gara gara;
  const GaraDetailView({super.key, required this.gara});

  @override
  State<GaraDetailView> createState() => _GaraDetailViewState();
}

class _GaraDetailViewState extends State<GaraDetailView> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.gara.imageUrls;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 1024,
        height: 640,
        child: Row(
          children: [
            // Gallery
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                child: images.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có ảnh',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : PhotoViewGallery.builder(
                        pageController: _pageController,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemCount: images.length,
                        builder: (context, index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: CachedNetworkImageProvider(images[index]),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2,
                          );
                        },
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      ),
              ),
            ),
            // Info panel
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.gara.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          tooltip: 'Đóng',
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    _kv('Địa chỉ', widget.gara.address),
                    const SizedBox(height: 6),
                    _kv('Chủ gara', widget.gara.ownerName),
                    const SizedBox(height: 6),
                    _kv('Số điện thoại', widget.gara.phoneNumbers.join(', ')),
                    const SizedBox(height: 6),
                    _kv('Trạng thái', widget.gara.status ?? 'Hoạt động'),
                    const Divider(height: 24),
                    if (images.isNotEmpty) ...[
                      const Text('Ảnh xem nhanh:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isActive = index == _currentIndex;
                            return InkWell(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                                setState(() => _currentIndex = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: images[index],
                                    width: 120,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    placeholder: (c, _) => Container(
                                      color: Colors.grey[200],
                                      width: 120,
                                      height: 96,
                                    ),
                                    errorWidget: (c, _, __) => Container(
                                      color: Colors.grey[200],
                                      width: 120,
                                      height: 96,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(k, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(v)),
      ],
    );
  }
}
