import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class MediaDisplay extends StatelessWidget {
  const MediaDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final videoController = mediaProvider.videoController;
    final hasVideo = mediaProvider.hasVideo;

    if (hasVideo && videoController != null) {
      return Video(
        controller: videoController,
        fit: BoxFit.contain,
        controls: (state) {
          return Builder(
            builder: (context) {
              final isFull = isFullscreen(context);
              if (isFull) {
                return AdaptiveVideoControls(state);
              } else {
                return Stack(
                  children: [
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => enterFullscreen(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0x8A000000),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.maximize,
                            color: Color(0xFFFFFFFF),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      );
    } else {
      return PoddrImage(imageUrl: mediaProvider.artwork);
    }
  }
}
