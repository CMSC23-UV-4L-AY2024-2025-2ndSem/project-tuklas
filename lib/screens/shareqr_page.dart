import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// This page generates a QR code for the travel plan
// It takes the travel plan id as input and generates a QR code
// The QR code can be scanned by other users to view the travel plan

class GenerateQrPage extends StatefulWidget {
  final String? travelPlanId;
  const GenerateQrPage({super.key, required this.travelPlanId});

  @override
  State<GenerateQrPage> createState() => _GenerateQrPageState();
}

class _GenerateQrPageState extends State<GenerateQrPage> {
  Future<void> _downloadQRCode() async {
    try {
      final qrPainter = QrPainter(
        data: widget.travelPlanId ?? 'No Travel Plan ID available',
        version: QrVersions.auto,
        gapless: false,
      );

      final image = await qrPainter.toImage(200); // Image size
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = Directory(
        '/storage/emulated/0/Download',
      ); // Save to Downloads
      final filePath = '${directory.path}/travel_plan_qr.png';

      // UNCOMMENT IF NECESSARY (e.g., when not in debug mode)
      // final selectedDirectory = await getExternalStorageDirectory();
      // if (selectedDirectory == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Failed to get directory')),
      //   );
      //   return;
      // }
      // final filePath = '${selectedDirectory.path}/travel_plan_qr.png';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('QR Code saved to $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
    }
  }

  //TODO: Add a function to enable user to share the travel plan by entering the username of another user
  void _shareTravelPlanViaUsername() {
    showDialog(
      context: context,
      builder: (context) {
        String? username;
        return AlertDialog(
          title: Text(
            'Share Travel Plan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: TextField(
            onChanged: (value) {
              username = value;
            },
            decoration: InputDecoration(hintText: 'Enter username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (username != null && username!.isNotEmpty) {
                  final message = context
                      .read<TravelPlanProvider>()
                      .sharePlanToUserViaUsername(
                        widget.travelPlanId!,
                        username!,
                      );
                  Navigator.of(context).pop();
                  // Show message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing to username $username: $message'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(
                'Share',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share your QR',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            backgroundColor: Colors.white,
            data: widget.travelPlanId ?? 'No Travel Plan ID available',
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _downloadQRCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF027572),
              foregroundColor: Colors.white,
              minimumSize: Size(350, 56),
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(
              'Download QR Code',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _shareTravelPlanViaUsername,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCA4A0C),
              foregroundColor: Colors.white,
              minimumSize: Size(350, 56),
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text('Input username'),
          ),
        ],
      ),
    );
  }
}
