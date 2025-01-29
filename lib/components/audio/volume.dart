import 'package:flutter/material.dart';
import 'package:poddr/utils/breakpoints.dart';
import 'package:provider/provider.dart';
import 'package:poddr/providers/media.dart';

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > Breakpoints.desktopScreen;
    final volume = context.select<MediaProvider, double>((e) => e.volume);

    if (isDesktop) {
      return Slider(
        value: volume,
        min: 0.0,
        max: 100.0,
        onChanged: (double value) {
          context.read<MediaProvider>().setVolume(value);
        },
      );
    } else {
      return PopupMenuButton(
        menuPadding: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.volume_up_rounded,
          size: 24,
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: RotatedBox(
                quarterTurns: -1,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Slider(
                      value: volume,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (double value) {
                        setState(
                          () {
                            context.read<MediaProvider>().setVolume(value);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ];
        },
      );
    }
  }
}
