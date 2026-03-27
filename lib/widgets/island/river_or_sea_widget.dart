import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RiverOrSeaWidget extends StatefulWidget {
  const RiverOrSeaWidget({
    super.key,
    this.height = 170,
    this.bottomOffset = -30,
    this.topRadius = 60,
  });

  final double height;
  final double bottomOffset;
  final double topRadius;

  @override
  State<RiverOrSeaWidget> createState() => _RiverOrSeaWidgetState();
}

class _RiverOrSeaWidgetState extends State<RiverOrSeaWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomOffset,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final wave = _controller.value * math.pi * 2;

            return SizedBox(
              height: widget.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.softBlue.withValues(alpha: 0.12),
                          AppColors.riverBlue.withValues(alpha: 0.28),
                          AppColors.oceanBlue.withValues(alpha: 0.58),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(widget.topRadius),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 22 + (math.sin(wave) * 8),
                    left: 28 + (math.cos(wave) * 10),
                    child: _WaterGlow(
                      width: 132,
                      height: 44,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: 74 + (math.cos(wave * 0.8) * 10),
                    right: 30 + (math.sin(wave * 1.2) * 12),
                    child: _WaterGlow(
                      width: 176,
                      height: 58,
                      color: AppColors.accentMint.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: 48 + (math.sin(wave * 1.1) * 6),
                    left: 110 + (math.cos(wave * 1.3) * 8),
                    child: _WaterGlow(
                      width: 82,
                      height: 26,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(widget.topRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaterGlow extends StatelessWidget {
  const _WaterGlow({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
