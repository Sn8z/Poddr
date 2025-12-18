import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/utils/gaps.dart';

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
            sliverGapH16,
            ContentBox(
              title: "Episodes",
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
              children: [
                PoddrListItem(
                  title: "Episode Title",
                  subtitle: "Podcast Name",
                  leading: Icon(Icons.music_note_rounded),
                  onTap: () {},
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.grid_3x3_outlined),
                    ),
                  ],
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
