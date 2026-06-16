import 'dart:math';
import 'package:flutter/material.dart';

/// Flutter replica of the FloatingLines component (React Bits / Three.js)
/// Renders animated wave lines using CustomPainter + AnimationController.
class FloatingLines extends StatefulWidget {
  /// Hex color strings for gradient coloring (max 8). e.g. ['#5C7AEA', '#A78BFA']
  final List<String>? linesGradient;

  /// Which wave layers to show: 'top', 'middle', 'bottom'
  final List<String> enabledWaves;

  /// Lines per wave. Single number for all, or list per wave.
  final dynamic lineCount;

  /// Spacing between lines. Single number for all, or list per wave.
  final dynamic lineDistance;

  /// Animation speed multiplier
  final double animationSpeed;

  /// Whether lines react to mouse/pointer movement
  final bool interactive;

  /// Radius of the area affected by pointer interaction
  final double bendRadius;

  /// Intensity of the bend effect on interaction
  final double bendStrength;

  /// Smoothing for pointer movement (0-1)
  final double mouseDamping;

  /// Enable parallax effect with pointer
  final bool parallax;

  /// Strength of the parallax effect
  final double parallaxStrength;

  /// Overall opacity of the effect
  final double opacity;

  const FloatingLines({
    super.key,
    this.linesGradient,
    this.enabledWaves = const ['top', 'middle', 'bottom'],
    this.lineCount = 10,
    this.lineDistance = 5,
    this.animationSpeed = 1.0,
    this.interactive = true,
    this.bendRadius = 5.0,
    this.bendStrength = -0.5,
    this.mouseDamping = 0.05,
    this.parallax = true,
    this.parallaxStrength = 0.2,
    this.opacity = 1.0,
  });

  @override
  State<FloatingLines> createState() => _FloatingLinesState();
}

