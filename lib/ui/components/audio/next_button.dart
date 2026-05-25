import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:provider/provider.dart';

class SkipButton extends StatelessWidget {
  final double size;

  const SkipButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoNext = context.select<MediaProvider, bool>(
      (provider) => provider.canGoNext,
    );

    return PoddrIconButton(
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedForward01,
        size: size * 0.8,
      ),
      size: size,
      padding: 0,
      color: canGoNext ? context.theme.primary : context.theme.onSurfaceVariant,
      onPressed:
          canGoNext ? () => context.read<MediaProvider>().skipToNext() : null,
      semanticLabel: 'Next episode',
    );
  }
}
