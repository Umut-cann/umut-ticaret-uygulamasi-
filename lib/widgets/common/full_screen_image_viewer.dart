import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    required this.imageUrls,
    this.initialIndex = 0,
    super.key,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int _currentIndex;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Arka plan beyaz yapıldı
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar arka planı beyaz
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black87,
          ), // İkon rengi siyah
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ), // Yazı rengi siyah
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            carouselController: _controller,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              enableInfiniteScroll: widget.imageUrls.length > 1,
              initialPage: widget.initialIndex,
              autoPlay: false, // Explicitly disable auto-play to prevent crash
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIdx) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                  // Get device screen size for cache dimensions
                  memCacheWidth: MediaQuery.of(context).size.width.toInt(),
                  memCacheHeight: MediaQuery.of(context).size.height.toInt(),
                  // Use imageBuilder for safer rendering
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error_outline, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          // Küçük Resim Önizlemeleri
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child: Container(
                height: 80.0, // Önizleme yüksekliği artırıldı
                alignment: Alignment.center,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(index),
                      child: Container(
                        width: 70.0, // Genişlik artırıldı
                        height: 70.0, // Yükseklik artırıldı
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color:
                                _currentIndex == index
                                    ? Colors
                                        .grey // Seçili kenarlık rengi gri yapıldı
                                    : Colors.transparent,
                            width: 2.5, // Kenarlık biraz kalınlaştırıldı
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrls[index],
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 200),
                            fadeOutDuration: const Duration(milliseconds: 200),
                            // Fixed thumbnail dimensions
                            memCacheWidth: 140, // 2x size for high resolution
                            memCacheHeight: 140,
                            // Use imageBuilder for safer rendering
                            imageBuilder: (context, imageProvider) => Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              color: AppColors.lightGrey.withOpacity(0.5),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
