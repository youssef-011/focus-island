import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<String> createPaymentSession(String planId) async {
    final url = Uri.parse('$_baseUrl/payments/create-session');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'planId': planId}),
      );

      final Map<String, dynamic> data = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true && data['checkout_url'] != null) {
          return data['checkout_url'];
        } else {
          throw Exception(data['error'] ?? 'Invalid response from server');
        }
      } else {
        throw Exception(data['error'] ?? 'Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Payment request failed');
    }
  }

  Map<String, dynamic> _safeJsonDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}