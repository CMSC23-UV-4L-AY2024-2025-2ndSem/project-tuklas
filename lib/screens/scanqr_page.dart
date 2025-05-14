import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  late String? travelPlanid; // store travel plan id here

  // method to add user id to plan['sharedWith']
  Future<void> addUserToPlan(String? travelPlanId) async {
    // add user ID to  plan['sharedWith'] document
    try {
      String? message = await context.read<TravelPlanProvider>().sharePlan(
        travelPlanId,
      );
      print(message);
    } catch (e) {
      print('Error saving shared plan via provider:$e');
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child:
                  (result != null)
                      ? Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',
                      )
                      : Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData; // identified the text, stored as Barcode
        travelPlanid = result!.code; // result!.code is the travel plan id
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
