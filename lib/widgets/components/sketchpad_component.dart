/// A Flutter widget that renders a Sketchpad component.
///
/// Advanced drawing component with multiple tools:
/// - Multiple brush colors
/// - Adjustable brush size
/// - Eraser tool
/// - Clear canvas
/// - Export as base64 PNG
library;

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class SketchpadComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current sketch value as base64 PNG.
  final String? value;

  /// Callback triggered when the sketch changes.
  final ValueChanged<String?> onChanged;

  const SketchpadComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SketchpadComponent> createState() => _SketchpadComponentState();
}

class _SketchpadComponentState extends State<SketchpadComponent> {
  final _points = <DrawingPoint>[];
  final _globalKey = GlobalKey();

  Color? _selectedColor;
  double _strokeWidth = 3.0;
  bool _isEraser = false;

  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  bool get _isRequired => widget.component.required;

  void _clear() {
    setState(() {
      _points.clear();
    });
    widget.onChanged(null);
  }

  void _undo() {
    if (_points.isEmpty) return;
    setState(() {
      // Remove points until we hit a null (stroke separator)
      do {
        _points.removeLast();
      } while (_points.isNotEmpty && _points.last.offset != null);
    });
    _saveSketch();
  }

  Future<void> _saveSketch() async {
    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null && _points.isNotEmpty) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();
        if (pngBytes != null) {
          final base64Image = base64Encode(pngBytes);
          widget.onChanged('data:image/png;base64,$base64Image');
        }
      }
    } catch (e) {
      debugPrint('Error saving sketch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = _selectedColor ?? colorScheme.primary;
    final hasError = _isRequired && (widget.value == null || _points.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(widget.component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),

        // Toolbar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Color picker
              Row(
                children: [
                  const Text('Color: ', style: TextStyle(fontSize: 12)),
                  ..._colors.map((color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                            _isEraser = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: activeColor == color && !_isEraser ? colorScheme.primary : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(width: 8),
                  // Eraser
                  GestureDetector(
                    onTap: () => setState(() => _isEraser = true),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isEraser ? colorScheme.primaryContainer : colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: const Icon(Icons.cleaning_services, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Brush size
              Row(
                children: [
                  const Text('Size: ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: _strokeWidth.toInt().toString(),
                      onChanged: (value) => setState(() => _strokeWidth = value),
                    ),
                  ),
                  Text('${_strokeWidth.toInt()}px', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Canvas
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: RepaintBoundary(
              key: _globalKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Listener(
                    onPointerDown: (event) {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        setState(() {
                          _points.add(DrawingPoint(
                            offset: details.localPosition,
                            color: _isEraser ? colorScheme.surfaceContainerHighest : activeColor,
                            strokeWidth: _isEraser ? _strokeWidth * 3 : _strokeWidth,
                          ));
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _points.add(DrawingPoint(
                            offset: details.localPosition,
                            color: _isEraser ? colorScheme.surfaceContainerHighest : activeColor,
                            strokeWidth: _isEraser ? _strokeWidth * 3 : _strokeWidth,
                          ));
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _points.add(DrawingPoint(offset: null));
                        });
                        _saveSketch();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: CustomPaint(
                          painter: _SketchPainter(_points),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _points.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo),
              label: Text(ComponentFactory.locale.undo),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _points.isEmpty ? null : _clear,
              icon: const Icon(Icons.clear),
              label: Text(ComponentFactory.locale.clear),
            ),
          ],
        ),

        // Error
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${widget.component.label} is required.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class DrawingPoint {
  final Offset? offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    this.offset,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
  });
}

class _SketchPainter extends CustomPainter {
  final List<DrawingPoint> points;

  _SketchPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawLine(points[i].offset!, points[i + 1].offset!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SketchPainter oldDelegate) => true;
}
