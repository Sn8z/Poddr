import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poddr/ui/components/widgets/poddr_slider.dart';
import 'package:poddr/ui/components/widgets/text_input.dart';
import 'package:poddr/ui/utils/gaps.dart';

class HsvColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const HsvColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;
  late TextEditingController _hexController;
  bool _updatingHexFromPicker = false;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _hexController =
        TextEditingController(text: _formatHex(widget.initialColor));
    _hexController.addListener(_onHexChanged);
  }

  @override
  void dispose() {
    _hexController.removeListener(_onHexChanged);
    _hexController.dispose();
    super.dispose();
  }

  String _formatHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  void _onHexChanged() {
    if (_updatingHexFromPicker) return;

    var text = _hexController.text;
    if (text.startsWith('#')) {
      _updatingHexFromPicker = true;
      _hexController.value = _hexController.value.copyWith(
        text: text.substring(1),
        selection: TextSelection.collapsed(
          offset: (_hexController.selection.baseOffset - 1).clamp(0, 5),
        ),
      );
      _updatingHexFromPicker = false;
      text = _hexController.text;
    }

    if (text.length != 6) return;

    final intValue = int.tryParse(text, radix: 16);
    if (intValue == null) return;

    final color = Color(0xFF000000 | intValue);
    final hsv = HSVColor.fromColor(color);

    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
    });

    _notifyColorChanged();
  }

  void _syncHexAndNotify() {
    final color = _currentColor;
    _updatingHexFromPicker = true;
    _hexController.text = _formatHex(color);
    _updatingHexFromPicker = false;
    widget.onColorChanged(color);
  }

  void _notifyColorChanged() {
    widget.onColorChanged(_currentColor);
  }

  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();

  @override
  Widget build(BuildContext context) {
    final currentColor = _currentColor;
    final hsl = HSLColor.fromColor(currentColor);
    final textColor =
        hsl.lightness > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoddrTextInput(
          controller: _hexController,
          backgroundColor: currentColor,
          foregroundColor: textColor,
          prefixIcon: Text(
            '#',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
          ],
          maxLength: 6,
          fontSize: 16,
        ),
        gapH16,
        _SaturationValuePicker(
          hue: _hue,
          saturation: _saturation,
          value: _value,
          onChanged: (s, v) {
            setState(() {
              _saturation = s;
              _value = v;
            });
            _syncHexAndNotify();
          },
        ),
        gapH16,
        PoddrSlider(
          value: _hue,
          min: 0,
          max: 360,
          trackHeight: 16,
          activeColor: const Color(0x00000000),
          inactiveGradient: LinearGradient(
            colors: List.generate(
              7,
              (i) => HSVColor.fromAHSV(1.0, i * 60.0, 1.0, 1.0).toColor(),
            ),
          ),
          thumbRadius: 18,
          thumbColor: HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
          thumbVisibility: PoddrThumbVisibility.always,
          onChanged: (value) {
            setState(() => _hue = value);
            _syncHexAndNotify();
          },
        ),
      ],
    );
  }
}

class _SaturationValuePicker extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  const _SaturationValuePicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 180.0;
        final hueColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();

        return GestureDetector(
          onPanDown: (details) =>
              _updateFromPosition(details.localPosition, width, height),
          onPanUpdate: (details) =>
              _updateFromPosition(details.localPosition, width, height),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _SaturationValuePainter(
                  hueColor: hueColor,
                  saturation: saturation,
                  value: value,
                  hue: hue,
                ),
                size: Size(width, height),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateFromPosition(Offset position, double width, double height) {
    final s = (position.dx / width).clamp(0.0, 1.0);
    final v = (1.0 - position.dy / height).clamp(0.0, 1.0);
    onChanged(s, v);
  }
}

class _SaturationValuePainter extends CustomPainter {
  final Color hueColor;
  final double hue;
  final double saturation;
  final double value;

  const _SaturationValuePainter({
    required this.hueColor,
    required this.hue,
    required this.saturation,
    required this.value,
  });

  Color get _thumbColor =>
      HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = hueColor);

    final whiteShader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFFFFFFF), Color(0x00000000)],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = whiteShader);

    final blackShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0xFF000000)],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = blackShader);

    final thumbX = saturation * size.width;
    final thumbY = (1.0 - value) * size.height;

    canvas.drawCircle(
      Offset(thumbX, thumbY + 2),
      12,
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      Offset(thumbX, thumbY),
      10,
      Paint()..color = _thumbColor,
    );

    canvas.drawCircle(
      Offset(thumbX, thumbY),
      10,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_SaturationValuePainter oldDelegate) =>
      oldDelegate.hueColor != hueColor ||
      oldDelegate.hue != hue ||
      oldDelegate.saturation != saturation ||
      oldDelegate.value != value;
}
