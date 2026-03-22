import 'package:flutter/material.dart';

class FloatingParticles extends StatelessWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(12, (index) {
          final top = 40.0 + (index * 45);
          final left = (index % 2 == 0) ? 30.0 + (index * 12) : null;
          final right = (index % 2 != 0) ? 20.0 + (index * 10) : null;

          return Positioned(
            top: top,
            left: left,
            right: right,
            child: Container(
              width: 6 + (index % 3).toDouble() * 2,
              height: 6 + (index % 3).toDouble() * 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}