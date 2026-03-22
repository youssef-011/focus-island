import 'package:flutter/material.dart';
import '../models/real_forest_tree_model.dart';

class RealForestProvider extends ChangeNotifier {
  final List<RealForestTreeModel> _trees = const [
    RealForestTreeModel(
      title: 'Mangrove Recovery',
      location: 'Indonesia',
      date: '12 Mar 2026',
      treesCount: 120,
      status: 'Active',
    ),
    RealForestTreeModel(
      title: 'Desert Edge Planting',
      location: 'Egypt',
      date: '08 Mar 2026',
      treesCount: 80,
      status: 'Completed',
    ),
    RealForestTreeModel(
      title: 'Rainforest Support',
      location: 'Brazil',
      date: '28 Feb 2026',
      treesCount: 150,
      status: 'Active',
    ),
  ];

  List<RealForestTreeModel> get trees => _trees;

  int get totalTrees =>
      _trees.fold(0, (sum, item) => sum + item.treesCount);

  int get nextGoal => 500;
}