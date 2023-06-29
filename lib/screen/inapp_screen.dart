import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firstapp/components/dialog.dart';
import 'package:firstapp/components/fcmSetting.dart';
import 'package:firstapp/screen/new_inapp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screen_brightness/screen_brightness.dart';

class InAppScreen extends StatefulWidget {
  const InAppScreen({Key? key}):super(key:key);

  @override
  State<InAppScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppScreen> {
  final GlobalKey webViewKey = GlobalKey();
  Uri myUrl = Uri.parse("http://applibrary2023.15449642.com:8080/");
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) async {
      if(Platform.isAndroid) {
        FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });

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
          '#ff0000', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    if(barcodeScanRes != "-1") {
      // String url = "http://applibrary2023.15449642.com:8080/main/site/appLibrary/search.do?";
      // url += "cmd_name=bookandnonbooksearch";
      // url += "&search_type=detail";
      // url += "&detail=OK";
      // url += "&use_facet=N";
      // url += "&manage_code=MS%2CMB%2CMC%2CMG%2CMA%2CMJ%2CMH%2CMN%2CMO%2CMP%2CMQ%2CMR%2CMK%2CML%2CME%2CMF%2CMT%2CMU%2CMV%2CMW%2CMX%2CNA";
      // url += "&all_lib=N";
      // url += "&all_lib_detail_big=Y";
      // url += "&all_lib_detail_small=Y";
      // url += "&search_isbn_issn=" + barcodeScanRes;
      String url = "http://applibrary2023.15449642.com:8080/main/site/appLibrary/search_isbn.do";
      url += "?search_isbn_issn=" + barcodeScanRes;

      if (webViewController != null) {
        await webViewController.loadUrl(urlRequest: URLRequest(
          url: Uri.parse(url),
        )); // Replace with your new Korean URL
      }
    }
  }
  Future<String?> getDeviceUniqueId() async {
    String? deviceIdentifier = 'unknown';
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      const androidId = AndroidId();
      deviceIdentifier = await androidId.getId();
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId!;
    } else if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    }

    return deviceIdentifier;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar( // 앱바 위젯 추가
        //   // 배경색 지정
        //   backgroundColor: Colors.orange,
        //   // 앱 타이틀 지정
        //   title: Text('Code Factory'),
        //   // 가운데정렬
        //   centerTitle: true,
        //   actions: [
        //     IconButton(
        //       onPressed: () {
        //         scanBarcodeNormal();
        //       },
        //       // 홈 버튼 아이콘 설정
        //       icon: Icon(
        //           Icons.barcode_reader
        //       ),
        //     ),
        //
        //   ],
        // ),
        body: WillPopScope(
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
                            verticalScrollBarEnabled: false, // disabled vertical scroll
                            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'
                        ),
                        android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                            allowContentAccess: true,
                            builtInZoomControls: true,
                            thirdPartyCookiesEnabled: true,
                            allowFileAccess: true,
                            supportMultipleWindows: true,

                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: true,
                          allowsLinkPreview: false, // 아이폰 롱클릭 미리보기 비활성화
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

                        webViewController.addJavaScriptHandler(handlerName: 'GetDeviceKey', callback: (args) async {
                          String? deviceID = await getDeviceUniqueId();

                          return deviceID;
                        });

                        webViewController.addJavaScriptHandler(handlerName: 'GetPushToken', callback: (args) async {
                          // FCM token
                          String? firebaseToken = await fcmSetting();

                          return firebaseToken;
                        });

                        webViewController.addJavaScriptHandler(handlerName: 'GetOS', callback: (args) async {
                          String OsType = "etc";

                          if(Platform.isAndroid) OsType ="android";
                          else if(Platform.isIOS) OsType ="ios";
                          else if(Platform.isWindows) OsType ="windows";
                          else if(Platform.isMacOS) OsType ="macos";
                          else if(Platform.isLinux) OsType ="linux";
                          else if(Platform.isFuchsia) OsType ="fuchsia";

                          return OsType;
                        });

                      },
                      onCreateWindow: (controller, createWindowRequest) async{
                        Uri? url = createWindowRequest.request?.url;
                        if (url != null) {
                          //await webViewController.loadUrl(urlRequest: URLRequest(url: url));
                          //await launchUrl(url);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              //builder: (context) => NewInAppScreen(),
                              builder: (context) => NewInAppScreen(url: url), fullscreenDialog: true
                            ),
                          );
                        }
                        return true; // true 반환하여 기본 동작 방지

                      },
                    )
                  ]))
            ])
        )
    );
  }
}