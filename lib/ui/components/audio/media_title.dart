import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String? artist =
        context.select<MediaProvider, String?>((e) => e.podcastTitle);
    String? rss = context.select<MediaProvider, String?>((e) => e.podcastRSS);

    final encodedRSS =
        rss != null && rss.isNotEmpty ? Uri.encodeComponent(rss) : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: encodedRSS != null
            ? () => context.go("/podcasts/$encodedRSS")
            : null,
        child: Text(
          artist ?? "Artist",
          style: context.theme.textTheme.titleSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
