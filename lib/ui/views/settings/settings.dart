import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/core/log.dart';
import 'package:poddr/core/theme/poddr_theme_data.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/views/settings/collections/collections_settings.dart';
import 'package:poddr/ui/views/settings/opml/opml_settings.dart';

import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/color_picker.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/layouts/page_layout.dart';

import 'package:poddr/services/theme.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:poddr/ui/views/settings/sync/sync_settings.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_licenses.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      header: const PoddrAppBar(title: "Settings"),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            gapH16,
            const ContentBox(
              title: "Appearance",
              children: [
                gapH32,
                ThemeSelector(),
                gapH32,
                ColorSelector(),
                gapH16,
              ],
            ),
            gapH16,
            const ContentBox(
              title: "Collections",
              children: [
                CollectionsSection(),
              ],
            ),
            gapH16,
            const ContentBox(title: "OPML", children: [
              OpmlSection(),
            ]),
            gapH16,
            const ContentBox(title: "gPodder sync", children: [
              SyncSection(),
            ]),
            gapH16,
            ContentBox(
              title: "Support",
              children: [
                PoddrListItem(
                  leading: Icon(
                    LucideIcons.heart,
                    color: context.theme.onSurface,
                  ),
                  title: "GitHub Sponsor",
                  onTap: () async {
                    try {
                      await launchUrl(
                          Uri.parse("https://github.com/sponsors/Sn8z"));
                    } catch (e) {
                      error('Error launching URL: $e', name: 'SettingsView');
                    }
                  },
                ),
                PoddrListItem(
                  leading: Icon(
                    LucideIcons.wallet,
                    color: context.theme.onSurface,
                  ),
                  title: "Paypal",
                  onTap: () {
                    try {
                      launchUrl(Uri.parse("https://www.paypal.com/paypalme/sn8z"));
                    } catch (e) {
                      error('Error launching URL: $e', name: 'SettingsView');
                    }
                  },
                ),
                PoddrListItem(
                  leading: Icon(
                    LucideIcons.coffee,
                    color: context.theme.onSurface,
                  ),
                  title: "Ko-Fi",
                  onTap: () {
                    try {
                      launchUrl(Uri.parse("https://ko-fi.com/sneitz"));
                    } catch (e) {
                      error('Error launching URL: $e', name: 'SettingsView');
                    }
                  },
                ),
              ],
            ),
            gapH16,
            ContentBox(
              title: "About",
              children: [
                PoddrListItem(
                  leading: Icon(
                    LucideIcons.bug,
                    color: context.theme.onSurface,
                  ),
                  title: "Issues",
                  onTap: () {
                    try {
                      launchUrl(Uri.parse("https://github.com/Sn8z/Poddr/issues"));
                    } catch (e) {
                      error('Error launching URL: $e', name: 'SettingsView');
                    }
                  },
                ),
                PoddrListItem(
                  leading: Icon(
                    LucideIcons.info,
                    color: context.theme.onSurface,
                  ),
                  title: 'Licenses',
                  onTap: () => showPoddrDialog(
                    context: context,
                    maxWidth: 500,
                    builder: (dialogContext) {
                      final contentHeight = MediaQuery.sizeOf(dialogContext).height * 0.7;
                      return SizedBox(
                        height: contentHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Poddr",
                                  style: dialogContext.theme.textTheme.titleMedium,
                                ),
                                PoddrIconButton(
                                  icon: const Icon(LucideIcons.x, size: 18),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Version 3.0.0",
                              style: dialogContext.theme.textTheme.bodyMedium.copyWith(
                                color: dialogContext.theme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(height: 1, color: dialogContext.theme.outline.withAlpha(50)),
                            const SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: PoddrLicenseView(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                PoddrTextButton(
                                  label: "Close",
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
          mode: PoddrThemeMode.system,
          color: Color(0xFF808080),
          icon: LucideIcons.monitor,
          iconColor: Color(0xFFFFFFFF),
        ),
        ThemeBox(
          title: 'Light',
          mode: PoddrThemeMode.light,
          color: Color(0xFFFFFFFF),
          icon: LucideIcons.sun,
          iconColor: Color(0xFF000000),
        ),
        ThemeBox(
          title: 'Dark',
          mode: PoddrThemeMode.dark,
          color: Color(0xFF000000),
          icon: LucideIcons.moon,
          iconColor: Color(0xFFFFFFFF),
        ),
      ],
    );
  }
}

class ThemeBox extends StatelessWidget {
  final String title;
  final PoddrThemeMode mode;
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
              color:
                  isSelected ? context.theme.primary : const Color(0x00000000),
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
    final currentColor = context.watch<ThemeProvider>().color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showColorPickerDialog(context),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.theme.onSurface,
              width: 4,
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showPoddrDialog(
      context: context,
      builder: (dialogContext) => PoddrDialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Color',
                style: context.theme.textTheme.titleMedium,
              ),
              gapH16,
              HsvColorPicker(
                initialColor: context.read<ThemeProvider>().color,
                onColorChanged: (color) {
                  dialogContext.read<ThemeProvider>().setColor(color);
                },
              ),
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PoddrTextButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
