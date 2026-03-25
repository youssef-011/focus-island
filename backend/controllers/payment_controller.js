const crypto = require('crypto');

const paymobService = require('../services/paymob_service');

const PLAN_AMOUNTS = {
  monthly_plan: 499,
  yearly_plan: 3999,
};

const paymentSessions = new Map();

function nowIsoString() {
  return new Date().toISOString();
}

function createPaymentSessionId() {
  return crypto.randomUUID();
}

function buildInitialSession({
  paymentSessionId,
  planId,
  amountCents,
  orderId,
  customer,
  callbackUrlPrefix,
}) {
  return {
    paymentSessionId,
    merchantOrderId: paymentSessionId,
    planId,
    amountCents,
    orderId: String(orderId),
    customer,
    transactionId: null,
    paymentStatus: 'pending',
    isFinal: false,
    isVerified: false,
    verificationSource: 'unverified',
    failureReason: null,
    callbackUrlPrefix,
    createdAt: nowIsoString(),
    updatedAt: nowIsoString(),
    callbackPayload: null,
    webhookPayload: null,
  };
}

function updateSession(paymentSessionId, updates) {
  const current = paymentSessions.get(paymentSessionId);

  if (!current) {
    return null;
  }

  const next = {
    ...current,
    ...updates,
    updatedAt: nowIsoString(),
  };

  paymentSessions.set(paymentSessionId, next);
  return next;
}

function normalizeBoolean(value) {
  if (typeof value === 'boolean') {
    return value;
  }

  const normalizedValue = String(value ?? '')
    .trim()
    .toLowerCase();

  if (['true', '1', 'yes'].includes(normalizedValue)) {
    return true;
  }

  if (['false', '0', 'no'].includes(normalizedValue)) {
    return false;
  }

  return false;
}

function normalizeCustomer(customer = {}) {
  return {
    fullName: String(customer.fullName || '').trim(),
    email: String(customer.email || '').trim().toLowerCase(),
    phone: String(customer.phone || '').trim(),
    country: String(customer.country || '').trim().toUpperCase(),
  };
}

function validateCustomer(customer) {
  if (!customer.fullName) {
    return 'Customer full name is required';
  }

  if (!customer.email || !customer.email.includes('@')) {
    return 'A valid customer email is required';
  }

  if (!customer.phone || customer.phone.length < 8) {
    return 'A valid customer phone number is required';
  }

  if (!customer.country || customer.country.length !== 2) {
    return 'A valid 2-letter customer country code is required';
  }

  return null;
}

function getPayloadObject(payload) {
  if (payload && typeof payload.obj === 'object' && payload.obj !== null) {
    return payload.obj;
  }

  return payload || {};
}

function normalizeVerificationPayload(payload) {
  const obj = getPayloadObject(payload);
  const order = obj.order || {};
  const sourceData = obj.source_data || {};

  return {
    transactionId: String(
      obj.id ?? obj.transaction_id ?? payload.transaction_id ?? ''
    ),
    orderId: String(
      order.id ?? obj.order_id ?? obj.order ?? payload.order_id ?? payload.order ?? ''
    ),
    merchantOrderId: String(
      order.merchant_order_id ??
        obj.merchant_order_id ??
        payload.merchant_order_id ??
        ''
    ),
    success: normalizeBoolean(obj.success ?? payload.success),
    pending: normalizeBoolean(obj.pending ?? payload.pending),
    isVoided: normalizeBoolean(obj.is_voided ?? payload.is_voided),
    isRefunded: normalizeBoolean(obj.is_refunded ?? payload.is_refunded),
    errorOccurred: normalizeBoolean(
      obj.error_occured ?? payload.error_occured ?? obj.error_occurred ?? payload.error_occurred
    ),
    responseCode: String(
      obj.txn_response_code ?? payload.txn_response_code ?? ''
    ),
    sourceType: String(sourceData.type ?? payload.source_type ?? ''),
    rawPayload: payload,
  };
}

