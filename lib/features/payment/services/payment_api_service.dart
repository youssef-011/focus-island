import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';

class PaymentCustomerDetails {
  final String fullName;
  final String email;
  final String phone;
  final String country;

  const PaymentCustomerDetails({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'country': country.trim().toUpperCase(),
    };
  }
}

class PaymentSessionResponse {
  final String checkoutUrl;
  final String paymentSessionId;
  final String callbackUrlPrefix;

  const PaymentSessionResponse({
    required this.checkoutUrl,
    required this.paymentSessionId,
    required this.callbackUrlPrefix,
  });
}

class PaymentVerificationResult {
  final String paymentStatus;
  final bool isFinal;
  final bool isVerified;
  final String? failureReason;
  final String? orderId;
  final String? transactionId;
  final String message;

  const PaymentVerificationResult({
    required this.paymentStatus,
    required this.isFinal,
    required this.isVerified,
    required this.failureReason,
    required this.orderId,
    required this.transactionId,
    required this.message,
  });

  bool get isSuccess => paymentStatus == 'success';
  bool get isFailure => paymentStatus == 'failed';
}

class PaymentApiService {
  Future<PaymentSessionResponse> createPaymentSession(
    String planId,
    PaymentCustomerDetails customer,
  ) async {
    final url = ApiConfig.buildUri('/payments/create-session');
    final payload = {
      'planId': planId,
      'customer': customer.toJson(),
    };

    try {
      debugPrint('Payment request URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('Payment response (${response.statusCode}): ${response.body}');

      final data = _safeJsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true;

      if (!isSuccess) {
        throw Exception(
          data['error'] ??
              data['message'] ??
              'Unable to start payment. Please try again.',
        );
      }

      final checkoutUrl = data['checkout_url'] as String?;
      final paymentSessionId = data['payment_session_id'] as String?;
      final callbackUrlPrefix = data['callback_url_prefix'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw const FormatException('Missing checkout_url in payment response');
      }

      if (paymentSessionId == null || paymentSessionId.isEmpty) {
        throw const FormatException(
          'Missing payment_session_id in payment response',
        );
      }

      if (callbackUrlPrefix == null || callbackUrlPrefix.isEmpty) {
        throw const FormatException(
          'Missing callback_url_prefix in payment response',
        );
      }

      return PaymentSessionResponse(
        checkoutUrl: checkoutUrl,
        paymentSessionId: paymentSessionId,
        callbackUrlPrefix: callbackUrlPrefix,
      );
    } catch (error) {
      debugPrint('Payment request error: $error');

      if (error is FormatException) {
        throw Exception('Invalid payment response from server.');
      }

      if (error is Exception) {
        rethrow;
      }

      throw Exception('Unable to connect to the payment server.');
    }
  }

  Future<PaymentVerificationResult> fetchPaymentStatus(
    String paymentSessionId,
  ) async {
    final url = ApiConfig.buildUri('/payments/status/$paymentSessionId');

    try {
      debugPrint('Payment verify request URL: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
        'Payment verify response (${response.statusCode}): ${response.body}',
      );

      final data = _safeJsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true;

      if (!isSuccess) {
        throw Exception(
          data['error'] ??
              data['message'] ??
              'Unable to verify payment. Please try again.',
        );
      }

      return PaymentVerificationResult(
        paymentStatus: (data['payment_status'] as String?) ?? 'pending',
        isFinal: data['is_final'] == true,
        isVerified: data['is_verified'] == true,
        failureReason: data['failure_reason'] as String?,
        orderId: data['order_id'] as String?,
        transactionId: data['transaction_id'] as String?,
        message:
            (data['message'] as String?) ?? 'Payment status fetched successfully.',
      );
    } catch (error) {
      debugPrint('Payment verify error: $error');

      if (error is Exception) {
        rethrow;
      }

      throw Exception('Unable to verify payment right now.');
    }
  }

  Future<PaymentVerificationResult> waitForVerifiedPayment(
    String paymentSessionId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 20,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await fetchPaymentStatus(paymentSessionId);

      if (result.isFinal) {
        return result;
      }

      if (attempt < maxAttempts - 1) {
        await Future.delayed(interval);
      }
    }

    throw Exception(
      'Payment confirmation is taking longer than expected. Please wait a moment and try again.',
    );
  }

  Map<String, dynamic> _safeJsonDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
