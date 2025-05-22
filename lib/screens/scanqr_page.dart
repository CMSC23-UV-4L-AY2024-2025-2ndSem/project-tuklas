import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isProcessing = false; //flag to prevent multiple scans

  // Method to add user id to plan['sharedWith']
  Future<String?> addUserToPlan(String? travelPlanId) async {
    if (travelPlanId == null) return null;

    try {
      String? message = await context.read<TravelPlanProvider>().sharePlan(
        travelPlanId,
      );
      print(message);
      return message;
    } catch (e) {
      print('Error saving shared plan via provider: $e');
      return 'Error saving shared plan via provider: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF027572),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) async {
                if (isProcessing) return;
                isProcessing = true;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    travelPlanId = barcodes.first.rawValue;
                  });
                  //display return message
                  final message = await addUserToPlan(travelPlanId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Travel Plan ID: $travelPlanId: $message'),
                    ),
                  );
                  await Future.delayed(Duration(seconds: 2));
                }
                isProcessing = false;
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child:
                  (travelPlanId != null)
                      ? Text(
                        'Travel Plan ID: $travelPlanId',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                      : Text(
                        'Scan a code',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
