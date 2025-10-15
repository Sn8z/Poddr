import 'package:flutter/material.dart';
import 'package:poddr/services/media.dart';
import 'package:provider/provider.dart';

class PreviousButton extends StatelessWidget {
  final double size;

  const PreviousButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Enable/disable based on whether there is a previous item in the queue
    //final bool isSkippable = context.select<MediaProvider, bool>(
    //  (provider) => provider.playbackState.que,
    //);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().skipToPrevious();
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
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.skip_previous_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
