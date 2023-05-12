// ** lib/controller/webview_controller.dart **
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewMainController extends GetxController {
static WebviewMainController get to => Get.find();

var controller = WebViewController()
..setJavaScriptMode(JavaScriptMode.unrestricted)
..setBackgroundColor(const Color(0x00000000))
..setNavigationDelegate(
NavigationDelegate(
onProgress: (int progress) {
// Update loading bar.
},
onPageStarted: (String url) {},
onPageFinished: (String url) {},
onWebResourceError: (WebResourceError error) {},
onNavigationRequest: (NavigationRequest request) {
if (request.url.startsWith('https://www.youtube.com/')) {
return NavigationDecision.prevent;
}
return NavigationDecision.navigate;
},
),
)
..loadRequest(Uri.parse('Your url')); // => 웹뷰에 연결할 URL

WebViewController getController() {
return controller;
}
}