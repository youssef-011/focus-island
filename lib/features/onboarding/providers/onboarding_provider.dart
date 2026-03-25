import 'package:flutter/material.dart';
import '../services/otp_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final OtpService _otpService = OtpService();

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Sends the OTP to the provided [email].
  Future<bool> sendOtp(String email) async {
    _isSendingOtp = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _otpService.sendOtp(email);

    _isSendingOtp = false;
    if (result['success']) {
      _successMessage = result['message'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Verifies the provided [code] for the given [email].
  Future<bool> verifyOtp(String email, String code) async {
    _isVerifyingOtp = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _otpService.verifyOtp(email, code);

    _isVerifyingOtp = false;
    if (result['success']) {
      _successMessage = result['message'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
