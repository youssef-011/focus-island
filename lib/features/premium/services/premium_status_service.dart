import 'package:shared_preferences/shared_preferences.dart';

class PremiumStatus {
  final bool isActive;
  final String? planId;
  final String? activatedAt;
  final String? orderId;
  final String? transactionId;

  const PremiumStatus({
    required this.isActive,
    this.planId,
    this.activatedAt,
    this.orderId,
    this.transactionId,
  });
}

class PremiumStatusService {
  static const String _keyIsPremiumActive = 'premium_active';
  static const String _keyPremiumPlanId = 'premium_plan_id';
  static const String _keyPremiumActivatedAt = 'premium_activated_at';
  static const String _keyPremiumOrderId = 'premium_order_id';
  static const String _keyPremiumTransactionId = 'premium_transaction_id';

  Future<void> saveVerifiedPremium({
    required String planId,
    String? orderId,
    String? transactionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremiumActive, true);
    await prefs.setString(_keyPremiumPlanId, planId);
    await prefs.setString(
      _keyPremiumActivatedAt,
      DateTime.now().toIso8601String(),
    );

    if (orderId != null && orderId.isNotEmpty) {
      await prefs.setString(_keyPremiumOrderId, orderId);
    }

    if (transactionId != null && transactionId.isNotEmpty) {
      await prefs.setString(_keyPremiumTransactionId, transactionId);
    }
  }

  Future<PremiumStatus> getPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return PremiumStatus(
      isActive: prefs.getBool(_keyIsPremiumActive) ?? false,
      planId: prefs.getString(_keyPremiumPlanId),
      activatedAt: prefs.getString(_keyPremiumActivatedAt),
      orderId: prefs.getString(_keyPremiumOrderId),
      transactionId: prefs.getString(_keyPremiumTransactionId),
    );
  }

  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPremiumActive);
    await prefs.remove(_keyPremiumPlanId);
    await prefs.remove(_keyPremiumActivatedAt);
    await prefs.remove(_keyPremiumOrderId);
    await prefs.remove(_keyPremiumTransactionId);
  }
}
