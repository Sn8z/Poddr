import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// views
import 'package:poddr/ui/layouts/base.dart';
import 'package:poddr/ui/views/player/player.dart';
import 'package:poddr/ui/views/discover/discover.dart';
import 'package:poddr/ui/views/podcast/podcast.dart';
import 'package:poddr/ui/views/library/library.dart';
import 'package:poddr/ui/views/library/downloads/downloads.dart';
import 'package:poddr/ui/views/library/latest/latest.dart';
import 'package:poddr/ui/views/search/search.dart';
import 'package:poddr/ui/views/settings/settings.dart';

final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'Root navigation');
final _podcastNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'Podcast navigation');
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
    initialLocation: "/podcasts",
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
            child: BasePage(
              state: state,
              child: navigationShell,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _podcastNavKey,
            routes: [
              GoRoute(
                path: '/',
                redirect: (context, state) => '/podcasts',
              ),
              GoRoute(
                path: '/podcasts',
                parentNavigatorKey: _podcastNavKey,
                pageBuilder: (context, state) {
                  return const NoTransitionPage(
                    child: PodcastDiscoveryView(),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':rss',
                    parentNavigatorKey: _podcastNavKey,
                    pageBuilder: (context, state) {
                      final rss = state.pathParameters['rss'] ?? '';
                      final decodedRSS = Uri.decodeComponent(rss);
                      return NoTransitionPage(
                        child: PodcastDetailsView(rss: decodedRSS),
                      );
                    },
                  )
                ],
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
                routes: [
                  GoRoute(
                    path: '/latest',
                    parentNavigatorKey: _libraryNavKey,
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: LatestEpisodesView(),
                      );
                    },
                  ),
                  GoRoute(
                    path: '/downloads',
                    parentNavigatorKey: _libraryNavKey,
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(
                        child: DownloadsView(),
                      );
                    },
                  ),
                ],
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
