import 'package:flutter/material.dart';
import 'package:poddr/components/audio/loading.dart';
import 'package:poddr/providers/media.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, this.size = 48});
  final double size;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isPlaying = context
        .select<MediaProvider, bool>((e) => e.playbackState.value.playing);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) => setState(
        () => _isHovered = true,
      ),
      onExit: (event) => setState(
        () => _isHovered = false,
      ),
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().playOrPause();
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transformAlignment: Alignment.center,
                  transform: _isHovered
                      ? (Matrix4.identity()..scale(1.1))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              blurRadius: 16,
                              spreadRadius: -4,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              Center(
                child: isPlaying == true
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
              ),
              Positioned.fill(
                child: LoadingIndicator(size: widget.size),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
