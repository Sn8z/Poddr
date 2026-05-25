import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
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

    return PoddrIconButton(
      icon: HugeIcon(icon: HugeIcons.strokeRoundedShuffle),
      size: size,
      padding: 0,
      color:
          isShuffling ? context.theme.primary : context.theme.onSurfaceVariant,
      onPressed: () => context.read<MediaProvider>().cycleShuffleMode(),
      semanticLabel: isShuffling ? 'Shuffle on' : 'Shuffle off',
    );
  }
}
