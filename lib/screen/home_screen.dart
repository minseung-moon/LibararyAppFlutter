import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

// URI/URL을 생성하는데 도움을 주는 클래스
// 쿼리파라미터 등을 스트링으로 입력해도 알아서 처리해준다
final uri = Uri.parse('http://dandi.15449642.com/');

class HomeScreen extends StatefulWidget {
  final String url;

  //HomeScreen({Key? key}) : super(key: key);
  HomeScreen({Key? key, required this.url}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(url);

}

class _HomeScreenState extends State<HomeScreen> {
  late final String url;
  late final Uri uri;
  late final WebViewController controller;

  _HomeScreenState(this.url) {
    uri = Uri.parse(url);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Toaster', onMessageReceived: (JavaScriptMessage message) {
        Fluttertoast.showToast(
          msg: message.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      })
      ..loadRequest(uri);
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
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                // => false 리턴
                child: const Text('아니오'),
              ),
              ElevatedButton(
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
      Future<bool> dialogResult = showExitPopup(context);
      return Future.value(dialogResult); // => true이면 앱 끄기;
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
              // 웹뷰에서 보여줄 사이트 실행하기
              //controller.loadRequest(uri);
              Navigator.pushNamed(context, "/barcode");
            },
            // 홈 버튼 아이콘 설정
            icon: Icon(
              Icons.home,
            ),
          ),
        ],
      ),
      body: WillPopScope(
        child: WebViewWidget(controller: controller
          ..addJavaScriptChannel("Barcode", onMessageReceived: (JavaScriptMessage message) {
            //var data = jsonDecode(message.message);

            Navigator.pushNamed(context, "/barcode");
          }),),
        onWillPop: () => onGoBack(context),
      ),
      // body: WebViewWidget( // webview 추가하기
      //   controller: controller,
      // ),

    );
  }

}