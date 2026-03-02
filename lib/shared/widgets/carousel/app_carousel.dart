//updated version

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

import '../../../core/themes/app_colors.dart';
import '../progress_loader/progress_loader.dart';
import '../spacer/app_spacer.dart';

typedef OnSlideChanged = void Function(int index);

enum _ImageSource { network, asset }

class AppCarousel extends StatelessWidget {
  // Common
  final List<String> _images;
  final _ImageSource _source;

  final int currentIndex;
  final OnSlideChanged onSlideChanged;
  final double aspectRatio;
  final bool autoPlay;
  final double viewportFraction;
  final double enlargeCenterPageRadius;
  final Widget? firstItem;
  final Duration? autoPlayInterval;
  final List<Widget>? belowItems;
  final List<List<Widget>>? belowItemsPerSlide;

  // NEW: toggle dot indicators
  final bool showDots;

  /// Creates a carousel with network images
  const AppCarousel({
    super.key,
    required List<String> imageUrls,
    required this.currentIndex,
    required this.onSlideChanged,
    this.aspectRatio = 2.5,
    this.autoPlay = true,
    this.viewportFraction = 1.0,
    this.enlargeCenterPageRadius = 5.0,
    this.firstItem,
    this.autoPlayInterval,
    this.belowItems,
    this.belowItemsPerSlide,
    this.showDots = true, // <—
  }) : _images = imageUrls,
       _source = _ImageSource.network;

  /// Creates a carousel with asset images
  factory AppCarousel.assets({
    Key? key,
    required List<String> assetPaths,
    required int currentIndex,
    required OnSlideChanged onSlideChanged,
    double aspectRatio = 2.5,
    bool autoPlay = true,
    double viewportFraction = 1.0,
    double enlargeCenterPageRadius = 5.0,
    Widget? firstItem,
    Duration? autoPlayInterval,
    List<Widget>? belowItems,
    List<List<Widget>>? belowItemsPerSlide,
    bool showDots = true, // <—
  }) {
    return AppCarousel._internal(
      key: key,
      images: assetPaths,
      source: _ImageSource.asset,
      currentIndex: currentIndex,
      onSlideChanged: onSlideChanged,
      aspectRatio: aspectRatio,
      autoPlay: autoPlay,
      viewportFraction: viewportFraction,
      enlargeCenterPageRadius: enlargeCenterPageRadius,
      firstItem: firstItem,
      autoPlayInterval: autoPlayInterval,
      belowItems: belowItems,
      belowItemsPerSlide: belowItemsPerSlide,
      showDots: showDots, // <—
    );
  }

  const AppCarousel._internal({
    super.key,
    required List<String> images,
    required _ImageSource source,
    required this.currentIndex,
    required this.onSlideChanged,
    this.aspectRatio = 2.5,
    this.autoPlay = true,
    this.viewportFraction = 1.0,
    this.enlargeCenterPageRadius = 5.0,
    this.firstItem,
    this.autoPlayInterval,
    this.belowItems,
    this.belowItemsPerSlide,
    this.showDots = true, // <—
  }) : _images = images,
       _source = source;

  @override
  Widget build(BuildContext context) {
    final List<Widget> carouselItems = [];

    if (firstItem != null) {
      carouselItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: firstItem!,
        ),
      );
    }

    carouselItems.addAll(
      _images.map((path) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(enlargeCenterPageRadius),
            ),
            child: _buildImage(path),
          ),
        );
      }),
    );

    return Column(
      children: [
        // Carousel itself
        CarouselSlider(
          items: carouselItems,
          options: CarouselOptions(
            autoPlay: autoPlay,
            enlargeCenterPage: true,
            aspectRatio: aspectRatio,
            viewportFraction: viewportFraction,
            autoPlayInterval: autoPlayInterval ?? const Duration(seconds: 4),
            onPageChanged: (index, reason) => onSlideChanged(index),
          ),
        ),

        // Dots (conditionally shown)
        if (showDots) ...[
          addSpacer(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(carouselItems.length, (index) {
              final isSelected = currentIndex == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  isSelected ? Icons.circle : Icons.circle_outlined,
                  size: isSelected ? 10 : 8,
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                ),
              );
            }),
          ),
        ],

        // Dynamic widgets per-slide
        if (belowItemsPerSlide != null &&
            belowItemsPerSlide!.isNotEmpty &&
            currentIndex < belowItemsPerSlide!.length &&
            belowItemsPerSlide![currentIndex].isNotEmpty) ...[
          addSpacer(8),
          ...belowItemsPerSlide![currentIndex],
        ]
        // Static global widgets
        else if (belowItems != null && belowItems!.isNotEmpty) ...[
          addSpacer(8),
          ...belowItems!,
        ],
      ],
    );
  }

  Widget _buildImage(String path) {
    switch (_source) {
      case _ImageSource.asset:
        return Image.asset(
          path,
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stack) => const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      case _ImageSource.network:
        return CachedNetworkImage(
          imageUrl: path,
          fit: BoxFit.cover,
          width: double.infinity,
          progressIndicatorBuilder: (context, url, progress) {
            final value = progress.progress;
            return Center(
              child: showLoader(
                value: value,
                progressColor: AppColors.primaryColor,
              ),
            );
          },
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
    }
  }
}

