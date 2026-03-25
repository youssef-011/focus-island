import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';

class OtpService {
  Future<Map<String, dynamic>> sendOtp(String email) async {
    final url = ApiConfig.buildUri('/api/auth/send-otp');
    final payload = {'email': email.trim()};

    try {
      debugPrint('OTP send request URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('OTP send response (${response.statusCode}): ${response.body}');

      final responseData = _safeJsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true;

      if (isSuccess) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ??
            'Unable to send OTP. Please try again.',
      };
    } catch (error) {
      debugPrint('OTP send error: $error');
      return {
        'success': false,
        'message': 'Unable to connect to the server. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final url = ApiConfig.buildUri('/api/auth/verify-otp');
    final payload = {
      'email': email.trim(),
      'otp': code.trim(),
    };

    try {
      debugPrint('OTP verify request URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('OTP verify response (${response.statusCode}): ${response.body}');

      final responseData = _safeJsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true;

      if (isSuccess) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully',
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ??
            'The code is invalid or expired. Please try again.',
      };
    } catch (error) {
      debugPrint('OTP verify error: $error');
      return {
        'success': false,
        'message': 'Unable to connect to the server. Please try again.',
      };
    }
  }

  Map<String, dynamic> _safeJsonDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
