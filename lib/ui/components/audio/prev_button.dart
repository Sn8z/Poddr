import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:provider/provider.dart';

class PreviousButton extends StatelessWidget {
  final double size;

  const PreviousButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = context.select<MediaProvider, bool>(
      (provider) => provider.canGoPrevious,
    );

    return PoddrIconButton(
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedBackward01,
        size: size * 0.8,
      ),
      size: size,
      padding: 0,
      color: canGoPrevious
          ? context.theme.primary
          : context.theme.onSurfaceVariant,
      onPressed: canGoPrevious
          ? () => context.read<MediaProvider>().skipToPrevious()
          : null,
      semanticLabel: 'Previous episode',
    );
  }
}
