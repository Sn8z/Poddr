import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/core/http_client.dart';
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
import 'package:poddr/data/db/drift/database.dart';
import 'package:poddr/data/collections/drift_collections_repository.dart';
import 'package:poddr/data/history/drift_history_repository.dart';
import 'package:poddr/data/offline/drift_offline_repository.dart';
import 'package:poddr/data/subscriptions/drift_subscription_repository.dart';
import 'package:poddr/data/sync/drift_sync_repository.dart';
import 'package:poddr/data/podcast/podcast_repository.dart';
import 'package:poddr/data/podcast/itunes_podcast_repository.dart';
import 'package:poddr/data/settings/settings_repository.dart';
import 'package:poddr/data/settings/prefs_settings_repository.dart';
import 'package:poddr/data/settings/secure_settings_repository.dart';
import 'package:poddr/data/countries/country_repository.dart';
import 'package:poddr/data/countries/itunes_country_repository.dart';
import 'package:poddr/data/genres/genre_repository.dart';
import 'package:poddr/data/genres/itunes_genre_repository.dart';
import 'package:poddr/data/media/media_repository.dart';
import 'package:poddr/data/media/prefs_media_repository.dart';

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

  ErrorWidget.builder = (_) => const _FriendlyErrorFallback();

  final GoRouter router = PoddrRouter.router;

  final PoddrDatabase database = PoddrDatabase.open();
  final DriftSubscriptionRepository subscriptionRepository =
      DriftSubscriptionRepository(database);
  final DriftHistoryRepository historyRepository =
      DriftHistoryRepository(database);
  final DriftOfflineRepository offlineRepository =
      DriftOfflineRepository(database);
  final DriftCollectionsRepository collectionsRepository =
      DriftCollectionsRepository(database);
  final DriftSyncRepository syncRepository = DriftSyncRepository(database);

  runApp(
    MultiProvider(
      providers: [
        Provider<PoddrHttpClient>(
          create: (_) => PoddrHttpClient(),
          dispose: (_, client) => client.close(),
        ),
        Provider<IPodcastRepository>(
          create: (context) => ITunesPodcastRepository(
            httpClient: context.read<PoddrHttpClient>(),
          ),
        ),
        Provider<ISettingsRepository>(
          create: (_) => SharedPrefSettingsRepository(),
        ),
        Provider<SecureSettingsRepository>(
          create: (_) => SecureSettingsRepository(),
        ),
        Provider<ICountryRepository>(
          create: (_) => ItunesCountryRepository(),
        ),
        Provider<IGenreRepository>(
          create: (_) => ItunesGenreRepository(),
        ),
        Provider<IMediaRepository>(
          create: (_) => SharedPrefsMediaRepository(),
        ),

        // Theme
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
            settingsRepository: context.read<ISettingsRepository>(),
          ),
        ),

        // Offline
        ChangeNotifierProvider<OfflineProvider>(
          create: (_) => OfflineProvider(repository: offlineRepository),
        ),

        // Subscriptions
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (context) => SubscriptionProvider(
            podcastRepository: context.read<IPodcastRepository>(),
            subscriptionRepository: subscriptionRepository,
            syncRepository: syncRepository,
          ),
        ),

        // History
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(historyRepository: historyRepository),
        ),

        // Collections
        ChangeNotifierProvider<CollectionsProvider>(
          create: (_) => CollectionsProvider(repository: collectionsRepository),
        ),

        // Sync
        ChangeNotifierProvider<SyncProvider>(
          create: (context) => SyncProvider(
            subscriptionProvider: context.read<SubscriptionProvider>(),
            historyProvider: context.read<HistoryProvider>(),
            settings: context.read<ISettingsRepository>(),
            secureSettings: context.read<SecureSettingsRepository>(),
            syncRepository: syncRepository,
          ),
        ),

        // Media
        ChangeNotifierProvider<MediaProvider>(
          create: (context) => MediaProvider(
            historyProvider: context.read<HistoryProvider>(),
            offlineProvider: context.read<OfflineProvider>(),
            syncProvider: context.read<SyncProvider>(),
            mediaRepository: context.read<IMediaRepository>(),
          ),
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
          child: ColoredBox(
            color: themeData.colors.surface,
            child: SafeArea(
              child: PoddrShortcuts(
                router: router,
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Last-resort UI when a widget fails to build. It must not depend on the
/// app's providers, theme, or routing, because any of those may be broken.
class _FriendlyErrorFallback extends StatelessWidget {
  const _FriendlyErrorFallback();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFF121212),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Something went wrong while showing this screen.\n'
              'Your data is safe. Try going back or restarting Poddr.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 14,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
