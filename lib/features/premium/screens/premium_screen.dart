import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../payment/screens/payment_webview_screen.dart';
import '../../payment/services/payment_api_service.dart';
import '../models/premium_plan.dart';
import '../widgets/plan_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlanId = 'yearly_plan';
  bool _isProcessing = false;
  final PaymentApiService _apiService = PaymentApiService();

  Future<void> _handleSubscription() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final checkoutUrl =
      await _apiService.createPaymentSession(_selectedPlanId);

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentWebViewScreen(checkoutUrl: checkoutUrl),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Subscription successful! Welcome to Focus Island Plus.',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else if (result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen.withOpacity(0.4),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.gold,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upgrade to Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unlock exclusive features and plant real trees while you focus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...PremiumData.plans.map(
                            (plan) => PlanCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          onTap: _isProcessing
                              ? () {}
                              : () => setState(() {
                            _selectedPlanId = plan.id;
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handleSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          foregroundColor: AppColors.background,
                          elevation: 0,
                          disabledBackgroundColor:
                          AppColors.lightGreen.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.background,
                          ),
                        )
                            : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cancel anytime. Terms & Conditions apply.',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}