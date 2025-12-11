import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: 'Downloads',
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            PoddrAppBarOptions(),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
