import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../onboarding/models/user_profile.dart';
import '../../onboarding/services/onboarding_storage_service.dart';
import '../../payment/screens/payment_webview_screen.dart';
import '../../payment/services/payment_api_service.dart';
import '../models/premium_plan.dart';
import '../services/premium_status_service.dart';
import '../widgets/plan_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();
  final PremiumStatusService _premiumStatusService = PremiumStatusService();
  final PaymentApiService _apiService = PaymentApiService();

  String _selectedPlanId = 'yearly_plan';
  bool _isProcessing = false;
  bool _isLoadingProfile = true;
  bool _isPremiumActive = false;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadPaymentContext();
  }

  Future<void> _loadPaymentContext() async {
    final profile = await _onboardingStorageService.getUserProfile();
    final premiumStatus = await _premiumStatusService.getPremiumStatus();

    if (!mounted) {
      return;
    }

    setState(() {
      _userProfile = profile;
      _isPremiumActive = premiumStatus.isActive;
      _isLoadingProfile = false;
      if (premiumStatus.planId != null && premiumStatus.planId!.isNotEmpty) {
        _selectedPlanId = premiumStatus.planId!;
      }
    });
  }

  String? _validateProfileForPayment() {
    final profile = _userProfile;

    if (profile == null || !profile.hasPaymentDetails) {
      return 'Please complete your name, email, phone, and country before subscribing.';
    }

    return null;
  }

  Future<void> _handleSubscription() async {
    if (_isProcessing || _isLoadingProfile) {
      return;
    }

    if (_isPremiumActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium is already active on this device.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      return;
    }

    final profileValidationError = _validateProfileForPayment();
    if (profileValidationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileValidationError),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final profile = _userProfile!;

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentSession = await _apiService.createPaymentSession(
        _selectedPlanId,
        PaymentCustomerDetails(
          fullName: profile.name,
          email: profile.email,
          phone: profile.phone,
          country: profile.country,
        ),
      );

      if (!mounted) {
        return;
      }

      final verificationResult =
          await Navigator.push<PaymentVerificationResult>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            checkoutUrl: paymentSession.checkoutUrl,
            paymentSessionId: paymentSession.paymentSessionId,
            callbackUrlPrefix: paymentSession.callbackUrlPrefix,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (verificationResult?.isSuccess == true) {
        await _premiumStatusService.saveVerifiedPremium(
          planId: _selectedPlanId,
          orderId: verificationResult?.orderId,
          transactionId: verificationResult?.transactionId,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isPremiumActive = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Subscription successful! Welcome to Focus Island Plus.',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else if (verificationResult?.isFailure == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verificationResult?.failureReason ??
                  verificationResult?.message ??
                  'Payment failed. Please try again.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled. You can retry any time.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildStatusBanner() {
    if (_isLoadingProfile) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: LinearProgressIndicator(
          color: AppColors.lightGreen,
          backgroundColor: Colors.white12,
        ),
      );
    }

    if (_isPremiumActive) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.35)),
        ),
        child: const Text(
          'Premium is active on this device. Your verified subscription details are saved locally.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final profileError = _validateProfileForPayment();
    if (profileError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Text(
        profileError,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled =
        _isProcessing || _isLoadingProfile || _isPremiumActive;

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
                      const SizedBox(height: 24),
                      _buildStatusBanner(),
                      ...PremiumData.plans.map(
                        (plan) => PlanCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          onTap: isButtonDisabled
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
                        onPressed: isButtonDisabled ? null : _handleSubscription,
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
                            : Text(
                                _isPremiumActive ? 'Premium Active' : 'Continue',
                                style: const TextStyle(
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
