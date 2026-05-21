import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
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

    FaIconData icon;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        icon = FontAwesomeIcons.repeat;
        break;
      case AudioServiceRepeatMode.one:
        icon = FontAwesomeIcons.repeat;
        break;
      case AudioServiceRepeatMode.all:
        icon = FontAwesomeIcons.repeat;
        break;
      default:
        icon = FontAwesomeIcons.repeat;
        break;
    }

    final color = repeatMode != AudioServiceRepeatMode.none
        ? context.theme.primary
        : context.theme.onSurfaceVariant.withAlpha(50);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<MediaProvider>().cycleRepeatMode();
        },
        child: SizedBox.fromSize(
          size: Size.square(size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: FaIcon(
                  icon,
                  size: size * 0.8,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
