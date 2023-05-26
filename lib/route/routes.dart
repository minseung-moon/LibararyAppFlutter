import 'package:firstapp/screen/barcode_screen.dart';
import 'package:firstapp/screen/home_screen.dart';
import 'package:firstapp/screen/sst_screen.dart';
import 'package:flutter/material.dart';

final routes = {
  '/': (BuildContext context) => HomeScreen(),
  '/barcode': (BuildContext context) => BarcodeScreen(),
  '/sst': (BuildContext context) => SttScreen(),
};