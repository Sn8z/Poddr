import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';

class PoddrImage extends StatelessWidget {
  const PoddrImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ValueKey<String> imageKey = ValueKey('image-$imageUrl');

    final String errorImage = Theme.of(context).brightness == Brightness.light
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_black.png';

    return Image.network(
      imageUrl,
      fit: fit,
      key: imageKey,
      cacheHeight: 500,
      cacheWidth: 500,
      gaplessPlayback: true,
      headers: const {'Cache-Control': 'max-age=604800'},
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const ShimmerBox();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const ShimmerBox();
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          errorImage,
          fit: fit,
        );
      },
    );
  }
}
