import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class PolarCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final String successUrl;
  final String cancelUrl;

  const PolarCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  @override
  State<PolarCheckoutWebView> createState() => _PolarCheckoutWebViewState();
}

class _PolarCheckoutWebViewState extends State<PolarCheckoutWebView> {
  double progress = 0;
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      useSafeArea: true,
      appBar: AppBar(
        title: Text(
          'Complete Purchase',
          style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: false), // User cancelled
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              _handleUrlChange(url);
            },
            onLoadStop: (controller, url) {
              _handleUrlChange(url);
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              _handleUrlChange(url);
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF7F67CB),
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }

  void _handleUrlChange(WebUri? url) {
    if (url == null) return;
    final urlString = url.toString();

    if (urlString.startsWith(widget.successUrl)) {
      Get.back(result: true); // Payment success
    } else if (urlString.startsWith(widget.cancelUrl)) {
      Get.back(result: false); // Payment cancelled
    }
  }
}
