import 'package:firstapp/screen/barcode_screen.dart';
import 'package:firstapp/screen/home_screen.dart';
import 'package:firstapp/screen/inapp_screen.dart';
import 'package:flutter/material.dart';

final routes = {
  //'/': (BuildContext context) => HomeScreen(),
  '/': (BuildContext context) => InAppScreen(),
  '/barcode': (BuildContext context) => BarcodeScreen(),
  //'/inapp': (BuildContext context) => InAppScreen(),
};