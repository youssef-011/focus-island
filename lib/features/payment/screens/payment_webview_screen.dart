import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../services/payment_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String paymentSessionId;
  final String callbackUrlPrefix;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.paymentSessionId,
    required this.callbackUrlPrefix,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _shouldVerifyAfterCallbackLoad = false;

  bool _isBackendCallbackUrl(String url) {
    final normalizedUrl = url.toLowerCase();
    final normalizedCallbackPrefix = widget.callbackUrlPrefix.toLowerCase();

    return normalizedUrl.startsWith(normalizedCallbackPrefix) ||
        normalizedUrl.contains('/payments/callback');
  }

  bool _isHostedSuccessUrl(String url) {
    final normalizedUrl = url.toLowerCase();

    return normalizedUrl.contains('success');
  }

  Future<void> _verifyPaymentResult() async {
    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _isLoading = true;
    });

    try {
      final result = await _paymentService.waitForVerifiedPayment(
        widget.paymentSessionId,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, result);
    } catch (error) {
      debugPrint('Payment verification error: $error');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppColors.warning,
        ),
      );

      setState(() {
        _isVerifying = false;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    debugPrint('Opening checkout URL: ${widget.checkoutUrl}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Checkout navigation request: ${request.url}');

            if (_isBackendCallbackUrl(request.url)) {
              _shouldVerifyAfterCallbackLoad = true;
              return NavigationDecision.navigate;
            }

            if (_isHostedSuccessUrl(request.url)) {
              _verifyPaymentResult();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            debugPrint('Checkout page started: $url');

            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Checkout page finished: $url');

            if (!mounted) {
              return;
            }

            if (_shouldVerifyAfterCallbackLoad && _isBackendCallbackUrl(url)) {
              _shouldVerifyAfterCallbackLoad = false;
              _verifyPaymentResult();
              return;
            }

            if (!_isVerifying) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) {
              return;
            }

            debugPrint('WebView Error: ${error.description}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load checkout page: ${error.description}',
                ),
                backgroundColor: AppColors.warning,
              ),
            );

            setState(() {
              _isLoading = false;
              _isVerifying = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isVerifying ? 'Verifying Payment' : 'Secure Checkout',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.lightGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isVerifying
                        ? 'Confirming payment with the server...'
                        : 'Loading secure checkout...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
