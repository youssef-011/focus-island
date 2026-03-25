import 'payment_api_service.dart';

class PaymentService {
  final PaymentApiService _apiService;

  PaymentService({PaymentApiService? apiService})
      : _apiService = apiService ?? PaymentApiService();

  Future<PaymentSessionResponse> createPaymentSession(
    String planId,
    PaymentCustomerDetails customer,
  ) {
    return _apiService.createPaymentSession(planId, customer);
  }

  Future<PaymentVerificationResult> waitForVerifiedPayment(
    String paymentSessionId,
  ) {
    return _apiService.waitForVerifiedPayment(paymentSessionId);
  }
}
