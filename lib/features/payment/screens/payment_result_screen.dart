import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSubtitle(),
              const Spacer(),
              _buildActionButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isSuccess ? AppColors.lightGreen : AppColors.warning)
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        color: isSuccess ? AppColors.lightGreen : AppColors.warning,
        size: 100,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isSuccess ? 'Payment Successful' : 'Payment Failed',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      isSuccess
          ? 'Congratulations! Your Premium subscription has been activated. Enjoy all exclusive features of Focus Island.'
          : 'We couldn\'t process your payment. Please check your payment method and try again.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (isSuccess) {
            // Navigate back to the main screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            // Go back to the premium screen to try again
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSuccess ? AppColors.primaryGreen : AppColors.warning,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isSuccess ? 'Back to Island' : 'Try Again',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
