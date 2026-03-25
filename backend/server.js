const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const crypto = require('crypto');

dotenv.config();

const paymentRoutes = require('./routes/payment_routes');

const app = express();
const PORT = Number(process.env.PORT) || 3000;
const otpStore = new Map();
const OTP_TTL_MS = 5 * 60 * 1000;
const isProduction = process.env.NODE_ENV === 'production';

app.use(
  cors({
    origin: true,
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  const startedAt = Date.now();
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);

  res.on('finish', () => {
    const durationMs = Date.now() - startedAt;
    console.log(
      `[${new Date().toISOString()}] ${req.method} ${req.originalUrl} ${res.statusCode} ${durationMs}ms`
    );
  });

  next();
});

app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Focus Island backend is running',
    port: PORT,
  });
});

app.post('/api/auth/send-otp', (req, res) => {
  const email = String(req.body?.email || '').trim().toLowerCase();

  if (!email) {
    return res.status(400).json({
      success: false,
      message: 'Email is required',
    });
  }

  const otp = String(crypto.randomInt(100000, 1000000));
  otpStore.set(email, {
    otp,
    expiresAt: Date.now() + OTP_TTL_MS,
  });

  if (!isProduction) {
    console.log(`Development OTP for ${email}: ${otp}`);
  }

  const responsePayload = {
    success: true,
    message: 'OTP sent successfully',
  };

  if (!isProduction) {
    responsePayload.otp_preview = otp;
  }

  return res.status(200).json(responsePayload);
});

app.post('/api/auth/verify-otp', (req, res) => {
  const email = String(req.body?.email || '').trim().toLowerCase();
  const otp = String(req.body?.otp || '').trim();
  const storedOtp = otpStore.get(email);

  if (!email || !otp) {
    return res.status(400).json({
      success: false,
      message: 'Email and OTP are required',
    });
  }

  if (!storedOtp) {
    return res.status(404).json({
      success: false,
      message: 'No OTP request found for this email',
    });
  }

  if (Date.now() > storedOtp.expiresAt) {
    otpStore.delete(email);
    return res.status(400).json({
      success: false,
      message: 'OTP expired. Please request a new code.',
    });
  }

  if (storedOtp.otp !== otp) {
    return res.status(401).json({
      success: false,
      message: 'Invalid OTP',
    });
  }

  otpStore.delete(email);

  return res.status(200).json({
    success: true,
    message: 'OTP verified successfully',
  });
});

app.use('/payments', paymentRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);

  res.status(500).json({
    success: false,
    message: 'Internal server error',
  });
});

app.listen(PORT, () => {
  console.log(`Focus Island backend listening on port ${PORT}`);
});
