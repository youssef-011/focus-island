import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  const FloatingParticles({
    super.key,
    this.count = 12,
    this.color = Colors.white,
    this.minSize = 4,
    this.maxSize = 10,
    this.maxOpacity = 0.18,
    this.verticalDrift = 14,
    this.padding = const EdgeInsets.fromLTRB(20, 40, 20, 56),
    this.duration = const Duration(seconds: 12),
  });

  final int count;
  final Color color;
  final double minSize;
  final double maxSize;
  final double maxOpacity;
  final double verticalDrift;
  final EdgeInsets padding;
  final Duration duration;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.maxWidth - widget.padding.horizontal;
          final availableHeight =
              constraints.maxHeight - widget.padding.vertical;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value * math.pi * 2;

              return Stack(
                children: List.generate(widget.count, (index) {
                  final seed = index + 1.0;
                  final baseX = (math.sin(seed * 1.73) + 1) / 2;
                  final baseY = (math.cos(seed * 2.27) + 1) / 2;
                  final sizeFactor = (index % 4) / 3;
                  final size =
                      widget.minSize +
                      (widget.maxSize - widget.minSize) * sizeFactor;

                  final horizontalShift = math.sin(progress + seed) * 10;
                  final verticalShift =
                      math.cos(progress * 0.82 + seed * 1.6) *
                      widget.verticalDrift;

                  final left =
                      widget.padding.left +
                      ((availableWidth - size).clamp(0.0, double.infinity) *
                          baseX) +
                      horizontalShift;
                  final top =
                      widget.padding.top +
                      ((availableHeight - size).clamp(0.0, double.infinity) *
                          baseY) +
                      verticalShift;

                  final opacity =
                      (widget.maxOpacity *
                              (0.45 +
                                  0.55 *
                                      ((math.sin(progress + seed * 2.1) + 1) /
                                          2)))
                          .clamp(0.0, 1.0);

                  return Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(alpha: opacity),
                      ),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}
