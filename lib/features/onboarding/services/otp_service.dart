import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  // Base URL for the backend API (for Android emulator)
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth';

  /// Sends a request to the backend to generate and send an OTP to the given [email].
  Future<Map<String, dynamic>> sendOtp(String email) async {
    final url = Uri.parse('$_baseUrl/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'OTP sent successfully'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check if backend is running.'
      };
    }
  }

  /// Sends the [code] and [email] to the backend for verification.
  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final url = Uri.parse('$_baseUrl/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': code}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Verification successful'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid or expired code'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }
}
