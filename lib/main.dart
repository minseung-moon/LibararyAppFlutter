import 'package:firstapp/route/routes.dart';
import 'package:flutter/material.dart';

void main() {
  // 플러터 프레임워크가 앱을 실행할 준비가 될 때까지 기다림
  WidgetsFlutterBinding.ensureInitialized();

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
      routes: routes,
    );
  }

}