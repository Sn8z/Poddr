import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poddr/models/tag.dart';
import 'package:poddr/services/opml.dart';
import 'package:poddr/services/tags.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/components/widgets/content_box.dart';
import 'package:poddr/ui/components/widgets/logo.dart';
import 'package:poddr/ui/components/widgets/color_picker.dart';
import 'package:poddr/services/theme.dart';
import 'package:poddr/ui/utils/breakpoints.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/data/theme/theme_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            PoddrAppBarOptions(),
            sliverGapH16,
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
            sliverGapH16,
            ContentBox(
              title: "Tags",
              children: const [
                TagsSection(),
              ],
            ),
            sliverGapH16,
            ContentBox(title: "OPML", children: [
              OpmlSection(),
            ]),
            sliverGapH16,
            ContentBox(title: "Support", children: [
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text("GitHub Sponsor"),
                onTap: () async {
                  try {
                    await launchUrl(
                        Uri.parse("https://github.com/sponsors/Sn8z"));
                  } catch (e) {
                    log('Error launching URL: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser_outlined),
                title: const Text("Paypal"),
                onTap: () {
                  try {
                    launchUrl(
                        Uri.parse("https://www.paypal.com/paypalme/sn8z"));
                  } catch (e) {
                    log('Error launching URL: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.coffee_outlined),
                title: const Text("Ko-Fi"),
                onTap: () {
                  try {
                    launchUrl(Uri.parse("https://ko-fi.com/sneitz"));
                  } catch (e) {
                    log('Error launching URL: $e');
                  }
                },
              ),
            ]),
            sliverGapH16,
            ContentBox(
              title: "About",
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text("Issues"),
                  onTap: () {
                    try {
                      launchUrl(
                          Uri.parse("https://github.com/Sn8z/Poddr/issues"));
                    } catch (e) {
                      log('Error launching URL: $e');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Licenses'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Poddr",
                      applicationVersion: "3.0.0",
                      applicationIcon: const PoddrLogo(
                        size: 56,
                      ),
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

class OpmlSection extends StatelessWidget {
  const OpmlSection({super.key});

  @override
  Widget build(BuildContext context) {
    final opmlProvider = context.watch<OpmlProvider>();
    final isLoading = opmlProvider.isLoading;
    final statusMessage = opmlProvider.statusMessage;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_circle_right_outlined),
          title: const Text("Import"),
          enabled: !isLoading,
          onTap: () => opmlProvider.importOpml(),
        ),
        ListTile(
          leading: const Icon(Icons.arrow_circle_left_outlined),
          title: const Text("Export"),
          enabled: !isLoading,
          onTap: () => opmlProvider.exportOpml(),
        ),
        if (statusMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              statusMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class TagsSection extends StatefulWidget {
  const TagsSection({super.key});

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  Future<void> _showCreateTagDialog(BuildContext context) async {
    final tagsProvider = context.read<TagsProvider>();

    final dialogResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _TagCreateDialog(),
    );

    if (dialogResult != null && mounted) {
      await tagsProvider.createTag(
        dialogResult['name'] as String,
        color: dialogResult['color'] as int,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsProvider = context.watch<TagsProvider>();

    return StreamBuilder<List<PodcastTag>>(
      stream: tagsProvider.tagsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final tags = snapshot.data ?? [];

        if (tags.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'No tags yet. Tags will be created automatically when you subscribe to podcasts.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final tag in tags)
              _TagListItem(
                tag: tag,
                onEdit: () => _showEditTagDialog(context, tag),
                onDelete: () => _showDeleteConfirmation(context, tag),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => _showCreateTagDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTagDialog(BuildContext context, dynamic tag) async {
    final tagsProvider = context.read<TagsProvider>();

    final dialogResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TagCreateDialog(
        initialName: tag.name,
        initialColor: tag.color,
      ),
    );

    if (dialogResult != null && mounted) {
      final newName = dialogResult['name'] as String;
      final newColor = dialogResult['color'] as int;

      if (newName != tag.name) {
        await tagsProvider.updateTagName(tag.id, newName);
      }
      if (newColor != tag.color) {
        await tagsProvider.updateTagColor(tag.id, newColor);
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, dynamic tag) async {
    final tagsProvider = context.read<TagsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await tagsProvider.deleteTag(tag.id);
    }
  }
}

class _TagListItem extends StatelessWidget {
  final dynamic tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagListItem({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Color(tag.color),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(tag.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TagCreateDialog extends StatefulWidget {
  final String? initialName;
  final int? initialColor;

  const _TagCreateDialog({
    this.initialName,
    this.initialColor,
  });

  @override
  State<_TagCreateDialog> createState() => _TagCreateDialogState();
}

class _TagCreateDialogState extends State<_TagCreateDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor != null
        ? Color(widget.initialColor!)
        : const Color(0xFF6750A4);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialName != null ? 'Edit Tag' : 'New Tag',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: HsvColorPicker(
                    initialColor: _selectedColor,
                    onColorChanged: (color) {
                      setState(() => _selectedColor = color);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tag name cannot be empty')),
                        );
                        return;
                      }
                      Navigator.of(context).pop({
                        'name': name,
                        'color': _selectedColor.toARGB32(),
                      });
                    },
                    child: Text(widget.initialName != null ? 'Save' : 'Create'),
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
