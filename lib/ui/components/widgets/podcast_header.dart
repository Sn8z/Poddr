import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/image.dart';
import 'package:poddr/ui/components/widgets/shimmer.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';

class PodcastHeader extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final Widget? metadata;
  final Widget? collections;
  final List<Widget> actions;
  final Widget? bottom;
  final double shrinkRatio;

  const PodcastHeader({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.isLoading = false,
    this.metadata,
    this.collections,
    this.actions = const [],
    this.bottom,
    this.shrinkRatio = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Semantics(
      header: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < Breakpoints.mobileScreen;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  Container(
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryContainer.withAlpha(100),
                        theme.primaryContainer.withAlpha(30),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile
                      ? _MobileLayout(
                          imageUrl: imageUrl,
                          title: title,
                          subtitle: subtitle,
                          isLoading: isLoading,
                          metadata: metadata,
                          collections: collections,
                          actions: actions,
                          shrinkRatio: shrinkRatio,
                        )
                      : _DesktopLayout(
                          imageUrl: imageUrl,
                          title: title,
                          subtitle: subtitle,
                          isLoading: isLoading,
                          metadata: metadata,
                          collections: collections,
                          actions: actions,
                        ),
                ),
                if (bottom != null) bottom!,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final Widget? metadata;
  final Widget? collections;
  final List<Widget> actions;
  final double shrinkRatio;

  const _MobileLayout({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    this.metadata,
    this.collections,
    required this.actions,
    this.shrinkRatio = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final imageSize = 120.0 * (1 - shrinkRatio);
    final gap12 = 12.0 * (1 - shrinkRatio);
    final gap8 = 8.0 * (1 - shrinkRatio);
    final metadataOpacity = 1 - shrinkRatio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: AnimatedOpacity(
            opacity: 1 - shrinkRatio,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: imageSize,
              width: imageSize,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? const ShimmerBox()
                  : PoddrImage(
                      imageUrl: imageUrl ?? "",
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        SizedBox(height: gap12),
        Text(
          title ?? "",
          style: theme.textTheme.titleLarge.copyWith(
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          SizedBox(height: gap12 > 4 ? 4.0 : gap12),
          Text(
            subtitle!,
            style: theme.textTheme.titleSmall.copyWith(
              overflow: TextOverflow.ellipsis,
              color: theme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (metadata != null) ...[
          RepaintBoundary(
            child: AnimatedOpacity(
              opacity: metadataOpacity,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: SizedBox(height: metadataOpacity * 32, child: metadata!),
              ),
            ),
          ),
        ],
        if (actions.isNotEmpty) ...[
          RepaintBoundary(
            child: AnimatedOpacity(
              opacity: 1 - shrinkRatio,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: gap8 + (1 - shrinkRatio) * 32,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: actions,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (collections != null) ...[
          RepaintBoundary(
            child: AnimatedOpacity(
              opacity: 1 - shrinkRatio,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: gap12 + (1 - shrinkRatio) * 40,
                  child: collections!,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final Widget? metadata;
  final Widget? collections;
  final List<Widget> actions;

  const _DesktopLayout({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    this.metadata,
    this.collections,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: isLoading
                ? const ShimmerBox()
                : PoddrImage(
                    imageUrl: imageUrl ?? "",
                    fit: BoxFit.cover,
                  ),
          ),
          gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gapH8,
                Text(
                  title ?? "",
                  style: theme.textTheme.displaySmall.copyWith(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  gapH4,
                  Text(
                    subtitle!,
                    style: theme.textTheme.titleLarge.copyWith(
                      overflow: TextOverflow.ellipsis,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (metadata != null) ...[
                  gapH8,
                  metadata!,
                ],
                if (collections != null) ...[
                  const Spacer(),
                  collections!,
                ],
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (actions.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
