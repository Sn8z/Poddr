import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/core/http_client.dart';

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
    final bool isDark = context.theme.brightness == Brightness.dark;
    final String errorImage = isDark
        ? 'assets/images/logo_dark_bg.png'
        : 'assets/images/logo_light_bg.png';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      httpHeaders: {'User-Agent': PoddrHttpClient.userAgent},
      maxHeightDiskCache: 800,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => const ShimmerBox(),
      errorWidget: (context, url, error) => Image.asset(
        errorImage,
        fit: BoxFit.contain,
      ),
    );
  }
}