class _FloatingLinesState extends State<FloatingLines>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _mousePos = Offset.zero;
  Offset _smoothMouse = Offset.zero;
  Offset _smoothParallax = Offset.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getCount(String wave) {
    final count = widget.lineCount;
    if (count is int || count is double) return (count as num).toInt();
    if (count is List) {
      final idx = widget.enabledWaves.indexOf(wave);
      if (idx >= 0 && idx < count.length) return (count[idx] as num).toInt();
    }
    return 6;
  }

  double _getDist(String wave) {
    final dist = widget.lineDistance;
    if (dist is int || dist is double) return (dist as num).toDouble();
    if (dist is List) {
      final idx = widget.enabledWaves.indexOf(wave);
      if (idx >= 0 && idx < dist.length) return (dist[idx] as num).toDouble();
    }
    return 5.0;
  }

  List<Color> get _gradientColors {
    final grad = widget.linesGradient;
    if (grad == null || grad.isEmpty) return [];
    return grad.map(_hexToColor).toList();
  }

  Color _hexToColor(String hex) {
    String h = hex.trim().replaceAll('#', '');
    if (h.length == 3) h = h.split('').map((c) => c + c).join();
    return Color(int.parse('FF$h', radix: 16));
  }

  void _onPointerMove(PointerEvent event) {
    if (!widget.interactive) return;
    _mousePos = event.localPosition;
  }

  void _onPointerExit(PointerEvent event) {
    _mousePos = Offset(_size.width / 2, _size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerHover: _onPointerMove,
      onPointerSignal: null,
      child: MouseRegion(
        onExit: (_) => _onPointerExit,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _size = Size(constraints.maxWidth, constraints.maxHeight);
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Smooth mouse
                final target = _mousePos == Offset.zero
                    ? Offset(_size.width / 2, _size.height / 2)
                    : _mousePos;
                _smoothMouse = Offset.lerp(
                  _smoothMouse == Offset.zero ? target : _smoothMouse,
                  target,
                  widget.mouseDamping.clamp(0.01, 1.0),
                )!;

                // Parallax offset
                if (widget.parallax && _size != Size.zero) {
                  final cx = _size.width / 2;
                  final cy = _size.height / 2;
                  final px = ((_smoothMouse.dx - cx) / _size.width) *
                      widget.parallaxStrength;
                  final py = ((_smoothMouse.dy - cy) / _size.height) *
                      widget.parallaxStrength;
                  _smoothParallax = Offset.lerp(
                      _smoothParallax, Offset(px, py), 0.05)!;
                }

                final t = _controller.value * 10.0 * widget.animationSpeed;

                return Opacity(
                  opacity: widget.opacity,
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _FloatingLinesPainter(
                      time: t,
                      enabledWaves: widget.enabledWaves,
                      topCount: _getCount('top'),
                      middleCount: _getCount('middle'),
                      bottomCount: _getCount('bottom'),
                      topDist: _getDist('top'),
                      middleDist: _getDist('middle'),
                      bottomDist: _getDist('bottom'),
                      mousePos: _smoothMouse,
                      bendRadius: widget.bendRadius,
                      bendStrength: widget.bendStrength,
                      interactive: widget.interactive,
                      parallaxOffset: _smoothParallax,
                      gradientColors: _gradientColors,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FloatingLinesPainter extends CustomPainter {
  final double time;
  final List<String> enabledWaves;
  final int topCount, middleCount, bottomCount;
  final double topDist, middleDist, bottomDist;
  final Offset mousePos;
  final double bendRadius, bendStrength;
  final bool interactive;
  final Offset parallaxOffset;
  final List<Color> gradientColors;

  static const _defaultColors = [
    Color(0xFF2F4BA2), // blue
    Color(0xFFE947F5), // pink
    Color(0xFF5C7AEA), // indigo
  ];

  _FloatingLinesPainter({
    required this.time,
    required this.enabledWaves,
    required this.topCount,
    required this.middleCount,
    required this.bottomCount,
    required this.topDist,
    required this.middleDist,
    required this.bottomDist,
    required this.mousePos,
    required this.bendRadius,
    required this.bendStrength,
    required this.interactive,
    required this.parallaxOffset,
    required this.gradientColors,
  });

  List<Color> get _colors =>
      gradientColors.isNotEmpty ? gradientColors : _defaultColors;

  Color _lineColor(double t) {
    final colors = _colors;
    if (colors.length == 1) return colors[0];
    final scaled = t.clamp(0.0, 0.9999) * (colors.length - 1);
    final idx = scaled.floor().clamp(0, colors.length - 2);
    final f = scaled - idx;
    return Color.lerp(colors[idx], colors[idx + 1], f)!;
  }

  // Compute Y offset for a single line at X position
  double _waveY(
    double xNorm, // normalized x in [-1, 1]
    double yBase, // base y offset in normalized space
    double offset,
    double rotateAngle,
    double canvasW,
    double canvasH, {
    bool flipX = false,
  }) {
    // apply rotation
    final cosR = cos(rotateAngle);
    final sinR = sin(rotateAngle);
    double rx = flipX ? -xNorm : xNorm;
    // rotate
    final nx = rx * cosR - yBase * sinR;
    final ny = rx * sinR + yBase * cosR;

    final xOffset = offset;
    final xMovement = time * 0.1;
    final amp = sin(offset + time * 0.2) * 0.3;
    return ny + sin(nx + xOffset + xMovement) * amp;
  }

  void _drawLayer(
    Canvas canvas,
    Size size,
    String wave,
    int count,
    double dist,
    double rotateAngle,
    double yOffset,
    double xOffset,
    double opacityMult, {
    bool flipX = false,
  }) {
    if (!enabledWaves.contains(wave) || count == 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.height;

    // Mouse in normalized space
    final mx = interactive ? (mousePos.dx - cx) / scale : 0.0;
    final my = interactive ? (mousePos.dy - cy) / scale : 0.0;

    for (int i = 0; i < count; i++) {
      final fi = i.toDouble();
      final t = count > 1 ? fi / (count - 1) : 0.0;
      final lineColor = _lineColor(t);
      final paint = Paint()
        ..color = lineColor.withValues(alpha: opacityMult * 0.85)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final lineOffset = dist * fi * 0.01 + xOffset;

      final path = Path();
      const steps = 120;
      bool first = true;

      for (int s = 0; s <= steps; s++) {
        final xPixel = s / steps * size.width;
        final xNorm = (xPixel - cx) / scale + parallaxOffset.dx;
        final yNorm = yOffset + parallaxOffset.dy;

        double y = _waveY(
          xNorm, yNorm, lineOffset + fi * 0.2, rotateAngle, size.width, size.height,
          flipX: flipX,
        );

        // Mouse bend
        if (interactive) {
          final dx = xNorm - mx;
          final dy = yNorm - my;
          final dist2 = dx * dx + dy * dy;
          final influence = exp(-dist2 * bendRadius);
          y += (my - yNorm) * influence * bendStrength;
        }

        final yPixel = cy + y * scale;

        if (first) {
          path.moveTo(xPixel, yPixel);
          first = false;
        } else {
          path.lineTo(xPixel, yPixel);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom layer (subtle, 20% opacity)
    _drawLayer(
      canvas, size, 'bottom',
      bottomCount, bottomDist,
      -1.0 * log(1.0 + 0.5), // rotate ~= -0.4
      -0.7, 2.0, 0.18,
    );

    // Middle layer (full)
    _drawLayer(
      canvas, size, 'middle',
      middleCount, middleDist,
      0.2 * log(1.0 + 0.5),
      0.0, 5.0, 0.65,
    );

    // Top layer (subtle, 10% opacity, flipped x)
    _drawLayer(
      canvas, size, 'top',
      topCount, topDist,
      -0.4 * log(1.0 + 0.5),
      0.5, 10.0, 0.35,
      flipX: true,
    );
  }

  @override
  bool shouldRepaint(_FloatingLinesPainter old) => true;
}
