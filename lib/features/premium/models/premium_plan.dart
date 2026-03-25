class PremiumPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isBestValue;
  final double priceValue;

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isBestValue = false,
    required this.priceValue,
  });
}

class PremiumData {
  static const List<PremiumPlan> plans = [
    PremiumPlan(
      id: 'monthly_plan',
      name: 'Monthly',
      price: '\$4.99',
      period: '/ month',
      priceValue: 4.99,
      features: [
        'Unlock all tree species',
        'Exclusive ambient sounds',
        'Advanced statistics',
        'Cloud sync across devices',
        'No advertisements',
      ],
    ),
    PremiumPlan(
      id: 'yearly_plan',
      name: 'Yearly',
      price: '\$39.99',
      period: '/ year',
      priceValue: 39.99,
      isBestValue: true,
      features: [
        'Everything in Monthly',
        'Plant a real tree every month',
        'Exclusive "Guardian" badge',
        'Priority support',
        'Save 33% compared to monthly',
      ],
    ),
  ];
}
