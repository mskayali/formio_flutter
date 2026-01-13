/// A Flutter widget that renders a signature input field based on
/// a Form.io "signature" component.
///
/// Allows the user to draw a signature on a canvas. The signature
/// is captured as a base64-encoded PNG image string.
library;

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/component.dart';
import '../../models/formio_locale.dart';

class SignatureComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current signature value as a base64-encoded PNG.
  final String? value;

  /// Callback triggered when the signature is drawn.
  final ValueChanged<String?> onChanged;

  /// Localization strings
  final FormioLocale locale;

  const SignatureComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.locale = const FormioLocale(),
  });

  @override
  State<SignatureComponent> createState() => _SignatureComponentState();
}

class _SignatureComponentState extends State<SignatureComponent> {
  final _points = <Offset?>[];
  final _globalKey = GlobalKey();

  bool get _isRequired => widget.component.required;

  void _clear() {
    setState(() {
      _points.clear();
    });
    widget.onChanged(null);
  }

  Future<void> _saveSignature() async {
    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null && _points.isNotEmpty) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();
        if (pngBytes != null) {
          final base64Image = base64Encode(pngBytes);
          widget.onChanged('data:image/png;base64,$base64Image');
        }
      }
    } catch (e) {
      debugPrint('Error saving signature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && (widget.value == null || _points.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: RepaintBoundary(
              key: _globalKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Listener(
                    onPointerDown: (event) {
                      // This prevents scroll gestures from interfering
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _points.add(null); // Add null to separate strokes
                        });
                        _saveSignature();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: CustomPaint(
                          painter: _SignaturePainter(_points, Theme.of(context).colorScheme.onSurfaceVariant),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _points.isEmpty ? null : _clear,
              icon: const Icon(Icons.clear),
              label: Text(widget.locale.clear),
            ),
          ],
        ),
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

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  final Color color;
  _SignaturePainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
