import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';

class PlayerViewButton extends StatelessWidget {
  final double size;
  const PlayerViewButton({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return PoddrIconButton(
      onPressed: () {
        context.push('/player');
      },
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedExpand,
      ),
      size: size,
    );
  }
}
