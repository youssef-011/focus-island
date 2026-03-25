const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment_controller');

// Create payment session
router.post('/create-session', paymentController.createPaymentSession);

// Paymob browser callback
router.get('/callback', paymentController.handlePaymentCallback);

// Paymob processed callback / webhook
router.post('/webhook', paymentController.handlePaymentWebhook);

// Check the verified payment status from Flutter
router.get('/status/:paymentSessionId', paymentController.getPaymentStatus);

// Optional: simple route to test payments route
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Payment routes working',
  });
});

module.exports = router;
