import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firstapp/components/dialog.dart';
// 바코드
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// 화면밝기
import 'package:screen_brightness/screen_brightness.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String url;
  late final Uri uri;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      String arg_url = 'http://applibrary2023.15449642.com:8080/main/site/appLibrary/main.do';
      arg_url = "http://dandi.15449642.com/";

      if(args != null && args['url'] != "") {
        arg_url = args['url'];
      } else {
        // args가 null인 경우에 대한 처리
      }

      url = arg_url;
      uri = Uri.parse(url);

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('Toaster', onMessageReceived: (JavaScriptMessage message) {
          DialogAction positive = DialogAction("확인", () => true);
          var data = jsonDecode(message.message);
          //String title = data['title'];
          String title = "";
          String content = data['content'];
          UDialog.confirm(context, title: title, content: content, positive: positive);
        })
        ..addJavaScriptChannel('TConfirm', onMessageReceived: (JavaScriptMessage message) {
          var data = jsonDecode(message.message);
          //String title = data['title'];
          String title = "";
          String content = data['content'];
          String okEvent = data['okEvent'];
          String noEvent = data['noEvent'];
          DialogAction positive = DialogAction("확인", () {
            controller.runJavaScriptReturningResult(okEvent);
            return true;
          });
          DialogAction negative = DialogAction("취소", () {
            controller.runJavaScriptReturningResult(noEvent);
            return true;
          });
          UDialog.confirm(context, title: title, content: content, positive: positive, negative: negative);
        })
        ..addJavaScriptChannel("Barcode", onMessageReceived: (JavaScriptMessage message) {
          Navigator.pushNamed(context, "/barcode");
        })
        ..addJavaScriptChannel("BrightnessMax", onMessageReceived: (JavaScriptMessage message) {
          setBrightness(1);
        })
        ..addJavaScriptChannel("BrightnessReset", onMessageReceived: (JavaScriptMessage message) {
          resetBrightness();
        })
        ..loadRequest(uri);
    });
  }

  _HomeScreenState() {

    controller = WebViewController();
      // ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..addJavaScriptChannel('Toaster', onMessageReceived: (JavaScriptMessage message) {
      //   DialogAction positive = DialogAction("확인", () => true);
      //   var data = jsonDecode(message.message);
      //   String title = data['title'];
      //   String content = data['content'];
      //   UDialog.confirm(context, title: title, content: content, positive: positive);
      // })
      // ..addJavaScriptChannel('TConfirm', onMessageReceived: (JavaScriptMessage message) {
      //   var data = jsonDecode(message.message);
      //   String title = data['title'];
      //   String content = data['content'];
      //   String OkEvent = data['OkEvent'];
      //   String NoEvent = data['NoEvent'];
      //   DialogAction positive = DialogAction("확인", () {
      //     controller.runJavaScriptReturningResult(OkEvent);
      //     return true;
      //   });
      //   DialogAction negative = DialogAction("취소", () {
      //     controller.runJavaScriptReturningResult(NoEvent);
      //     return true;
      //   });
      //   UDialog.confirm(context, title: title, content: content, positive: positive, negative: negative);
      // })
      // ..loadRequest(uri);
  }

  //앱 나가기 전 dialog
  Future<bool> showExitPopup(context) async {
    return await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('앱 종료'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                // => false 리턴
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                // => true 리턴
                child: const Text('예'),
              ),
            ],
          ),
    ) ?? false;
  }

  //뒤로가기 로직(핸드폰 뒤로가기 버튼 클릭시)
  Future<bool> onGoBack(context) async {
    if (await controller.canGoBack()) { //=> Webview의 뒤로가기가 가능하면
      controller.goBack(); // => Webview 뒤로가기
      return Future.value(false); // => onWillPop은 false면 앱을 끄지 않는다.
    } else {
      //Future<bool> dialogResult = showExitPopup(context);
      //return Future.value(dialogResult); // => true이면 앱 끄기;
      return Future.value(true); // => true이면 앱 끄기;
    }
  }

  // 바코드, 화면 없이 실행
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    //String url = "http://dandi.15449642.com?isbn=" + barcodeScanRes;
    String url = "http://applibrary2023.15449642.com:8080/main/site/appLibrary/search.do?";
    url += "cmd_name=bookandnonbooksearch";
    url += "&search_type=detail";
    url += "&detail=OK";
    url += "&use_facet=N";
    url += "&manage_code=MS%2CMB%2CMC%2CMG%2CMA%2CMJ%2CMH%2CMN%2CMO%2CMP%2CMQ%2CMR%2CMK%2CML%2CME%2CMF%2CMT%2CMU%2CMV%2CMW%2CMX%2CNA";
    url += "&all_lib=N";
    url += "&all_lib_detail_big=Y";
    url += "&all_lib_detail_small=Y";
    url += "&search_isbn_issn=" + barcodeScanRes;

    print('barcode code value');
    print(url);
    Navigator.pushNamed(context, '/', arguments: {'url': url});
  }

  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
      throw 'Failed to set brightness';
    }
  }

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
      appBar: AppBar( // 앱바 위젯 추가
        // 배경색 지정
        backgroundColor: Colors.orange,
        // 앱 타이틀 지정
        title: Text('Code Factory'),
        // 가운데정렬
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //Navigator.pushNamed(context, "/barcode");
              // 바코드 화면없이 실행
              scanBarcodeNormal();
            },
            // 홈 버튼 아이콘 설정
            icon: Icon(
              Icons.barcode_reader
            ),
          ),
        ],
      ),
      body: WillPopScope(
        child: WebViewWidget(controller: controller),
        onWillPop: () => onGoBack(context),
      ),
    );
  }

}