function resolveSession(normalizedPayload) {
  if (normalizedPayload.merchantOrderId) {
    const session = paymentSessions.get(normalizedPayload.merchantOrderId);
    if (session) {
      return session;
    }
  }

  for (const session of paymentSessions.values()) {
    if (
      (normalizedPayload.orderId && session.orderId === normalizedPayload.orderId) ||
      (normalizedPayload.transactionId &&
        session.transactionId === normalizedPayload.transactionId)
    ) {
      return session;
    }
  }

  return null;
}

function finalizeSession(session, normalizedPayload, verificationSource) {
  const isSuccessfulPayment =
    normalizedPayload.success &&
    !normalizedPayload.pending &&
    !normalizedPayload.isVoided &&
    !normalizedPayload.isRefunded &&
    !normalizedPayload.errorOccurred;

  const paymentStatus = isSuccessfulPayment ? 'success' : 'failed';
  const failureReason = isSuccessfulPayment
    ? null
    : normalizedPayload.responseCode || 'Payment was not completed successfully.';

  return updateSession(session.paymentSessionId, {
    transactionId: normalizedPayload.transactionId || session.transactionId,
    paymentStatus,
    isFinal: true,
    isVerified: true,
    verificationSource,
    failureReason,
  });
}

function markSessionPending(session, source, payloadField, payload) {
  return updateSession(session.paymentSessionId, {
    [payloadField]: payload,
    verificationSource: source,
  });
}

function handleVerifiedPayload({
  session,
  normalizedPayload,
  verificationSource,
  payloadField,
  payload,
}) {
  const stagedSession = updateSession(session.paymentSessionId, {
    [payloadField]: payload,
    transactionId: normalizedPayload.transactionId || session.transactionId,
  });

  if (
    normalizedPayload.pending &&
    !normalizedPayload.success &&
    !normalizedPayload.isVoided &&
    !normalizedPayload.isRefunded &&
    !normalizedPayload.errorOccurred
  ) {
    return markSessionPending(stagedSession, verificationSource, payloadField, payload);
  }

  return finalizeSession(stagedSession, normalizedPayload, verificationSource);
}

function buildCallbackHtml(session) {
  const statusLabel =
    session.paymentStatus === 'success'
      ? 'Payment verified successfully.'
      : session.paymentStatus === 'failed'
        ? 'Payment verification failed.'
        : 'Payment is being verified.';

  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Focus Island Payment</title>
    <style>
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background: #081c15;
        color: #ffffff;
        font-family: Arial, sans-serif;
      }
      .card {
        max-width: 420px;
        padding: 32px;
        border-radius: 20px;
        background: rgba(255, 255, 255, 0.08);
        text-align: center;
      }
      h1 {
        margin: 0 0 12px;
        font-size: 24px;
      }
      p {
        margin: 0;
        line-height: 1.5;
        color: rgba(255, 255, 255, 0.8);
      }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Focus Island</h1>
      <p>${statusLabel}</p>
    </div>
  </body>
