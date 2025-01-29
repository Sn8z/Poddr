import 'package:flutter/widgets.dart';
import 'package:poddr/components/ui/shimmer.dart';

class PoddrImage extends StatelessWidget {
  const PoddrImage({
    super.key,
    required this.imageUri,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final Uri imageUri;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = width ?? constraints.maxWidth;
        final imageHeight = height ?? constraints.maxHeight;

        return Image.network(
          imageUri.toString(),
          fit: fit,
          width: imageWidth,
          cacheWidth: imageWidth.toInt(),
          height: imageHeight,
          cacheHeight: imageHeight.toInt(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: frame != null
                  ? child
                  : ShimmerBox(
                      height: imageHeight,
                      width: imageWidth,
                    ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/icon.png",
              fit: BoxFit.cover,
              height: imageHeight,
              cacheHeight: imageHeight.toInt(),
              width: imageWidth,
              cacheWidth: imageWidth.toInt(),
            );
          },
        );
      },
    );
  }
}
