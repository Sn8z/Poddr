import 'package:flutter/material.dart';
import 'package:poddr/components/auth/user_tile.dart';
import 'package:poddr/components/ui/appbar.dart';
import 'package:poddr/components/ui/logo.dart';
import 'package:poddr/providers/theme.dart';
import 'package:poddr/utils/theme_colors.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PoddrAppBar(
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SwitchListTile(
              value: context.watch<ThemeProvider>().isDark,
              onChanged: (bool value) {
                context.read<ThemeProvider>().toggleThemeMode();
              },
              title: const Text('Dark mode'),
            ),
          ),
          SliverToBoxAdapter(
            child: ExpansionTile(
              title: const Text('Themes'),
              children: [
                for (final color in colors)
                  ListTile(
                    tileColor: color.color,
                    title: Text(color.name),
                    onTap: () =>
                        context.read<ThemeProvider>().setColor(color.color),
                  ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(indent: 8.0, endIndent: 8.0),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: UserInfoTile(),
          ),
          const SliverToBoxAdapter(
            child: Divider(indent: 8.0, endIndent: 8.0),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Poddr",
                  applicationVersion: "1.0.0",
                  applicationIcon: const PoddrLogo(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
