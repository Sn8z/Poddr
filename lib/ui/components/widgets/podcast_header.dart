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
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Breakpoints.mobileScreen;

    if (isMobile) {
      return SliverPersistentHeader(
        pinned: true,
        delegate: _PodcastHeaderDelegate(
          imageUrl: imageUrl,
          title: title,
          subtitle: subtitle,
          isLoading: isLoading,
          metadata: metadata,
          collections: collections,
          actions: actions,
          bottom: bottom,
        ),
      );
    }

    return PinnedHeaderSliver(
      child: Semantics(
        header: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: context.theme.surfaceContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.theme.primaryContainer.withAlpha(100),
                        context.theme.primaryContainer.withAlpha(30),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _DesktopLayout(
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
            ),
          ),
        ),
      ),
    );
  }
}

class _PodcastHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PodcastHeaderDelegate({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    this.metadata,
    this.collections,
    required this.actions,
    this.bottom,
  });

  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final Widget? metadata;
  final Widget? collections;
  final List<Widget> actions;
  final Widget? bottom;

  static const _minExtent = 104.0;
  static const _maxExtent = 400.0;

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = context.theme;
    final progress = (shrinkOffset / (_maxExtent - _minExtent)).clamp(0.0, 1.0);

    return Semantics(
      header: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: theme.surfaceContainer,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
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
                  padding: EdgeInsets.lerp(
                    const EdgeInsets.all(16),
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    progress,
                  ) ?? const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Opacity(
                        opacity: 1.0 - progress,
                        child: _MobileLayout(
                          imageUrl: imageUrl,
                          title: title,
                          subtitle: subtitle,
                          isLoading: isLoading,
                          metadata: metadata,
                          collections: collections,
                          actions: actions,
                        ),
                      ),
                      Opacity(
                        opacity: progress,
                        child: _CompactHeader(
                          imageUrl: imageUrl,
                          title: title,
                          isLoading: isLoading,
                          actions: actions,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_PodcastHeaderDelegate oldDelegate) {
    return imageUrl != oldDelegate.imageUrl ||
        title != oldDelegate.title ||
        subtitle != oldDelegate.subtitle ||
        isLoading != oldDelegate.isLoading ||
        metadata != oldDelegate.metadata ||
        collections != oldDelegate.collections ||
        actions != oldDelegate.actions ||
        bottom != oldDelegate.bottom;
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

  const _MobileLayout({
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
    const imageSize = 120.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: Container(
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
        gapH12,
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
          gapH4,
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
          gapH8,
          metadata!,
        ],
        if (actions.isNotEmpty) ...[
          gapH8,
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
        if (collections != null) ...[
          gapH12,
          collections!,
        ],
      ],
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final bool isLoading;
  final List<Widget> actions;

  const _CompactHeader({
    required this.imageUrl,
    required this.title,
    required this.isLoading,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 32,
              height: 32,
              child: isLoading
                  ? const ShimmerBox()
                  : PoddrImage(
                      imageUrl: imageUrl ?? "",
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          gapW12,
          Expanded(
            child: Text(
              title ?? "",
              style: theme.textTheme.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
        ],
      ),
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
