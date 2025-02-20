import 'package:flutter/material.dart';
import 'package:poddr/components/ui/tag.dart';

class RadioDiscoveryView extends StatelessWidget {
  const RadioDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselView(
        scrollDirection: Axis.horizontal,
        itemExtent: double.infinity,
        children: List<Widget>.generate(10, (int index) {
          return Center(child: Text('Item $index'));
        }),
      ),
    );
  }
}
