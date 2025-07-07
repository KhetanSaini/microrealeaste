import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final String title;
  final Function(Color) onColorChanged;
  final bool showAlpha;

  const ColorPickerWidget({
    super.key,
    required this.initialColor,
    required this.title,
    required this.onColorChanged,
    this.showAlpha = false,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;
  late double _hue;
  late double _saturation;
  late double _value;
  late double _alpha;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _updateHSVFromColor(_selectedColor);
  }

  void _updateHSVFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _alpha = color.opacity;
  }

  void _updateColor() {
    final newColor = HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor();
    setState(() {
      _selectedColor = newColor;
    });
    widget.onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color previewTextColor = _selectedColor.computeLuminance() > 0.5
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '#${_selectedColor.value.toRadixString(16).toUpperCase().substring(2)}',
                  style: TextStyle(
                    color: previewTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hue slider
            _buildSliderRow(
              'Hue',
              _hue,
              0,
              360,
              (value) {
                setState(() {
                  _hue = value;
                });
                _updateColor();
              },
              Colors.red,
            ),
            const SizedBox(height: 12),

            // Saturation slider
            _buildSliderRow(
              'Saturation',
              _saturation,
              0,
              1,
              (value) {
                setState(() {
                  _saturation = value;
                });
                _updateColor();
              },
              HSVColor.fromAHSV(1, _hue, 1, _value).toColor(),
            ),
            const SizedBox(height: 12),

            // Value slider
            _buildSliderRow(
              'Value',
              _value,
              0,
              1,
              (value) {
                setState(() {
                  _value = value;
                });
                _updateColor();
              },
              HSVColor.fromAHSV(1, _hue, _saturation, 1).toColor(),
            ),
            const SizedBox(height: 12),

            // Alpha slider (optional)
            if (widget.showAlpha) ...[
              _buildSliderRow(
                'Alpha',
                _alpha,
                0,
                1,
                (value) {
                  setState(() {
                    _alpha = value;
                  });
                  _updateColor();
                },
                Colors.grey,
              ),
              const SizedBox(height: 12),
            ],

            // Preset colors
            _buildPresetColors(),
            const SizedBox(height: 16),

            // RGB inputs
            _buildRGBInputs(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedColor);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    Color sliderColor,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sliderColor,
              thumbColor: sliderColor,
              overlayColor: sliderColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value.toStringAsFixed(label == 'Hue' ? 0 : 2),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetColors() {
    final presetColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preset Colors',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((color) {
            final isSelected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  _updateHSVFromColor(color);
                });
                widget.onColorChanged(color);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRGBInputs() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RGB Values',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRGBInput(
                'R',
                _selectedColor.red,
                (value) {
                  final newColor = Color.fromARGB(
                    _selectedColor.alpha,
                    value,
                    _selectedColor.green,
                    _selectedColor.blue,
                  );
                  setState(() {
                    _selectedColor = newColor;
                    _updateHSVFromColor(newColor);
                  });
                  widget.onColorChanged(newColor);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRGBInput(
                'G',
                _selectedColor.green,
                (value) {
                  final newColor = Color.fromARGB(
                    _selectedColor.alpha,
                    _selectedColor.red,
                    value,
                    _selectedColor.blue,
                  );
                  setState(() {
                    _selectedColor = newColor;
                    _updateHSVFromColor(newColor);
                  });
                  widget.onColorChanged(newColor);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRGBInput(
                'B',
                _selectedColor.blue,
                (value) {
                  final newColor = Color.fromARGB(
                    _selectedColor.alpha,
                    _selectedColor.red,
                    _selectedColor.green,
                    value,
                  );
                  setState(() {
                    _selectedColor = newColor;
                    _updateHSVFromColor(newColor);
                  });
                  widget.onColorChanged(newColor);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRGBInput(String label, int value, ValueChanged<int> onChanged) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: value.toString());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (text) {
            final intValue = int.tryParse(text);
            if (intValue != null && intValue >= 0 && intValue <= 255) {
              onChanged(intValue);
            }
          },
        ),
      ],
    );
  }
}

// Utility function to show color picker
Future<Color?> showColorPicker({
  required BuildContext context,
  required Color initialColor,
  required String title,
  bool showAlpha = false,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) => ColorPickerWidget(
      initialColor: initialColor,
      title: title,
      showAlpha: showAlpha,
      onColorChanged: (color) {
        // This will be called as the user changes the color
      },
    ),
  );
} 