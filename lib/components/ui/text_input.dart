import 'package:flutter/material.dart';

class PoddrTextInput extends StatelessWidget {
  const PoddrTextInput({
    super.key,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
    this.hintText,
    this.autofocus = false,
    this.obscure = false,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: Theme.of(context).colorScheme.primary,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        hoverColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      autofocus: autofocus,
      obscureText: obscure,
      cursorColor: Theme.of(context).colorScheme.onSurface,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
