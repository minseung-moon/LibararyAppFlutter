import 'package:firebase_core/firebase_core.dart';
import 'package:firstapp/components/fcmSetting.dart';
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

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.lightBlue
      ),
      //routes: routes,
    );
  }

}