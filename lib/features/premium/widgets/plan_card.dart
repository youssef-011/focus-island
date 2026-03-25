import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/premium_plan.dart';

class PlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen.withOpacity(0.15)
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.accentMint : AppColors.borderWhite,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan.isBestValue)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              /// 🔥 FIXED ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        /// 🔥 PRICE FIX
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                plan.price,
                                style: const TextStyle(
                                  color: AppColors.accentMint,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                plan.period,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// CHECK ICON
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentMint
                            : AppColors.borderWhite,
                        width: 2,
                      ),
                      color: isSelected
                          ? AppColors.accentMint
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                        size: 16, color: AppColors.background)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// FEATURES
              ...plan.features.map(
                    (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.lightGreen, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}