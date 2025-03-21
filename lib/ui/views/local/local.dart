import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';

class LocalDiscoveryView extends StatelessWidget {
  const LocalDiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: 'Local',
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: ShimmerBox(),
            ),
            SliverList.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Local ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Local ${index + 1}',
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
