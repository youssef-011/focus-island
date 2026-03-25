import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });

            // Redirect detection for Success/Fail
            if (url.contains('success')) {
              Navigator.pop(context, true);
            } else if (url.contains('fail')) {
              Navigator.pop(context, false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            debugPrint('WebView Error: ${error.description}');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load checkout page: ${error.description}'),
                backgroundColor: AppColors.warning,
              ),
            );
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
        title: const Text(
          'Secure Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.lightGreen,
              ),
            ),
        ],
      ),
    );
  }
}
