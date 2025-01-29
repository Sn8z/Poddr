import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/audio/large_player.dart';
import 'package:poddr/components/audio/small_player.dart';
import 'package:poddr/components/navigation/bottom_navigation.dart';
import 'package:poddr/components/navigation/sidemenu.dart';

import 'package:poddr/utils/breakpoints.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final isTablet = size.width > Breakpoints.tabletScreen;

    return Scaffold(
      body: isTablet
          ? Row(
              children: [
                PoddrSideMenu(
                  shell: child,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: child),
                      const LargePlayer(),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
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
      bottomNavigationBar: isTablet ? null : PoddrBottomNav(shell: child),
    );
  }
}
