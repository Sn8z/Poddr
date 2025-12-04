import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class Artwork extends StatelessWidget {
  const Artwork({super.key});

  @override
  Widget build(BuildContext context) {
    String artwork = context.select<MediaProvider, String>((p) => p.artwork);
    String rss = context.select<MediaProvider, String>((p) => p.podcastRSS);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () {
            context.go("/podcasts/${Uri.encodeComponent(rss)}");
          },
          child: PoddrImage(imageUrl: artwork)),
    );
  }
}
