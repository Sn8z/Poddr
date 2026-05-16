import 'package:flutter/material.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:flutter/services.dart';

class PoddrTextInput extends StatelessWidget {
  const PoddrTextInput({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmit,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
    this.hintText,
    this.autofocus = false,
    this.obscure = false,
    this.validator,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool obscure;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationTextIntent(),
      },
      child: TextFormField(
        initialValue: controller == null ? initialValue : null,
        controller: controller,
        onChanged: onChanged,
        onFieldSubmitted: onSubmit,
        style: TextStyle(color: theme.onSurface),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.outline.withAlpha(128)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primary, width: 2),
          ),
          prefixIconColor: theme.primary,
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: theme.surfaceContainerLow,
          hoverColor: theme.surfaceContainer,
        ),
        autofocus: autofocus,
        obscureText: obscure,
        cursorColor: theme.onSurface,
        validator: validator,
      ),
    );
  }
}
