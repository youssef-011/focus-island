import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../onboarding/services/onboarding_storage_service.dart';
import '../../premium/services/premium_status_service.dart';
import '../services/payment_api_service.dart';
import '../services/payment_service.dart';
import 'payment_result_screen.dart';
import 'payment_webview_screen.dart';

class CheckoutLoadingScreen extends StatefulWidget {
  final String planId;

  const CheckoutLoadingScreen({
    super.key,
    required this.planId,
  });

  @override
  State<CheckoutLoadingScreen> createState() => _CheckoutLoadingScreenState();
}

class _CheckoutLoadingScreenState extends State<CheckoutLoadingScreen> {
  final PaymentService _paymentService = PaymentService();
  final OnboardingStorageService _onboardingStorageService =
      OnboardingStorageService();
  final PremiumStatusService _premiumStatusService = PremiumStatusService();

  @override
  void initState() {
    super.initState();
    _processCheckout();
  }

  Future<void> _processCheckout() async {
    try {
      final profile = await _onboardingStorageService.getUserProfile();

      if (!profile.hasPaymentDetails) {
        throw Exception(
          'Please complete your profile details before starting payment.',
        );
      }

      final paymentSession = await _paymentService.createPaymentSession(
        widget.planId,
        PaymentCustomerDetails(
          fullName: profile.name,
          email: profile.email,
          phone: profile.phone,
          country: profile.country,
        ),
      );

      debugPrint(
        'Redirecting to checkout URL: ${paymentSession.checkoutUrl}',
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
          planId: widget.planId,
          orderId: verificationResult?.orderId,
          transactionId: verificationResult?.transactionId,
        );

        if (!mounted) {
          return;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            isSuccess: verificationResult?.isSuccess == true,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Checkout error: $error');

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PaymentResultScreen(isSuccess: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.lightGreen,
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            const Text(
              'Securely opening checkout...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting to secure gateway',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
