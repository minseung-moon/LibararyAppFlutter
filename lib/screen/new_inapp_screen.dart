import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screen_brightness/screen_brightness.dart';

class NewInAppScreen extends StatefulWidget {
  final Uri url;

  NewInAppScreen({required this.url});

  @override
  _NewInAppScreenState createState() => _NewInAppScreenState();
}

class _NewInAppScreenState extends State<NewInAppScreen>{
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // 앱 상태 변화 이벤트 감지를 위해 옵저버 등록
    // print("여기 : ${widget.url}");
    // print("initState 호출됨");
    // setBrightness(1);
  }

  @override
  void dispose() {
    super.dispose();
    // 앱 상태 변화 이벤트 감지 옵저버 제거
    // print("여기 : ${widget.url}");
    // print("dispose 호출됨");
    // resetBrightness();
  }

  // 밝기조절 (0~1)
  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set brightness';
    }
  }
  // 밝기 초기화
  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to reset brightness';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: widget.url),
              onWebViewCreated: (controller) {
                _webViewController = controller;
                _addJavaScriptChannel();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addJavaScriptChannel() {
    _webViewController.addJavaScriptHandler(
      handlerName: 'closeNewWindow',
      callback: (args) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // 원하는 JavaScript 코드 작성
        // 예: window.close();
      },
    );
  }
}