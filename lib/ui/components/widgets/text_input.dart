import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

enum PoddrTextInputValidateMode {
  onChanged,
  onFocusLost,
  onSubmit,
}

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
    this.readOnly = false,
    this.enabled = true,
    this.validator,
    this.validateMode = PoddrTextInputValidateMode.onFocusLost,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.height,
    this.minHeight,
    this.fontSize,
    this.selectionColor,
    this.backgroundColor,
    this.foregroundColor,
  }) : assert(
          maxLines == null || maxLines > 0,
          'maxLines must be null or greater than zero.',
        );

  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final String? labelText;
  final String? hintText;
  // External error always takes priority over validator error
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool obscure;
  final bool readOnly;
  final bool enabled;
  final String? Function(String?)? validator;
  final PoddrTextInputValidateMode validateMode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final double? height;
  final double? minHeight;
  final double? fontSize;
  final Color? selectionColor;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<PoddrTextInput> createState() => _PoddrTextInputState();
}

class _PoddrTextInputState extends State<PoddrTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  String? _validatorError;

  // External errorText always wins; validator error only shows when no external error
  String? get _displayError => widget.errorText ?? _validatorError;
  bool get _hasError => _displayError != null;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    // Validate on focus lost
    if (!hasFocus &&
        widget.validateMode == PoddrTextInputValidateMode.onFocusLost) {
      _runValidator(_controller.text);
    }
    setState(() {
      _hasFocus = hasFocus;
    });
  }

  void _runValidator(String value) {
    if (widget.validator != null) {
      setState(() {
        _validatorError = widget.validator!(value);
      });
    }
  }

  void _onChanged(String value) {
    if (widget.validateMode == PoddrTextInputValidateMode.onChanged) {
      _runValidator(value);
    }
    widget.onChanged?.call(value);
  }

  void _onSubmitted(String value) {
    if (widget.validateMode == PoddrTextInputValidateMode.onSubmit) {
      _runValidator(value);
    }
    widget.onSubmit?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final borderColor = _hasError
        ? theme.error
        : _hasFocus
            ? theme.primary
            : const Color(0x00000000);

    final effectiveFontSize = widget.fontSize ?? 14.0;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationTextIntent(),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Semantics(
              label: widget.labelText,
              child: Text(
                widget.labelText!,
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  color:
                      widget.enabled ? theme.onSurface : theme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Semantics(
            textField: true,
            label: widget.labelText ?? widget.hintText,
            hint: widget.hintText,
            readOnly: widget.readOnly,
            enabled: widget.enabled,
            child: Listener(
              onPointerDown: widget.enabled && !widget.readOnly
                  ? (_) => _focusNode.requestFocus()
                  : null,
              behavior: HitTestBehavior.translucent,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: widget.minHeight ?? 40.0,
                ),
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? (widget.enabled
                      ? theme.surfaceContainerLowest
                      : theme.surfaceContainerLowest.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: widget.maxLines != 1 ? 10.0 : 8.0,
                ),
                child: Row(
                  crossAxisAlignment: widget.maxLines != 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
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
                        readOnly: widget.readOnly,
                        enabled: widget.enabled,
                        hintText: widget.hintText,
                        onChanged: _onChanged,
                        onSubmitted: _onSubmitted,
                        autofocus: widget.autofocus,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        inputFormatters: [
                          if (widget.maxLength != null)
                            LengthLimitingTextInputFormatter(widget.maxLength),
                          ...?widget.inputFormatters,
                        ],
                        textCapitalization: widget.textCapitalization,
                        autocorrect: widget.autocorrect,
                        enableSuggestions: widget.enableSuggestions,
                        maxLines: widget.obscure ? 1 : widget.maxLines,
                        minLines: widget.minLines,
                        fontSize: effectiveFontSize,
                        selectionColor: widget.selectionColor ??
                            theme.primary.withValues(alpha: 0.3),
                        foregroundColor: widget.foregroundColor,
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
          ),
          if (_displayError != null) ...[
            const SizedBox(height: 4),
            Text(
              _displayError!,
              style: TextStyle(
                color: theme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableTextField extends StatelessWidget {
  const _EditableTextField({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.readOnly,
    required this.enabled,
    required this.fontSize,
    required this.selectionColor,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.foregroundColor,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final bool readOnly;
  final bool enabled;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final double fontSize;
  final Color selectionColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textStyle = TextStyle(
      color: foregroundColor ?? (enabled ? theme.onSurface : theme.onSurfaceVariant),
      fontSize: fontSize,
    );

    return Stack(
      alignment: maxLines == 1 ? Alignment.centerLeft : Alignment.topLeft,
      children: [
        if (hintText != null)
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.text.isNotEmpty) return const SizedBox.shrink();
              return Text(
                hintText!,
                style: textStyle.copyWith(color: theme.onSurfaceVariant),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        EditableText(
          controller: controller,
          focusNode: focusNode,
          style: textStyle,
          cursorColor: foregroundColor ?? theme.onSurface,
          backgroundCursorColor: theme.onSurfaceVariant,
          selectionColor: selectionColor,
          obscureText: obscure,
          readOnly: readOnly || !enabled,
          keyboardType: keyboardType ??
              (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
        ),
      ],
    );
  }
}
