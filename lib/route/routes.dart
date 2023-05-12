import 'package:firstapp/screen/barcode_screen.dart';
import 'package:firstapp/screen/home_screen.dart';
import 'package:flutter/material.dart';

final routes = {
  '/': (BuildContext context) => HomeScreen(url: 'http://dandi.15449642.com/'),
  '/barcode': (BuildContext context) => BarcodeScreen(),
};