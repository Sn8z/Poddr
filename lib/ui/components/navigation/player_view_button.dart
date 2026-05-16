import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';

class PlayerViewButton extends StatelessWidget {
  final double size;
  const PlayerViewButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return PoddrIconButton(
      onPressed: () {
        context.push('/player');
      },
      icon: Icon(
        LucideIcons.monitor,
        size: size,
      ),
      size: size,
    );
  }
}
