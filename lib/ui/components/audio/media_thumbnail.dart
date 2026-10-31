import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final videoController = context
        .select<MediaProvider, VideoController?>((p) => p.videoController);
    final hasVideo = context.select<MediaProvider, bool>((p) => p.hasVideo);
    final artwork = context.select<MediaProvider, String>((p) => p.artwork);

    Widget content;
    if (hasVideo && videoController != null) {
      content = Video(
        controller: videoController,
        fit: BoxFit.contain,
        controls: NoVideoControls,
      );
    } else {
      content = PoddrImage(imageUrl: artwork, maxHeightDiskCache: 300);
    }

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: content,
    );
  }
}
