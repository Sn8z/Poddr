import 'package:flutter/material.dart';
import 'package:poddr/ui/components/audio/loading.dart';
import 'package:poddr/services/media/media_provider.dart';
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
      (p) => p.isPlaying,
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
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedSuperellipseBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(size / 3),
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: size * 0.5,
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
