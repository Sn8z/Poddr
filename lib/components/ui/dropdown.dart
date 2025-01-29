import 'package:flutter/material.dart';

class PoddrDropDown extends StatelessWidget {
  const PoddrDropDown({
    super.key,
    required this.items,
    required this.onSelected,
    this.initialSelection,
    this.leading,
  });

  final List<DropdownMenuEntry<String>> items;
  final void Function(String?) onSelected;
  final String? initialSelection;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: initialSelection ?? items[0].value,
      dropdownMenuEntries: items,
      onSelected: onSelected,
      enableSearch: true,
      enableFilter: false,
      leadingIcon: leading,
      width: 160,
      requestFocusOnTap: true,
      trailingIcon: const Icon(Icons.arrow_drop_down_rounded),
      selectedTrailingIcon: const Icon(Icons.arrow_drop_up_rounded),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      menuStyle: const MenuStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        fixedSize: WidgetStatePropertyAll(
          Size(160, 160),
        ),
      ),
    );
  }
}
