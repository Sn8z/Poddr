import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/services/latest_episodes.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/services/opml.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

// Providers
import 'package:poddr/services/profile.dart';
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final ProfileProvider profileProvider = ProfileProvider();
  await profileProvider.init();

  final GoRouter router = PoddrRouter.router;

  runApp(
    MultiProvider(
      providers: [
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Profiles
        ChangeNotifierProvider.value(value: profileProvider),

        // Offline
        ChangeNotifierProvider(create: (_) => OfflineProvider()),

        // Subscriptions
        ChangeNotifierProxyProvider<ProfileProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
          update: (_, profile, prev) {
            prev ??= SubscriptionProvider();
            prev.update(profile);
            return prev;
          },
        ),

        // History
        ChangeNotifierProxyProvider<ProfileProvider, HistoryProvider>(
          create: (_) => HistoryProvider(),
          update: (_, profile, prev) {
            prev ??= HistoryProvider();
            prev.update(profile);
            return prev;
          },
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

        // Media
        ChangeNotifierProxyProvider2<HistoryProvider, OfflineProvider, MediaProvider>(
          create: (_) => MediaProvider(),
          update: (_, history, offline, prev) {
            prev ??= MediaProvider();
            prev.update(history, offline);
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
      ),
    );
  }
}
