import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/services/offline.dart';
import 'package:poddr/core/shortcuts.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:poddr/services/subscriptions.dart';
import 'package:poddr/services/history.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/services/media/media_provider.dart';
import 'package:poddr/services/sync.dart';
import 'package:poddr/core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  FlutterError.onError = (details) {
    error(
      'Flutter error',
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (err, stackTrace) {
    error(
      'Uncaught error',
      name: 'UncaughtError',
      error: err,
      stackTrace: stackTrace,
    );
    return true;
  };

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
    return WidgetsApp.router(
      title: "Poddr",
      color: themeProvider.color,
      routerConfig: router,
      builder: (context, child) {
        final systemBrightness = MediaQuery.platformBrightnessOf(context);
        final themeData = themeProvider.resolveTheme(systemBrightness);
        return PoddrTheme(
          data: themeData,
          child: IconTheme(
            data: themeData.iconTheme,
            child: ColoredBox(
              color: themeData.colors.surface,
              child: SafeArea(
                child: PoddrShortcuts(
                  router: router,
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
