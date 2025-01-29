import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/shortcuts.dart';

// pages
import 'package:poddr/views/base.dart';
import 'package:poddr/views/player/player.dart';
import 'package:poddr/views/podcast/discover.dart';
import 'package:poddr/views/podcast/podcast.dart';
import 'package:poddr/views/library/library.dart';
import 'package:poddr/views/radio/radio.dart';
import 'package:poddr/views/search/search.dart';
import 'package:poddr/views/settings/settings.dart';

final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'Root navigation');
final _podcastNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'Podcast navigation');
final _radioNavKey = GlobalKey<NavigatorState>(debugLabel: 'Radio navigation');
final _libraryNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'Library navigation');
final _searchNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'Search navigation');
final _settingsNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'Settings navigation');

abstract class PoddrRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavKey,
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const PlayerView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) {
          return NoTransitionPage(
            child: PoddrShortcuts(
              child: BasePage(
                child: navigationShell,
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _podcastNavKey,
            routes: [
              GoRoute(
                path: '/',
                parentNavigatorKey: _podcastNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: PodcastDiscoveryView(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'podcast',
                    parentNavigatorKey: _podcastNavKey,
                    pageBuilder: (context, state) {
                      return NoTransitionPage(
                          child: PodcastDetailsView(
                              rss: state.uri.queryParameters['rss'] ?? ''));
                    },
                  )
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _radioNavKey,
            routes: [
              GoRoute(
                path: '/radio',
                parentNavigatorKey: _radioNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: RadioDiscoveryView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _libraryNavKey,
            routes: [
              GoRoute(
                path: '/library',
                parentNavigatorKey: _libraryNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: LibraryView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavKey,
            routes: [
              GoRoute(
                path: '/search',
                parentNavigatorKey: _searchNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: SearchView(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavKey,
            routes: [
              GoRoute(
                path: '/settings',
                parentNavigatorKey: _settingsNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: SettingsView(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