// old version

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider_plus/carousel_slider_plus.dart';
//
// import '../../../core/themes/app_colors.dart';
// import '../progress_loader/progress_loader.dart';
// import '../spacer/app_spacer.dart';
//
// typedef OnSlideChanged = void Function(int index);
//
// enum _ImageSource { network, asset }
//
// class AppCarousel extends StatelessWidget {
//   // Common
//   final List<String> _images;
//   final _ImageSource _source;
//
//   final int currentIndex;
//   final OnSlideChanged onSlideChanged;
//   final double aspectRatio;
//   final bool autoPlay;
//   final double viewportFraction;
//   final double enlargeCenterPageRadius;
//   final Widget? firstItem;
//   final Duration? autoPlayInterval;
//   final List<Widget>? belowItems;
//   final List<List<Widget>>? belowItemsPerSlide;
//
//   /// Creates a carousel with network images
//   const AppCarousel({
//     super.key,
//     required List<String> imageUrls,
//     required this.currentIndex,
//     required this.onSlideChanged,
//     this.aspectRatio = 2.5,
//     this.autoPlay = true,
//     this.viewportFraction = 1.0,
//     this.enlargeCenterPageRadius = 5.0,
//     this.firstItem,
//     this.autoPlayInterval,
//     this.belowItems,
//     this.belowItemsPerSlide,
//   })  : _images = imageUrls,
//         _source = _ImageSource.network;
//
//   /// Creates a carousel with asset images
//   factory AppCarousel.assets({
//     Key? key,
//     required List<String> assetPaths,
//     required int currentIndex,
//     required OnSlideChanged onSlideChanged,
//     double aspectRatio = 2.5,
//     bool autoPlay = true,
//     double viewportFraction = 1.0,
//     double enlargeCenterPageRadius = 5.0,
//     Widget? firstItem,
//     Duration? autoPlayInterval,
//     List<Widget>? belowItems,
//     List<List<Widget>>? belowItemsPerSlide,
//   }) {
//     return AppCarousel._internal(
//       key: key,
//       images: assetPaths,
//       source: _ImageSource.asset,
//       currentIndex: currentIndex,
//       onSlideChanged: onSlideChanged,
//       aspectRatio: aspectRatio,
//       autoPlay: autoPlay,
//       viewportFraction: viewportFraction,
//       enlargeCenterPageRadius: enlargeCenterPageRadius,
//       firstItem: firstItem,
//       autoPlayInterval: autoPlayInterval,
//       belowItems: belowItems,
//       belowItemsPerSlide: belowItemsPerSlide,
//     );
//   }
//
//   const AppCarousel._internal({
//     super.key,
//     required List<String> images,
//     required _ImageSource source,
//     required this.currentIndex,
//     required this.onSlideChanged,
//     this.aspectRatio = 2.5,
//     this.autoPlay = true,
//     this.viewportFraction = 1.0,
//     this.enlargeCenterPageRadius = 5.0,
//     this.firstItem,
//     this.autoPlayInterval,
//     this.belowItems,
//     this.belowItemsPerSlide,
//   })  : _images = images,
//         _source = source;
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> carouselItems = [];
//
//     if (firstItem != null) {
//       carouselItems.add(
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 5.0),
//           child: firstItem!,
//         ),
//       );
//     }
//
//     carouselItems.addAll(_images.map((path) {
//       return Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.all(
//             Radius.circular(enlargeCenterPageRadius),
//           ),
//           child: _buildImage(path),
//         ),
//       );
//     }));
//
//     return Column(
//       children: [
//         // Carousel itself
//         CarouselSlider(
//           items: carouselItems,
//           options: CarouselOptions(
//             autoPlay: autoPlay,
//             enlargeCenterPage: true,
//             aspectRatio: aspectRatio,
//             viewportFraction: viewportFraction,
//             autoPlayInterval: autoPlayInterval ?? const Duration(seconds: 4),
//             onPageChanged: (index, reason) => onSlideChanged(index),
//           ),
//         ),
//
//         addSpacer(8),
//
//         // Dots
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             carouselItems.length,
//                 (index) {
//               final isSelected = currentIndex == index;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                 child: Icon(
//                   isSelected ? Icons.circle : Icons.circle_outlined,
//                   size: isSelected ? 10 : 8,
//                   color: isSelected
//                       ? AppColors.primaryColor
//                       : Colors.grey.shade400,
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // Dynamic widgets per-slide
//         if (belowItemsPerSlide != null &&
//             belowItemsPerSlide!.isNotEmpty &&
//             currentIndex < belowItemsPerSlide!.length &&
//             belowItemsPerSlide![currentIndex].isNotEmpty) ...[
//           addSpacer(8),
//           ...belowItemsPerSlide![currentIndex],
//         ]
//
//         // Static global widgets
//         else if (belowItems != null && belowItems!.isNotEmpty) ...[
//           addSpacer(8),
//           ...belowItems!,
//         ],
//       ],
//     );
//   }
//
//   Widget _buildImage(String path) {
//     switch (_source) {
//       case _ImageSource.asset:
//         return Image.asset(
//           path,
//           fit: BoxFit.contain,
//           width: double.infinity,
//           errorBuilder: (context, error, stack) => const Center(
//             child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
//           ),
//         );
//       case _ImageSource.network:
//         return CachedNetworkImage(
//           imageUrl: path,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           progressIndicatorBuilder: (context, url, progress) {
//             final value = progress.progress;
//             return Center(
//               child: showLoader(
//                 value: value,
//                 progressColor: AppColors.primaryColor,
//               ),
//             );
//           },
//           errorWidget: (context, url, error) => const Center(
//             child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
//           ),
//         );
//     }
//   }
// }
