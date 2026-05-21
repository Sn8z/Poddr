import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:provider/provider.dart';

class ShuffleButton extends StatelessWidget {
  final double size;

  const ShuffleButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool isShuffling =
        context.select<MediaProvider, bool>((e) => e.isShuffling);

    final color = isShuffling
        ? context.theme.primary
        : context.theme.onSurfaceVariant.withAlpha(50);

    final Widget icon =
        HugeIcon(icon: HugeIcons.strokeRoundedShuffle, color: color);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().cycleShuffleMode();
        },
        child: SizedBox.fromSize(
          size: Size.square(size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
