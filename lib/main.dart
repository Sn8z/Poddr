import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/services/latest_episodes.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/opml.dart';
import 'package:poddr/shortcuts.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

// Providers
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final GoRouter router = PoddrRouter.router;

  runApp(
    MultiProvider(
      providers: [
        // Theme
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),

        // Offline
        ChangeNotifierProvider<OfflineProvider>(
            create: (_) => OfflineProvider()),

        // Subscriptions
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
        ),

        // History
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),

        // Collections
        ChangeNotifierProvider<CollectionsProvider>(
          create: (_) => CollectionsProvider(),
        ),

        // Latest Episodes
        ChangeNotifierProxyProvider<SubscriptionProvider,
            LatestEpisodesProvider>(
          create: (_) => LatestEpisodesProvider(),
          update: (_, subscription, prev) {
            prev ??= LatestEpisodesProvider();
            prev.update(subscription);
            return prev;
          },
        ),

        // Sync Provider
        ChangeNotifierProxyProvider2<SubscriptionProvider, HistoryProvider,
            SyncProvider>(
          create: (_) => SyncProvider(),
          update: (_, subscription, history, prev) {
            prev ??= SyncProvider();
            prev.update(subscription, history);
            return prev;
          },
        ),

        // Media
        ChangeNotifierProxyProvider3<HistoryProvider, OfflineProvider,
            SyncProvider, MediaProvider>(
          create: (_) => MediaProvider(),
          update: (_, history, offline, sync, prev) {
            prev ??= MediaProvider();
            prev.update(history, offline, sync);
            return prev;
          },
        ),

        // OPML
        ChangeNotifierProxyProvider<SubscriptionProvider, OpmlProvider>(
          create: (_) => OpmlProvider(),
          update: (_, subscription, prev) {
            prev ??= OpmlProvider();
            prev.update(subscription);
            return prev;
          },
        ),
      ],
      child: Poddr(router: router),
    ),
  );
}

class Poddr extends StatelessWidget {
  const Poddr({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return SafeArea(
      child: MaterialApp.router(
        title: "Poddr",
        themeMode: themeProvider.themeMode,
        theme: themeProvider.lightTheme,
        darkTheme: themeProvider.darkTheme,
        routerConfig: router,
        builder: (context, child) {
          return PoddrShortcuts(
            router: router,
            child: child!,
          );
        },
      ),
    );
  }
}
