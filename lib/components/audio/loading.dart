import 'package:flutter/material.dart';
import 'package:poddr/providers/media.dart';
import 'package:provider/provider.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        context.select<MediaProvider, bool>((e) => e.isLoading);

    return isLoading
        ? SizedBox(
            height: size,
            width: size,
            child: const CircularProgressIndicator(),
          )
        : const SizedBox.shrink();
  }
}
