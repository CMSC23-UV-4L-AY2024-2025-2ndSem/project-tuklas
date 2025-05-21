import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? travelPlanId;

  // Method to add user id to plan['sharedWith']
  Future<void> addUserToPlan(String? travelPlanId) async {
    if (travelPlanId == null) return;

    try {
      String? message = await context.read<TravelPlanProvider>().sharePlan(
        travelPlanId,
      );
      print(message);
    } catch (e) {
      print('Error saving shared plan via provider: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    travelPlanId = barcodes.first.rawValue;
                  });
                  addUserToPlan(travelPlanId);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child:
                  (travelPlanId != null)
                      ? Text('Travel Plan ID: $travelPlanId')
                      : const Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }
}
