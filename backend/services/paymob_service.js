const axios = require('axios');

class PaymobService {
  constructor() {
    this.baseUrl = 'https://accept.paymob.com/api';
  }

  validateEnv() {
    if (!process.env.PAYMOB_API_KEY) {
      throw new Error('Missing PAYMOB_API_KEY');
    }
    if (!process.env.PAYMOB_INTEGRATION_ID) {
      throw new Error('Missing PAYMOB_INTEGRATION_ID');
    }
    if (!process.env.PAYMOB_IFRAME_ID) {
      throw new Error('Missing PAYMOB_IFRAME_ID');
    }
  }

  async authenticate() {
    this.validateEnv();

    try {
      const response = await axios.post(`${this.baseUrl}/auth/tokens`, {
        api_key: process.env.PAYMOB_API_KEY,
      });

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to authenticate with Paymob');
    }
  }

  async createOrder(authToken, amountCents) {
    try {
      const response = await axios.post(`${this.baseUrl}/ecommerce/orders`, {
        auth_token: authToken,
        delivery_needed: false,
        amount_cents: String(amountCents),
        currency: 'EGP',
        items: [],
      });

      return response.data.id;
    } catch (error) {
      throw new Error('Failed to create Paymob order');
    }
  }

  async createPaymentKey(authToken, orderId, amountCents) {
    try {
      const response = await axios.post(`${this.baseUrl}/acceptance/payment_keys`, {
        auth_token: authToken,
        amount_cents: String(amountCents),
        expiration: 3600,
        order_id: orderId,
        billing_data: {
          apartment: 'NA',
          email: 'user@example.com',
          floor: 'NA',
          first_name: 'Focus',
          street: 'NA',
          building: 'NA',
          phone_number: '+201234567890',
          shipping_method: 'NA',
          postal_code: 'NA',
          city: 'Cairo',
          country: 'EG',
          last_name: 'Island',
          state: 'Cairo',
        },
        currency: 'EGP',
        integration_id: Number(process.env.PAYMOB_INTEGRATION_ID),
      });

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to generate Paymob payment key');
    }
  }

  getCheckoutUrl(paymentKey) {
    const iframeId = process.env.PAYMOB_IFRAME_ID;
    return `https://accept.paymob.com/api/acceptance/iframes/${iframeId}?payment_token=${paymentKey}`;
  }
}

module.exports = new PaymobService();