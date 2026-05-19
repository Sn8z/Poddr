import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_slider.dart';
import 'package:provider/provider.dart';

class SpeedButton extends StatelessWidget {
  final double size;

  const SpeedButton({
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final List<double> speedSteps = [
      0.25,
      0.5,
      0.75,
      1.0,
      1.25,
      1.5,
      1.75,
      2.0,
    ];

    return PoddrIconButton(
      onPressed: () {
        showPoddrDialog(
          context: context,
          builder: (context) {
            return PoddrDialog(
              child: Selector<MediaProvider, double>(
                selector: (_, mediaProvider) => mediaProvider.speed,
                builder: (context, speed, child) {
                  double currentStep = speedSteps.firstWhere(
                    (step) => (step - speed).abs() < 0.125,
                    orElse: () => 1.0,
                  );

                  int currentIndex = speedSteps.indexOf(currentStep);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${speedSteps[currentIndex.clamp(0, speedSteps.length - 1)]}x",
                        style: context.theme.textTheme.titleMedium.copyWith(
                          color: context.theme.onSurfaceVariant,
                        ),
                      ),
                      PoddrSlider(
                        value: currentIndex.toDouble(),
                        min: 0,
                        max: (speedSteps.length - 1).toDouble(),
                        divisions: speedSteps.length - 1,
                        trackHeight: 4,
                        onChanged: (double value) {
                          int index = value.round();
                          context
                              .read<MediaProvider>()
                              .setSpeed(speedSteps[index]);
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
      icon: Text(
        "${context.select<MediaProvider, double>(
          (mediaProvider) => mediaProvider.speed,
        )}x",
        style: context.theme.textTheme.labelLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      size: size,
    );
  }
}
