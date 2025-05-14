import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share your QR',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Center(
        child: QrImageView(
          data: widget.travelPlanId ?? 'No Travel Plan ID available',
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
