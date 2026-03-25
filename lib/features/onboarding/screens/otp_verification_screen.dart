import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'welcome_user_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String name;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.verifyOtp(widget.email, _otpController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeUserScreen(
            name: widget.name,
            email: widget.email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Invalid code'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.sendOtp(widget.email);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code resent successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to resend code'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.lock_outline,
                color: AppColors.lightGreen,
                size: 60,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enabled: !provider.isVerifyingOtp,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  if (value.length == 6) _verifyOtp();
                },
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: const TextStyle(color: Colors.white12),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _canResend && !provider.isSendingOtp ? _resendCode : null,
                child: provider.isSendingOtp
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lightGreen),
                      )
                    : Text(
                        _canResend ? 'Resend Code' : 'Resend code in ${_resendSeconds}s',
                        style: TextStyle(
                          color: _canResend ? AppColors.lightGreen : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: provider.isVerifyingOtp ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.lightGreen.withOpacity(0.5),
                  ),
                  child: provider.isVerifyingOtp
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.background,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
