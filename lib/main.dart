import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firstapp/components/fcmSetting.dart';
import 'package:firstapp/screen/inapp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firstapp/route/routes.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // 플러터 프레임워크가 앱을 실행할 준비가 될 때까지 기다림
  WidgetsFlutterBinding.ensureInitialized();

  // FCM token
  // String? firebaseToken = await fcmSetting();
  // print('firebaseToken : ${firebaseToken}');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 화면 세로모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //runApp(MyApp());
  // 휴대폰 유니크 아이디 전달
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

  // Get device unique ID before runApp
  String? initDeviceKey = await getDeviceUniqueId();
  String initUrl = "?appkey=${initDeviceKey}";
  String url = "http://applibrary2023.15449642.com:8080/main/site/appLibrary/intro.do$initUrl";

  runApp(MyApp(url: url));

}

class MyApp extends StatelessWidget {

  final String url;

  const MyApp({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '익산시립도서관',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue
      ),
      //routes: routes,
      home: InAppScreen(url: url,),
    );
  }

}