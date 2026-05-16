import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

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

    final bool isLoading = context.select<MediaProvider, bool>(
      (p) => p.isLoading,
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
                        context.theme.surfaceContainerHighest,
                    shape: RoundedSuperellipseBorder(
                      side: BorderSide(
                        color: context.theme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(size / 3),
                    ),
                  ),
                ),
              ),
              Center(
                child: isLoading
                    ? SizedBox(
                        width: size * 0.4,
                        height: size * 0.4,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: context.theme.onSurface,
                        size: size * 0.5,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
