import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class VolumeSlider extends StatelessWidget {
  final double size;
  const VolumeSlider({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.sizeOf(context).width);
    final volume = context.select<MediaProvider, double>((e) => e.volume);

    if (isDesktop) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          inactiveTrackColor: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50),
        ),
        child: Slider(
          value: volume,
          min: 0.0,
          max: 100.0,
          onChanged: (double value) {
            context.read<MediaProvider>().setVolume(value);
          },
        ),
      );
    }

    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return PoddrDialog(
              children: [
                Selector<MediaProvider, double>(
                  selector: (_, mediaProvider) => mediaProvider.volume,
                  builder: (context, volume, child) {
                    return Slider(
                      value: volume,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (double value) {
                        context.read<MediaProvider>().setVolume(value);
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      icon: Icon(
        Icons.volume_up,
        color: Theme.of(context).colorScheme.onSurface,
        size: size,
      ),
    );
  }
}
