import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/logo.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/data/theme_colors.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            const PoddrAppBar(
              title: "Settings",
            ),
            const SettingsBox(
              title: "Appearance",
              children: [
                gapH32,
                ThemeSelector(),
                gapH32,
                ColorSelector(),
                gapH16,
              ],
            ),
            const SettingsBox(
              title: "Preferences",
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Info"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Info"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Info"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Info"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Info"),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
            SettingsBox(title: "OPML", children: [
              ListTile(
                leading: const Icon(Icons.arrow_circle_right_outlined),
                title: const Text("Import"),
                onTap: () => debugPrint('Import'),
              ),
              ListTile(
                leading: const Icon(Icons.arrow_circle_left_outlined),
                title: const Text("Export"),
                onTap: () => debugPrint('Export'),
              ),
            ]),
            SettingsBox(title: "Support", children: [
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text("GitHub Sponsor"),
                onTap: () => debugPrint('GH sponsor'),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser_outlined),
                title: const Text("Paypal"),
                onTap: () => debugPrint('Paypal'),
              ),
            ]),
            SettingsBox(
              title: "About",
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text("Issues"),
                  onTap: () => debugPrint('/issues'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Licenses'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Poddr",
                      applicationVersion: "3.0.0",
                      applicationIcon: const PoddrLogo(),
                    );
                  },
                ),
              ],
            ),
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ThemeBox(
          title: 'System',
          mode: ThemeMode.system,
          color: Colors.grey,
          icon: Icons.brightness_auto_outlined,
          iconColor: Colors.white,
        ),
        ThemeBox(
          title: 'Light',
          mode: ThemeMode.light,
          color: Colors.white,
          icon: Icons.light_mode_outlined,
          iconColor: Colors.black,
        ),
        ThemeBox(
          title: 'Dark',
          mode: ThemeMode.dark,
          color: Colors.black,
          icon: Icons.dark_mode_outlined,
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class ThemeBox extends StatelessWidget {
  final String title;
  final ThemeMode mode;
  final Color color;
  final IconData icon;
  final Color iconColor;

  const ThemeBox({
    super.key,
    required this.title,
    required this.mode,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = context.watch<ThemeProvider>().themeMode == mode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<ThemeProvider>().setThemeMode(mode);
        },
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: isSelected ? 4 : 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < Breakpoints.mobileScreen;

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final color in colors)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ColorBox(
                  color: color.color,
                ),
              ),
          ],
        ),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final color in colors)
            ColorBox(
              color: color.color,
            ),
        ],
      );
    }
  }
}

class ColorBox extends StatelessWidget {
  final Color color;

  const ColorBox({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = context.watch<ThemeProvider>().color == color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<ThemeProvider>().setColor(color);
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: isSelected ? 4 : 0,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check_circle_outline_rounded)
              : null,
        ),
      ),
    );
  }
}

class SettingsBox extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsBox({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
