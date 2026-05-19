import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/views/podcast/podcast_view_model.dart';

class PodcastHeader extends StatelessWidget {
  final PodcastViewModel podcastProvider;

  const PodcastHeader({super.key, required this.podcastProvider});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < Breakpoints.mobileScreen;
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.surfaceContainerLow
            : theme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: isMobile
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: podcastProvider.isLoading
                      ? const ShimmerBox()
                      : PoddrImage(
                          imageUrl: podcastProvider.podcast?.image ?? "",
                          fit: BoxFit.cover,
                        ),
                ),
                gapH8,
                Text(
                  podcastProvider.podcast?.title ?? "",
                  style: theme.textTheme.titleLarge.copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                gapH8,
                Text(
                  podcastProvider.podcast?.author ?? "",
                  style: theme.textTheme.titleSmall.copyWith(
                    overflow: TextOverflow.ellipsis,
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: PoddrImage(
                    imageUrl: podcastProvider.podcast?.image ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
                gapW16,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcastProvider.podcast?.title ?? "",
                        style: theme.textTheme.displaySmall.copyWith(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                      gapH8,
                      Text(
                        podcastProvider.podcast?.author ?? "",
                        style: theme.textTheme.titleLarge.copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                      gapH8,
                      Text(
                        "${podcastProvider.podcast?.episodes.length ?? 0} Episodes",
                        style: theme.textTheme.labelMedium.copyWith(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          color: theme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
