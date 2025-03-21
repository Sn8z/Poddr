import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
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
            ContentBox(
              title: "Content",
              subtitle: "Subtitle",
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
              children: const [
                ListTile(
                  title: Text("Title"),
                ),
                ListTile(
                  title: Text("Title"),
                ),
              ],
            ),
            const ContentBox(
              title: "Content",
              children: [
                ListTile(
                  title: Text("Title"),
                ),
              ],
            ),
            const ContentBox(
              subtitle: "Subtitle",
              children: [
                ListTile(
                  title: Text("Title"),
                ),
              ],
            ),
            ContentBox(
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert_rounded),
                ),
                IconButton(
                    onPressed: () {}, icon: Icon(Icons.grid_3x3_outlined)),
              ],
            ),
            const ContentBox(
              children: [
                ListTile(
                  title: Text("Title"),
                ),
                ListTile(
                  title: Text("Title"),
                ),
              ],
            ),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
