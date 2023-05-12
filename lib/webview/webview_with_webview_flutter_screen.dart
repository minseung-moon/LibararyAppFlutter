import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firstapp/_core/app_bar.dart';

class WebviewWithWebviewFlutterScreen extends StatefulWidget {
  const WebviewWithWebviewFlutterScreen({super.key});

  @override
  State<WebviewWithWebviewFlutterScreen> createState() =>
      _WebviewWithWebviewFlutterScreenState();
}

class _WebviewWithWebviewFlutterScreenState
    extends State<WebviewWithWebviewFlutterScreen> {
  WebViewController? _webViewController;
  @override
  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('http://applibrary2023.15449642.com:8080/main/site/appLibrary/search.do'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBar(title: 'WebView With WebView Flutter'),
      body: WebViewWidget(controller: _webViewController!),
    );
  }
}