import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:poddr/services/favourites.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

// Providers
import 'package:poddr/services/theme.dart';
import 'package:poddr/router.dart';
import 'package:poddr/services/media.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  MediaKit.ensureInitialized();

  final GoRouter router = PoddrRouter.router;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
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
        themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: themeProvider.lightTheme.copyWith(
          textTheme: GoogleFonts.outfitTextTheme(
            ThemeData(brightness: Brightness.light).textTheme,
          ),
        ),
        darkTheme: themeProvider.darkTheme.copyWith(
          textTheme: GoogleFonts.outfitTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
