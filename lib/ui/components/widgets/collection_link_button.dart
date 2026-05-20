import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/dialogs/poddr_collection_selection_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';

class PoddrCollectionLinkButton extends StatelessWidget {
  const PoddrCollectionLinkButton({super.key, required this.subscriptionId});
  final int subscriptionId;

  @override
  Widget build(BuildContext context) {
    return PoddrFilledButton(
      onPressed: () {
        showPoddrDialog(
          context: context,
          builder: (context) => PoddrDialog(
            header: Text(
              'Add to Collection',
              style: context.theme.textTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.secondary,
              ),
            ),
            child: PoddrCollectionSelectionDialog(
              subscriptionId: subscriptionId,
            ),
          ),
        );
      },
      child: const Icon(LucideIcons.plus, size: 20),
    );
  }
}
