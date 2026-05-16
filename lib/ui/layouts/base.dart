import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/audio/large_player.dart';
import 'package:poddr/ui/components/audio/small_player.dart';
import 'package:poddr/ui/components/navigation/bottombar.dart';
import 'package:poddr/ui/components/navigation/sidebar.dart';

import 'package:poddr/ui/utils/breakpoints.dart';

class BasePage extends StatelessWidget {
  const BasePage({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final isTablet = size.width > Breakpoints.tabletScreen;

    return isTablet
        ? Row(
            children: [
              PoddrSideBar(
                state: state,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: child),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LargePlayer(),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: child),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SmallPlayer(),
                    ),
                  ],
                ),
              ),
              PoddrBottomBar(state: state),
            ],
          );
  }
}
