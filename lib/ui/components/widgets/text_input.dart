import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrTextInput extends StatefulWidget {
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
    this.errorText,
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
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool obscure;
  final String? Function(String?)? validator;

  @override
  State<PoddrTextInput> createState() => _PoddrTextInputState();
}

class _PoddrTextInputState extends State<PoddrTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onSubmitted(String value) {
    widget.onSubmit?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasError = _errorText != null || widget.errorText != null;
    final displayError = _errorText ?? widget.errorText;

    final borderColor = hasError
        ? theme.error
        : _hasFocus
            ? theme.primary
            : theme.outline.withAlpha(128);

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationTextIntent(),
      },
      child: Focus(
        focusNode: _focusNode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: TextStyle(
                  color: theme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
            ],
            GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: _hasFocus ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: _EditableTextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        obscure: widget.obscure,
                        hintText: widget.hintText,
                        onSubmitted: _onSubmitted,
                        autofocus: widget.autofocus,
                      ),
                    ),
                    if (widget.suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      widget.suffixIcon!,
                    ],
                  ],
                ),
              ),
            ),
            if (displayError != null) ...[
              const SizedBox(height: 4),
              Text(
                displayError,
                style: TextStyle(
                  color: theme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const _EditableTextField({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    this.hintText,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  State<_EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<_EditableTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return EditableText(
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: TextStyle(color: theme.onSurface, fontSize: 14),
      cursorColor: theme.onSurface,
      backgroundCursorColor: theme.onSurfaceVariant,
      obscureText: widget.obscure,
      keyboardType: TextInputType.text,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      maxLines: 1,
    );
  }
}
