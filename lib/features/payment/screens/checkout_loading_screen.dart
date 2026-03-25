import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/payment_service.dart';
import 'payment_result_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _processCheckout();
  }

  Future<void> _processCheckout() async {
    try {
      // 1. Create payment session via service
      final checkoutUrl = await _paymentService.createPaymentSession(widget.planId);
      
      debugPrint('Redirecting to checkout URL: $checkoutUrl');

      // 2. Simulate user spending time on the payment page
      await Future.delayed(const Duration(seconds: 3));

      // 3. Verify payment result
      final isSuccess = await _paymentService.verifyPayment('mock_order_id');

      if (mounted) {
        // 4. Navigate to final result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentResultScreen(isSuccess: isSuccess),
          ),
        );
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentResultScreen(isSuccess: false),
          ),
        );
      }
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
