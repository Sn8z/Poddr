import 'package:flutter/material.dart';
import 'package:poddr/ui/components/audio/loading.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatelessWidget {
  final double size;

  const PlayButton({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = context.select<MediaProvider, bool>(
      (provider) => provider.playbackState.value.playing,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().playOrPause();
        },
        child: SizedBox.fromSize(
          size: Size.square(size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Positioned.fill(
                child: LoadingIndicator(size: size),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
