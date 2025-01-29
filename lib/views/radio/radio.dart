import 'package:flutter/material.dart';

class RadioDiscoveryView extends StatelessWidget {
  const RadioDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: CarouselView(
            itemExtent: 360,
            shrinkExtent: 260,
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
