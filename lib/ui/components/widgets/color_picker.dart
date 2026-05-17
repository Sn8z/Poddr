import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/components/widgets/poddr_slider.dart';

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

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColor() {
    final color = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    final hexString = '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color preview
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              hexString,
              style: TextStyle(
                color: _value > 0.5 ? context.theme.onSurface : context.theme.surface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Hue slider
        _SliderRow(
          label: 'Hue',
          value: _hue,
          min: 0,
          max: 360,
          activeColor: HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
          onChanged: (value) {
            setState(() => _hue = value);
            _updateColor();
          },
          gradient: LinearGradient(
            colors: List.generate(
              7,
              (i) => HSVColor.fromAHSV(1.0, i * 60.0, 1.0, 1.0).toColor(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Saturation slider
        _SliderRow(
          label: 'Saturation',
          value: _saturation,
          min: 0,
          max: 1,
          activeColor: currentColor,
          onChanged: (value) {
            setState(() => _saturation = value);
            _updateColor();
          },
          gradient: LinearGradient(
            colors: [
              HSVColor.fromAHSV(1.0, _hue, 0.0, _value).toColor(),
              HSVColor.fromAHSV(1.0, _hue, 1.0, _value).toColor(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Brightness slider
        _SliderRow(
          label: 'Brightness',
          value: _value,
          min: 0,
          max: 1,
          activeColor: currentColor,
          onChanged: (value) {
            setState(() => _value = value);
            _updateColor();
          },
          gradient: LinearGradient(
            colors: [
              const Color(0xFF000000),
              HSVColor.fromAHSV(1.0, _hue, _saturation, 1.0).toColor(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final Gradient? gradient;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.onChanged,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.theme.textTheme.bodyMedium,
            ),
            Text(
              max > 1 ? value.round().toString() : '${(value * 100).round()}%',
              style: context.theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: PoddrSlider(
            value: value,
            min: min,
            max: max,
            trackHeight: 24,
            activeGradient: gradient,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