</html>`;
}

function buildStatusResponse(session) {
  let message = 'Payment is awaiting confirmation.';

  if (session.paymentStatus === 'success') {
    message = 'Payment verified successfully.';
  } else if (session.paymentStatus === 'failed') {
    message = session.failureReason || 'Payment verification failed.';
  }

  return {
    success: true,
    payment_session_id: session.paymentSessionId,
    order_id: session.orderId,
    transaction_id: session.transactionId,
    payment_status: session.paymentStatus,
    is_final: session.isFinal,
    is_verified: session.isVerified,
    verification_source: session.verificationSource,
    failure_reason: session.failureReason,
    message,
  };
}

exports.createPaymentSession = async (req, res) => {
  try {
    const { planId } = req.body;
    const customer = normalizeCustomer(req.body?.customer);

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

    const customerValidationError = validateCustomer(customer);
    if (customerValidationError) {
      return res.status(400).json({
        success: false,
        error: customerValidationError,
      });
    }

    const paymentSessionId = createPaymentSessionId();

    console.log(
      `Creating payment session for planId=${planId}, paymentSessionId=${paymentSessionId}`
    );

    const authToken = await paymobService.authenticate();
    const orderId = await paymobService.createOrder(
      authToken,
      amountCents,
      paymentSessionId
    );
    const paymentKey = await paymobService.createPaymentKey(
      authToken,
      orderId,
      amountCents,
      customer
    );
    const callbackUrlPrefix = paymobService.getCallbackUrlPrefix();
    const checkoutUrl = paymobService.getCheckoutUrl(paymentKey, {
      paymentSessionId,
      orderId,
    });

    const session = buildInitialSession({
      paymentSessionId,
      planId,
      amountCents,
      orderId,
      customer,
      callbackUrlPrefix,
    });

    paymentSessions.set(paymentSessionId, session);

    return res.status(200).json({
      success: true,
      checkout_url: checkoutUrl,
      order_id: String(orderId),
      payment_session_id: paymentSessionId,
      callback_url_prefix: callbackUrlPrefix,
    });
  } catch (error) {
    console.error('Failed to create payment session:', error.message);

    return res.status(500).json({
      success: false,
      error: 'Failed to create payment session',
    });
  }
};

exports.handlePaymentCallback = async (req, res) => {
  try {
    const normalizedPayload = normalizeVerificationPayload(req.query);
    const session = resolveSession(normalizedPayload);

    if (!session) {
      return res.status(404).send(buildCallbackHtml({
        paymentStatus: 'failed',
      }));
    }

    if (paymobService.isMockMode()) {
      const updatedSession = handleVerifiedPayload({
        session,
        normalizedPayload,
        verificationSource: 'mock_callback',
        payloadField: 'callbackPayload',
        payload: req.query,
      });

      return res.status(200).send(buildCallbackHtml(updatedSession));
    }

    const providedHmac =
      String(req.query.hmac || req.headers['x-paymob-signature'] || '').trim();
    const isHmacValid = paymobService.verifyCallbackHmac(
      req.query,
      providedHmac
    );

    const updatedSession = isHmacValid
      ? handleVerifiedPayload({
          session,
          normalizedPayload,
          verificationSource: 'callback_hmac',
          payloadField: 'callbackPayload',
          payload: req.query,
        })
      : markSessionPending(
          session,
          'callback_unverified',
          'callbackPayload',
          req.query
        );

    return res.status(200).send(buildCallbackHtml(updatedSession));
  } catch (error) {
    console.error('Failed to process callback:', error.message);

    return res.status(500).send(buildCallbackHtml({
      paymentStatus: 'failed',
    }));
  }
};

exports.handlePaymentWebhook = async (req, res) => {
  try {
    const normalizedPayload = normalizeVerificationPayload(req.body);
    const session = resolveSession(normalizedPayload);

    if (!session) {
      return res.status(404).json({
        success: false,
        error: 'Payment session not found',
      });
    }

    if (paymobService.isMockMode()) {
      const updatedSession = handleVerifiedPayload({
        session,
        normalizedPayload,
        verificationSource: 'mock_webhook',
        payloadField: 'webhookPayload',
        payload: req.body,
      });

      return res.status(200).json(buildStatusResponse(updatedSession));
    }

    const providedHmac = String(
      req.body?.hmac ||
        req.query?.hmac ||
        req.headers['x-paymob-signature'] ||
        ''
    ).trim();
    const isHmacValid = paymobService.verifyCallbackHmac(
      req.body,
      providedHmac
    );

    const updatedSession = isHmacValid
      ? handleVerifiedPayload({
          session,
          normalizedPayload,
          verificationSource: 'webhook_hmac',
          payloadField: 'webhookPayload',
          payload: req.body,
        })
      : markSessionPending(
          session,
          'webhook_unverified',
          'webhookPayload',
          req.body
        );

    return res.status(200).json(buildStatusResponse(updatedSession));
  } catch (error) {
    console.error('Failed to process webhook:', error.message);

    return res.status(500).json({
      success: false,
      error: 'Failed to process webhook',
    });
  }
};

exports.getPaymentStatus = async (req, res) => {
  const paymentSessionId = String(req.params.paymentSessionId || '').trim();
  const session = paymentSessions.get(paymentSessionId);

  if (!session) {
    return res.status(404).json({
      success: false,
      error: 'Payment session not found',
    });
  }

  return res.status(200).json(buildStatusResponse(session));
};
