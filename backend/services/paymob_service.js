const axios = require('axios');
const crypto = require('crypto');

class PaymobService {
  constructor() {
    this.baseUrl = 'https://accept.paymob.com/api';
  }

  validateEnv() {
    return Boolean(
      process.env.PAYMOB_API_KEY &&
        process.env.PAYMOB_INTEGRATION_ID &&
        process.env.PAYMOB_IFRAME_ID
    );
  }

  isMockMode() {
    return !this.validateEnv();
  }

  getPublicBaseUrl() {
    const rawBaseUrl =
      process.env.PUBLIC_BASE_URL ||
      `http://localhost:${process.env.PORT || 3000}`;

    return rawBaseUrl.replace(/\/+$/, '');
  }

  getCallbackUrlPrefix() {
    return `${this.getPublicBaseUrl()}/payments/callback`;
  }

  buildBillingData(customer = {}) {
    const fullName = String(customer.fullName || '').trim();
    const nameParts = fullName.split(/\s+/).filter(Boolean);
    const firstName = nameParts.shift() || 'Focus';
    const lastName = nameParts.join(' ') || 'Island';
    const country = String(customer.country || 'EG').trim().toUpperCase();

    return {
      apartment: 'NA',
      email: customer.email || 'user@example.com',
      floor: 'NA',
      first_name: firstName,
      street: 'NA',
      building: 'NA',
      phone_number: customer.phone || '+201234567890',
      shipping_method: 'NA',
      postal_code: '00000',
      city: 'NA',
      country,
      last_name: lastName,
      state: 'NA',
    };
  }

  async authenticate() {
    if (this.isMockMode()) {
      return 'mock_auth_token';
    }

    try {
      const response = await axios.post(`${this.baseUrl}/auth/tokens`, {
        api_key: process.env.PAYMOB_API_KEY,
      });

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to authenticate with Paymob');
    }
  }

  async createOrder(authToken, amountCents, merchantOrderId) {
    if (this.isMockMode()) {
      return `mock_order_${amountCents}_${Date.now()}`;
    }

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
    if (this.isMockMode()) {
      return `mock_payment_key_${orderId}_${amountCents}`;
    }

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
          integration_id: Number(process.env.PAYMOB_INTEGRATION_ID),
          lock_order_when_paid: true,
        }
      );

      return response.data.token;
    } catch (error) {
      throw new Error('Failed to generate Paymob payment key');
    }
  }

  getCheckoutUrl(paymentKey, metadata = {}) {
    if (this.isMockMode()) {
      const callbackUrl = new URL(this.getCallbackUrlPrefix());
      callbackUrl.searchParams.set(
        'payment_session_id',
        metadata.paymentSessionId || ''
      );
      callbackUrl.searchParams.set(
        'merchant_order_id',
        metadata.paymentSessionId || ''
      );
      callbackUrl.searchParams.set('order', String(metadata.orderId || ''));
      callbackUrl.searchParams.set(
        'id',
        `mock_transaction_${metadata.paymentSessionId || Date.now()}`
      );
      callbackUrl.searchParams.set('success', 'true');
      callbackUrl.searchParams.set('pending', 'false');
      callbackUrl.searchParams.set('is_voided', 'false');
      callbackUrl.searchParams.set('is_refunded', 'false');
      callbackUrl.searchParams.set('error_occured', 'false');
      callbackUrl.searchParams.set('txn_response_code', 'APPROVED');
      callbackUrl.searchParams.set('source', 'mock');
      return callbackUrl.toString();
    }

    const iframeId = process.env.PAYMOB_IFRAME_ID;
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
    if (this.isMockMode()) {
      return true;
    }

    const hmacSecret = process.env.PAYMOB_HMAC_SECRET;

    if (!hmacSecret || !providedHmac) {
      return false;
    }

    const hmacSource = this.buildCallbackHmacSource(payload);
    const computedHmac = crypto
      .createHmac('sha512', hmacSecret)
      .update(hmacSource)
      .digest('hex');

    const providedBuffer = Buffer.from(String(providedHmac).toLowerCase(), 'utf8');
    const computedBuffer = Buffer.from(computedHmac.toLowerCase(), 'utf8');

    if (providedBuffer.length !== computedBuffer.length) {
      return false;
    }

    return crypto.timingSafeEqual(providedBuffer, computedBuffer);
  }
}

module.exports = new PaymobService();
