import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poddr/services/collections.dart';
import 'package:poddr/models/collection.dart';
import 'package:poddr/ui/views/settings/collections/collections_view_model.dart';
import 'package:poddr/ui/components/widgets/dialog.dart';
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "${collection.name}"?'),
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
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
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
        gapW12,
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
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              );
            },
          ),
        ),
        gapW12,
        FilledButton(
          onPressed: () => viewModel.submitNewCollection(),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PoddrDialog(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                gapH16,
                Consumer<CollectionsViewModel>(
                  builder: (context, vm, child) {
                    return HsvColorPicker(
                      initialColor: Color(vm.newCollectionColor),
                      onColorChanged: (color) {
                        vm.setNewCollectionColor(color.toARGB32());
                      },
                    );
                  },
                ),
                gapH24,
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
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
    return showDialog<(String, int)>(
      context: context,
      builder: (context) => CollectionDialog(collection: collection),
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

    Navigator.of(context).pop((name, _selectedColor.value));
  }

  @override
  Widget build(BuildContext context) {
    return PoddrDialog(
      children: [
        Padding(
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Collection Name',
                  border: const OutlineInputBorder(),
                  errorText: _error.isNotEmpty ? _error : null,
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
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
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
