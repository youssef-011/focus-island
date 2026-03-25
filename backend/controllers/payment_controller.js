const paymobService = require('../services/paymob_service');

const PLAN_AMOUNTS = {
  monthly_plan: 499,
  yearly_plan: 3999,
};

exports.createPaymentSession = async (req, res) => {
  try {
    const { planId } = req.body;

    if (!planId) {
      return res.status(400).json({
        success: false,
        error: 'planId is required',
      });
    }

    const amountCents = PLAN_AMOUNTS[planId];

    if (!amountCents) {
      return res.status(400).json({
        success: false,
        error: 'Invalid planId',
      });
    }

    const authToken = await paymobService.authenticate();
    const orderId = await paymobService.createOrder(authToken, amountCents);
    const paymentKey = await paymobService.createPaymentKey(
      authToken,
      orderId,
      amountCents
    );

    const checkoutUrl = paymobService.getCheckoutUrl(paymentKey);

    return res.status(200).json({
      success: true,
      checkout_url: checkoutUrl,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: 'Failed to create payment session',
    });
  }
};

exports.handlePaymentWebhook = async (req, res) => {
  try {
    const transactionData = req.body;

    if (!transactionData) {
      return res.status(400).json({
        success: false,
        error: 'Missing webhook payload',
      });
    }

    // TODO:
    // 1. Verify HMAC using PAYMOB_HMAC_SECRET
    // 2. Check payment status
    // 3. Update user subscription / order in database

    return res.status(200).json({
      success: true,
      message: 'Webhook received',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: 'Failed to process webhook',
    });
  }
};