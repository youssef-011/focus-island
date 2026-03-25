const axios = require('axios');
const crypto = require('crypto');

class PaymobService {
  constructor() {
    this.baseUrl = 'https://accept.paymob.com/api';
  }

  assertConfigured() {
    const requiredEnvKeys = [
      'PUBLIC_BASE_URL',
      'PAYMOB_API_KEY',
      'PAYMOB_IFRAME_ID',
      'PAYMOB_INTEGRATION_ID',
      'PAYMOB_HMAC_SECRET',
    ];

    const missingEnvKeys = requiredEnvKeys.filter(
      (envKey) => !String(process.env[envKey] || '').trim()
    );

    if (missingEnvKeys.length > 0) {
      throw new Error(
        `Missing required Paymob environment values: ${missingEnvKeys.join(', ')}`
      );
    }
  }

  getPublicBaseUrl() {
    this.assertConfigured();
    return String(process.env.PUBLIC_BASE_URL).trim().replace(/\/+$/, '');
  }

  getCallbackUrlPrefix() {
    return `${this.getPublicBaseUrl()}/payments/callback`;
  }

  buildBillingData(customer = {}) {
    const fullName = String(customer.fullName || '').trim();
    const nameParts = fullName.split(/\s+/).filter(Boolean);
    const firstName = nameParts.shift() || fullName;
    const lastName = nameParts.join(' ') || fullName;
    const country = String(customer.country || '').trim().toUpperCase();

    return {
      apartment: 'NA',
      email: String(customer.email || '').trim(),
      floor: 'NA',
      first_name: firstName,
      street: 'NA',
      building: 'NA',
      phone_number: String(customer.phone || '').trim(),
      shipping_method: 'NA',
      postal_code: '00000',
      city: 'NA',
      country,
      last_name: lastName,
      state: 'NA',
    };
  }

  async authenticate() {
    this.assertConfigured();

    try {
      const response = await axios.post(`${this.baseUrl}/auth/tokens`, {
        api_key: String(process.env.PAYMOB_API_KEY).trim(),
      });

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to authenticate with Paymob');
    }
  }

  async createOrder(authToken, amountCents, merchantOrderId) {
    this.assertConfigured();

    try {
      const response = await axios.post(`${this.baseUrl}/ecommerce/orders`, {
        auth_token: authToken,
        delivery_needed: false,
        amount_cents: String(amountCents),
        currency: 'EGP',
        merchant_order_id: merchantOrderId,
        items: [],
      });

      return response.data.id;
    } catch (error) {
      throw new Error('Failed to create Paymob order');
    }
  }

  async createPaymentKey(authToken, orderId, amountCents, customer) {
    this.assertConfigured();

    try {
      const response = await axios.post(
        `${this.baseUrl}/acceptance/payment_keys`,
        {
          auth_token: authToken,
          amount_cents: String(amountCents),
          expiration: 3600,
          order_id: orderId,
          billing_data: this.buildBillingData(customer),
          currency: 'EGP',
          integration_id: Number(String(process.env.PAYMOB_INTEGRATION_ID).trim()),
          lock_order_when_paid: true,
        }
      );

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to generate Paymob payment key');
    }
  }

  getCheckoutUrl(paymentKey) {
    this.assertConfigured();

    const iframeId = String(process.env.PAYMOB_IFRAME_ID).trim();
    return `https://accept.paymob.com/api/acceptance/iframes/${iframeId}?payment_token=${paymentKey}`;
  }

  normalizeValue(value) {
    if (value === null || value === undefined) {
      return '';
    }

    if (typeof value === 'boolean') {
      return value ? 'true' : 'false';
    }

    return String(value);
  }

  getPayloadObject(payload) {
    if (payload && typeof payload.obj === 'object' && payload.obj !== null) {
      return payload.obj;
    }

    return payload || {};
  }

  buildCallbackHmacSource(payload) {
    const obj = this.getPayloadObject(payload);
    const order = obj.order || {};
    const sourceData = obj.source_data || {};

    const orderedValues = [
      obj.amount_cents,
      obj.created_at,
      obj.currency,
      obj.error_occured,
      obj.has_parent_transaction,
      obj.id,
      obj.integration_id,
      obj.is_3d_secure,
      obj.is_auth,
      obj.is_capture,
      obj.is_refunded,
      obj.is_standalone_payment,
      obj.is_voided,
      order.id ?? obj.order ?? payload.order,
      obj.owner,
      obj.pending,
      sourceData.pan,
      sourceData.sub_type,
      sourceData.type,
      obj.success,
    ];

    return orderedValues.map((value) => this.normalizeValue(value)).join('');
  }

  verifyCallbackHmac(payload, providedHmac) {
    this.assertConfigured();

    const hmacSecret = String(process.env.PAYMOB_HMAC_SECRET).trim();
    const normalizedProvidedHmac = String(providedHmac || '').trim();

    if (!normalizedProvidedHmac) {
      return false;
    }

    const hmacSource = this.buildCallbackHmacSource(payload);
    const computedHmac = crypto
      .createHmac('sha512', hmacSecret)
      .update(hmacSource)
      .digest('hex');

    const providedBuffer = Buffer.from(normalizedProvidedHmac.toLowerCase(), 'utf8');
    const computedBuffer = Buffer.from(computedHmac.toLowerCase(), 'utf8');

    if (providedBuffer.length !== computedBuffer.length) {
      return false;
    }

    return crypto.timingSafeEqual(providedBuffer, computedBuffer);
  }
}

module.exports = new PaymobService();
