import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';

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

    final label = isLoading
        ? 'Loading'
        : isPlaying
            ? 'Pause'
            : 'Play';
    final icon = isLoading
        ? PoddrSpinner(size: size * 0.4, strokeWidth: 2)
        : HugeIcon(
            icon: isPlaying
                ? HugeIcons.strokeRoundedPause
                : HugeIcons.strokeRoundedPlay,
            color: context.theme.onSurface,
            size: size * 0.5,
          );

    return Semantics(
      label: label,
      button: true,
      enabled: true,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            context.read<MediaProvider>().playOrPause();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
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
                        color: context.theme.surfaceContainer,
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
                  Center(child: icon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
