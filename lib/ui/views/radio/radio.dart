import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/carousel.dart';
import 'package:poddr/ui/components/widgets/tag.dart';

class RadioDiscoveryView extends StatelessWidget {
  const RadioDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: 'Radio',
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.cast_outlined),
                ),
              ],
            ),
            SliverList.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Radio ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Radio ${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
              itemCount: 100,
            ),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
