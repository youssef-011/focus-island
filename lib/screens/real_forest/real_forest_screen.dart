import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/real_forest_provider.dart';
import '../../widgets/real_forest/donation_progress_card.dart';
import '../../widgets/real_forest/forest_tree_card.dart';

class RealForestScreen extends StatelessWidget {
  const RealForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RealForestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Real Forest'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          children: [
            DonationProgressCard(
              totalTrees: provider.totalTrees,
              nextGoal: provider.nextGoal,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.trees.length,
                itemBuilder: (context, index) {
                  return ForestTreeCard(tree: provider.trees[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}