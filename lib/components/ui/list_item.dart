import 'package:flutter/material.dart';

class PoddrListItem extends StatelessWidget {
  const PoddrListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onTap,
    this.actions = const [],
  });
  final String title;
  final String subtitle;
  final Widget leading;
  final VoidCallback onTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.all(8.0),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        overflow: TextOverflow.ellipsis,
      ),
      leading: SizedBox(
        height: 48,
        width: 48,
        child: leading,
      ),
      trailing: actions.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            )
          : null,
      onTap: onTap,
    );
  }
}
