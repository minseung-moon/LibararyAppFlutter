import 'dart:convert';

import 'package:firstapp/components/dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screen_brightness/screen_brightness.dart';

class InAppScreen extends StatefulWidget {
  const InAppScreen({Key? key}):super(key:key);

  @override
  State<InAppScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppScreen> {
  final GlobalKey webViewKey = GlobalKey();
  Uri myUrl = Uri.parse("http://applibrary2023.15449642.com:8080/main/site/appLibrary/main.do");
  //Uri myUrl = Uri.parse("http://dandi.15449642.com/");
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue,),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController.loadUrl(urlRequest: URLRequest(url: await webViewController.getUrl()));}
      },
    ))!;
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

  //뒤로가기 로직(핸드폰 뒤로가기 버튼 클릭시)
  Future<bool> onGoBack(context) async {
    if (await webViewController.canGoBack()) { //=> Webview의 뒤로가기가 가능하면
      webViewController.goBack(); // => Webview 뒤로가기
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

    if (webViewController != null) {
      await webViewController.loadUrl(urlRequest: URLRequest(
        url: Uri.parse(url),
      )); // Replace with your new Korean URL
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
                scanBarcodeNormal();
              },
              // 홈 버튼 아이콘 설정
              icon: Icon(
                  Icons.barcode_reader
              ),
            ),

          ],
        ),
        body: SafeArea(
            child: WillPopScope(
                onWillPop: () => onGoBack(context),
                child: Column(children: <Widget>[
                  // 로딩바
                  // progress < 1.0
                  //     ? LinearProgressIndicator(value: progress, color: Colors.blue)
                  //     : Container(),
                  Expanded(
                      child: Stack(children: [
                        InAppWebView(
                          key: webViewKey,
                          initialUrlRequest: URLRequest(url: myUrl),
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                                javaScriptCanOpenWindowsAutomatically: true,
                                javaScriptEnabled: true,
                                useOnDownloadStart: true,
                                useOnLoadResource: true,
                                useShouldOverrideUrlLoading: true,
                                mediaPlaybackRequiresUserGesture: true,
                                allowFileAccessFromFileURLs: true,
                                allowUniversalAccessFromFileURLs: true,
                                verticalScrollBarEnabled: true,
                                userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'
                            ),
                            android: AndroidInAppWebViewOptions(
                                useHybridComposition: true,
                                allowContentAccess: true,
                                builtInZoomControls: true,
                                thirdPartyCookiesEnabled: true,
                                allowFileAccess: true,
                                supportMultipleWindows: true
                            ),
                            ios: IOSInAppWebViewOptions(
                              allowsInlineMediaPlayback: true,
                              allowsBackForwardNavigationGestures: true,
                            ),
                          ),
                          pullToRefreshController: pullToRefreshController,
                          onLoadStart: (InAppWebViewController controller, uri) {
                            setState(() {myUrl = uri!;});
                          },
                          onLoadStop: (InAppWebViewController controller, uri) {
                            setState(() {myUrl = uri!;});
                          },
                          onProgressChanged: (controller, progress) {
                            if (progress == 100) {pullToRefreshController.endRefreshing();}
                            setState(() {this.progress = progress / 100;});
                          },
                          androidOnPermissionRequest: (controller, origin, resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          },
                          onWebViewCreated: (InAppWebViewController controller) {
                            webViewController = controller;

                            webViewController.addJavaScriptHandler(handlerName: 'Toaster', callback: (args) {
                              String arg = args[0];

                              if(arg != null) {
                                DialogAction positive = DialogAction("확인", () => true);
                                var data = jsonDecode(arg);
                                String title = data['title'] ??  '';
                                String content = data['content'] ?? '';
                                UDialog.confirm(context, title: title, content: content, positive: positive);
                              }
                            });

                            webViewController.addJavaScriptHandler(handlerName: 'TConfirm', callback: (args) {
                              String arg = args[0];

                              var data = jsonDecode(arg);
                              String title = "";
                              String content = data['content'];
                              String okEvent = data['okEvent'];
                              String noEvent = data['noEvent'];

                              DialogAction positive = DialogAction("확인", () {
                                controller.evaluateJavascript(source: okEvent);
                                return true;
                              });
                              DialogAction negative = DialogAction("취소", () {
                                controller.evaluateJavascript(source: noEvent);
                                return true;
                              });
                              UDialog.confirm(context, title: title, content: content, positive: positive, negative: negative);
                            });

                            webViewController.addJavaScriptHandler(handlerName: 'BrightnessMax', callback: (args) {
                              setBrightness(1);
                            });
                            webViewController.addJavaScriptHandler(handlerName: 'BrightnessReset', callback: (args) {
                              resetBrightness();
                            });

                            webViewController.addJavaScriptHandler(handlerName: 'Barcode', callback: (args) {
                              //Navigator.pushNamed(context, "/barcode");
                              scanBarcodeNormal();
                            });

                          },
                          onCreateWindow: (controller, createWindowRequest) async{
                            showDialog(
                              context: context, builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 400,
                                  child: InAppWebView(
                                    // Setting the windowId property is important here!
                                    windowId: createWindowRequest.windowId,
                                    initialOptions: InAppWebViewGroupOptions(
                                      android: AndroidInAppWebViewOptions(
                                        builtInZoomControls: true,
                                        thirdPartyCookiesEnabled: true,
                                      ),
                                      crossPlatform: InAppWebViewOptions(
                                          cacheEnabled: true,
                                          javaScriptEnabled: true,
                                          userAgent: "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
                                      ),
                                      ios: IOSInAppWebViewOptions(
                                        allowsInlineMediaPlayback: true,
                                        allowsBackForwardNavigationGestures: true,
                                      ),
                                    ),
                                    onCloseWindow: (controller) async{
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),);
                            },
                            );
                            return true;
                          },
                        )
                      ]))
                ])
            )
        )
    );
  }
}