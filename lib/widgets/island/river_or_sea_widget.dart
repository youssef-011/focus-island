import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RiverOrSeaWidget extends StatelessWidget {
  const RiverOrSeaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -30,
      left: 0,
      right: 0,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.softBlue.withValues(alpha: 0.15),
              AppColors.riverBlue.withValues(alpha: 0.35),
              AppColors.oceanBlue.withValues(alpha: 0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(60),
          ),
        ),
      ),
    );
  }
}