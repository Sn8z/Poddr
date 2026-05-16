import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';

class PlayerViewButton extends StatelessWidget {
  final double size;
  const PlayerViewButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.push('/player');
      },
      icon: Icon(
        Icons.ondemand_video_rounded,
        color: context.theme.onSurface,
        size: size,
      ),
    );
  }
}
