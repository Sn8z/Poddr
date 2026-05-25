import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:provider/provider.dart';

class RepeatButton extends StatelessWidget {
  final double size;

  const RepeatButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final repeatMode = context
        .select<MediaProvider, AudioServiceRepeatMode>((e) => e.repeatMode);

    final isActive = repeatMode != AudioServiceRepeatMode.none;

    Widget icon;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        icon = HugeIcon(icon: HugeIcons.strokeRoundedRepeat);
        break;
      case AudioServiceRepeatMode.one:
        icon = HugeIcon(icon: HugeIcons.strokeRoundedRepeatOne01);
        break;
      case AudioServiceRepeatMode.all:
        icon = HugeIcon(icon: HugeIcons.strokeRoundedRepeat);
        break;
      default:
        icon = HugeIcon(icon: HugeIcons.strokeRoundedRepeat);
        break;
    }

    return PoddrIconButton(
      icon: icon,
      size: size,
      padding: 0,
      color: isActive ? context.theme.primary : context.theme.onSurfaceVariant,
      onPressed: () => context.read<MediaProvider>().cycleRepeatMode(),
      semanticLabel:
          'Repeat: ${repeatMode == AudioServiceRepeatMode.none ? 'off' : repeatMode == AudioServiceRepeatMode.one ? 'one' : 'all'}',
    );
  }
}
