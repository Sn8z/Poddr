import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final videoController = mediaProvider.videoController;
    final hasVideo = mediaProvider.hasVideo;

    Widget content;
    if (hasVideo && videoController != null) {
      content = Video(
        controller: videoController,
        fit: BoxFit.contain,
        controls: NoVideoControls,
      );
    } else {
      content = PoddrImage(imageUrl: mediaProvider.artwork);
    }

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: content,
    );
  }
}
