const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment_controller');

// Create payment session
router.post('/create-session', paymentController.createPaymentSession);

// Paymob webhook (for future verification)
router.post('/webhook', paymentController.handlePaymentWebhook);

// Optional: simple route to test payments route
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Payment routes working',
  });
});

module.exports = router;