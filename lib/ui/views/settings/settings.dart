import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/logo.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/theme_colors.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const PoddrAppBar(
              title: "Settings",
            ),
            SettingsBox(
              title: "Appearance",
              children: [
                SwitchListTile(
                  value: context.watch<ThemeProvider>().isDark,
                  onChanged: (bool value) {
                    context.read<ThemeProvider>().toggleThemeMode();
                  },
                  title: const Text('Dark mode'),
                ),
                gapH8,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final color in colors)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => context
                                .read<ThemeProvider>()
                                .setColor(color.color),
                            child: Container(
                              width: 64,
                              height: 64,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: color.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
            SettingsBox(
              title: "About",
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Licenses'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Poddr",
                      applicationVersion: "1.0.0",
                      applicationIcon: const PoddrLogo(),
                    );
                  },
                ),
              ],
            ),
          ],
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
