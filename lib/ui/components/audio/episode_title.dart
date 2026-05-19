import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/media/media_provider.dart';

class EpisodeTitle extends StatelessWidget {
  const EpisodeTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String? title =
        context.select<MediaProvider, String?>((e) => e.episodeTitle);
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
          title ?? "Title",
          style: context.theme.textTheme.titleMedium
              .copyWith(color: context.theme.primary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
