import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media.dart';

class Artwork extends StatelessWidget {
  const Artwork({super.key});

  @override
  Widget build(BuildContext context) {
    Uri? artUri =
        context.select<MediaProvider, Uri?>((e) => e.mediaItem.value?.artUri);
    String? podcastRSS = context.select<MediaProvider, String?>(
        (e) => e.mediaItem.value?.extras?["podcastRSS"]);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () {
            if (podcastRSS != null) {
              final rss = Uri.encodeComponent(podcastRSS);
              context.go("/podcasts/$rss");
            }
          },
          child: PoddrImage(imageUrl: artUri.toString())),
    );
  }
}
