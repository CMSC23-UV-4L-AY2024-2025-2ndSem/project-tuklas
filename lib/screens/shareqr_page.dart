import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  // Helper function for showing SnackBars
  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _downloadQRCode() async {
    // check if the app has permission to access storage
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }

    Directory directory = Directory("");
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final exPath = directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);

    try {
      final qrPainter = QrPainter(
        data: widget.travelPlanId ?? 'No Travel Plan ID available',
        version: QrVersions.auto,
        gapless: false,
      );

      final image = await qrPainter.toImage(150);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final filePath =
          '$exPath/travel_plan_${widget.travelPlanId}.png'; // reference
      final file = File(filePath); // reference

      await file.writeAsBytes(pngBytes); // write the image to file

      showSnackbar('QR Code saved to $filePath');
    } catch (e) {
      showSnackbar('Error saving QR code: $e');
    }
  }

  // Function to share the travel plan via username
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
                  context.read<TravelPlanProvider>().sharePlanToUserViaUsername(
                    widget.travelPlanId!,
                    username!,
                  );
                  Navigator.of(context).pop();
                  showSnackbar('Sharing travel plan to username: $username');
                } else {
                  showSnackbar('Please enter a valid username');
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the QR code
            QrImageView(
              backgroundColor: Colors.white,
              data: widget.travelPlanId ?? 'No Travel Plan ID available',
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            // Download QR code button
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
            // Share QR code by username button
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
      ),
    );
  }
}
