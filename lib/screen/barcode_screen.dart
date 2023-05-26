import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeScreen extends StatefulWidget {
  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
    scanBarcodeNormal();
  }

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

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scan'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => scanBarcodeNormal(),
                  child: Text(
                    'Start barcode scan'
                    ,style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                // Text(
                //   'Scan result : $_scanBarcode\n',
                //   style: TextStyle(fontSize: 20),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }


}