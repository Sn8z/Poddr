import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/ui/views/settings/collections/collections_view_model.dart';
import 'package:poddr/ui/components/widgets/poddr_overlay.dart';
import 'package:poddr/ui/components/widgets/poddr_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_confirm_dialog.dart';
import 'package:poddr/ui/components/widgets/poddr_icon_button.dart';
import 'package:poddr/ui/components/widgets/poddr_buttons.dart';
import 'package:poddr/ui/components/widgets/poddr_progress.dart';
import 'package:poddr/ui/components/widgets/color_picker.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/components/widgets/list_item.dart';
import 'package:poddr/ui/utils/gaps.dart';
import 'package:poddr/ui/utils/colors.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.read<CollectionsProvider>();

    return ChangeNotifierProvider(
      create: (_) => CollectionsViewModel(collectionsProvider),
      builder: (context, child) {
        return const _CollectionsView();
      },
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = context.watch<CollectionsProvider>();
    final viewModel = context.read<CollectionsViewModel>();

    return StreamBuilder<List<PodcastCollection>>(
      stream: collectionsProvider.collectionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: PoddrSpinner()),
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

        final collections = snapshot.data ?? [];

        return Column(
          children: [
            if (collections.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No collections yet. Create one to organize your podcasts!',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: context.theme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final collection in collections)
                _CollectionListItem(
                  collection: collection,
                  onEdit: () => _handleEdit(context, collection, viewModel),
                  onDelete: () =>
                      _showDeleteConfirmation(context, collection, viewModel),
                ),
            gapH16,
            _AddCollectionRow(viewModel: viewModel),
          ],
        );
      },
    );
  }

  Future<void> _handleEdit(BuildContext context, PodcastCollection collection,
      CollectionsViewModel viewModel) async {
    final result = await CollectionDialog.show(context, collection: collection);
    if (result != null) {
      final (name, color) = result;
      if (name != collection.name) {
        await viewModel.updateCollectionName(collection.id, name);
      }
      if (color != collection.color) {
        await viewModel.updateCollectionColor(collection.id, color);
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context,
      PodcastCollection collection, CollectionsViewModel viewModel) async {
    final confirmed = await showPoddrDialog<bool>(
      context: context,
      builder: (dialogContext) => PoddrConfirmDialog(
        title: 'Delete Collection',
        message: 'Are you sure you want to delete "${collection.name}"?',
        confirmLabel: 'Delete',
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed == true) {
      await viewModel.deleteCollection(collection.id);
    }
  }
}

class _CollectionListItem extends StatelessWidget {
  final PodcastCollection collection;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollectionListItem({
    required this.collection,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PoddrListItem(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Color(collection.color),
          shape: BoxShape.circle,
        ),
      ),
      title: collection.name,
      actions: [
        PoddrIconButton(
          icon: const Icon(LucideIcons.pencil),
          onPressed: onEdit,
        ),
        PoddrIconButton(
          icon: const Icon(LucideIcons.trash),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _AddCollectionRow extends StatelessWidget {
  final CollectionsViewModel viewModel;

  const _AddCollectionRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PoddrTextInput(
            controller: viewModel.nameController,
            onSubmit: (val) => viewModel.submitNewCollection(),
            labelText: 'New Collection',
            hintText: 'Enter name...',
          ),
        ),
        gapW8,
        GestureDetector(
          onTap: () => _showColorPicker(context),
          child: Consumer<CollectionsViewModel>(
            builder: (context, vm, child) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(vm.newCollectionColor),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.theme.outline,
                    width: 1,
                  ),
                ),
              );
            },
          ),
        ),
        gapW8,
        PoddrIconButton(
          onPressed: () => viewModel.submitNewCollection(),
          icon: const Icon(LucideIcons.plus),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
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
                'Select Color',
                style: context.theme.textTheme.titleMedium,
              ),
              gapH16,
              HsvColorPicker(
                initialColor: Color(viewModel.newCollectionColor),
                onColorChanged: (color) {
                  viewModel.setNewCollectionColor(color.toARGB32());
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

class CollectionDialog extends StatefulWidget {
  final PodcastCollection? collection;

  const CollectionDialog({
    super.key,
    this.collection,
  });

  static Future<(String, int)?> show(BuildContext context,
      {PodcastCollection? collection}) {
    return showPoddrDialog<(String, int)>(
      context: context,
      builder: (dialogContext) => CollectionDialog(collection: collection),
    );
  }

  @override
  State<CollectionDialog> createState() => _CollectionDialogState();
}

class _CollectionDialogState extends State<CollectionDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  String _error = '';

  bool get isEditing => widget.collection != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.collection?.name ?? '');
    _selectedColor = widget.collection != null
        ? Color(widget.collection!.color)
        : generateRandomColor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Collection name cannot be empty');
      return;
    }

    Navigator.of(context).pop((name, _selectedColor.toARGB32()));
  }

  @override
  Widget build(BuildContext context) {
    return PoddrDialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Collection' : 'New Collection',
                  style: context.theme.textTheme.headlineSmall,
                ),
                PoddrIconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name field
            PoddrTextInput(
              controller: _nameController,
              labelText: 'Collection Name',
              hintText: 'Enter name...',
              errorText: _error.isNotEmpty ? _error : null,
              autofocus: true,
              onChanged: (_) {
                if (_error.isNotEmpty) setState(() => _error = '');
              },
            ),
            const SizedBox(height: 24),

            // Color picker
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

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PoddrTextButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                const SizedBox(width: 8),
                PoddrFilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
