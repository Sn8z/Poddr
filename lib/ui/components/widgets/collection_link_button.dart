import 'package:flutter/material.dart';
import 'package:poddr/ui/components/dialogs/poddr_collection_selection_dialog.dart';

class PoddrCollectionLinkButton extends StatelessWidget {
  const PoddrCollectionLinkButton({super.key, required this.subscriptionId});
  final int subscriptionId;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => PoddrCollectionSelectionDialog(
            subscriptionId: subscriptionId,
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
