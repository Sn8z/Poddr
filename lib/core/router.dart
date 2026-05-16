import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    redirect: (context, state) {
      if (state.matchedLocation == '/') {
        return '/podcasts';
      }
      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/podcasts'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/player',
        name: 'player',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PlayerView(),
            transitionsBuilder: (_, animation, __, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BasePage(
            state: state,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _podcastNavKey,
            routes: [
              GoRoute(
                path: '/podcasts',
                name: 'podcasts',
                parentNavigatorKey: _podcastNavKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage<void>(
                    key: state.pageKey,
                    child: const PodcastDiscoveryView(),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':rss',
                    name: 'podcast-details',
                    parentNavigatorKey: _podcastNavKey,
                    pageBuilder: (context, state) {
                      final rss = state.pathParameters['rss'] ?? '';
                      final decodedRSS = Uri.decodeComponent(rss);
                      return NoTransitionPage<void>(
                        key: state.pageKey,
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
                name: 'library',
                parentNavigatorKey: _libraryNavKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage<void>(
                    key: state.pageKey,
                    child: const LibraryView(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'latest',
                    name: 'library-latest',
                    pageBuilder: (context, state) {
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: const LatestEpisodesView(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'downloads',
                    name: 'library-downloads',
                    pageBuilder: (context, state) {
                      return NoTransitionPage<void>(
                        key: state.pageKey,
                        child: const DownloadsView(),
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
                name: 'search',
                parentNavigatorKey: _searchNavKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage<void>(
                    key: state.pageKey,
                    child: const SearchView(),
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
                name: 'settings',
                parentNavigatorKey: _settingsNavKey,
                pageBuilder: (context, state) {
                  return NoTransitionPage<void>(
                    key: state.pageKey,
                    child: const SettingsView(),
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
