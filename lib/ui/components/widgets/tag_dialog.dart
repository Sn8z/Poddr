import 'dart:math';
import 'package:flutter/material.dart';
import 'package:poddr/models/tag.dart';
import 'package:poddr/ui/components/widgets/color_picker.dart';

class TagDialog extends StatefulWidget {
  final PodcastTag? tag;

  const TagDialog({
    super.key,
    this.tag,
  });

  static Future<bool?> show(BuildContext context, {PodcastTag? tag}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => TagDialog(tag: tag),
    );
  }

  @override
  State<TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<TagDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  String _error = '';

  bool get isEditing => widget.tag != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor =
        widget.tag != null ? Color(widget.tag!.color) : _generateRandomColor();
  }

  Color _generateRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    const saturation = 0.6;
    const lightness = 0.5;
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Tag name cannot be empty');
      return;
    }

    Navigator.of(context).pop(true);
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Tag' : 'New Tag',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tag Name',
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
                    onPressed: () => Navigator.of(context).pop(false),
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
      ),
    );
  }
}
