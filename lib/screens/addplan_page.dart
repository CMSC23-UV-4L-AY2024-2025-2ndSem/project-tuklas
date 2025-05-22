import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/travel_plan_model.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/map_search_page.dart';
import 'package:project_TUKLAS/screens/scanqr_page.dart';
import 'package:provider/provider.dart';

//this page allows the user to add a new travel plan
//input fields includes: name of the trip,
//location (with auto suggest feature), date (start and end), and add travel buddy

class AddtravelPage extends StatefulWidget {
  const AddtravelPage({super.key});

  @override
  State<AddtravelPage> createState() => _AddtravelPageState();
}

class _AddtravelPageState extends State<AddtravelPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  double? lat, long;

  // method to reset form fields
  void _resetForm() {
    _tripNameController.clear();
    _locationController.clear();
    _startDateController.clear();
    _endDateController.clear();
    lat = null;
    long = null;
  }

  // method to add a date using datepicker
  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    setState(() {
      controller.text = "${picked!.toLocal()}".split(' ')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    closeButton,
                    const SizedBox(width: 15),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: 20),
                tripNameField,
                findlocation,
                dateFields,
                const SizedBox(height: 20),
                addTravelBuddy,
                const SizedBox(height: 20),
                Center(child: addPlanButton),
                const SizedBox(height: 20),
                Center(child: scanQRButton),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // title widget
  Widget get title => Text(
    "Add Travel Plan",
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 20,
      color: Colors.black,
    ),
  );

  // to add trip name
  Widget get tripNameField => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        width: 300,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            controller: _tripNameController,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Color(0xFFCA4A0C),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Enter trip name",
              hintStyle: GoogleFonts.poppins(
                fontSize: 20,
                color: Color(0xFFCA4A0C),
                fontWeight: FontWeight.bold,
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFCA4A0C), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please name this trip plan first!")),
                );
                return "Please name trip";
              }
              return null;
            },
          ),
        ),
      ),
    ],
  );

  // field that pop ups a new screen for location input
  Widget get findlocation => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: InkWell(
      // inkwell widget for tap feedback
      onTap: () async {
        print("Navigating to MapSearchPage...");
        // navigate to the new MapSearchPage and wait for a result
        final result = await Navigator.push<Map<String, dynamic>>(
          // Expect a Map result
          context,
          MaterialPageRoute(builder: (context) => const MapSearchPage()),
        );

        // handles the returned result
        if (result != null && mounted) {
          print("Received location result: $result");
          // ensures the result contains the expected keys and types
          if (result.containsKey('name') &&
              result.containsKey('latitude') &&
              result.containsKey('longitude') &&
              result['name'] is String &&
              result['latitude'] is double &&
              result['longitude'] is double) {
            setState(() {
              _locationController.text = result['name'] as String;
              lat = result['latitude'] as double?; // use nullable assignment
              long = result['longitude'] as double?; // use nullable assignment
            });
          } else {
            // checker
            print("Received invalid location result format: $result");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid location data received."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          print("No location selected or page dismissed.");
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: "Where to?",
          labelStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        child: Text(
          _locationController.text.isEmpty
              ? "Search or pick a location"
              : _locationController.text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color:
                _locationController.text.isEmpty
                    ? Colors.grey.shade600
                    : Colors.black,
          ),
        ),
      ),
    ),
  );

  //start and end date fields in one row
  Widget get dateFields => Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: startDateField),
        SizedBox(width: 5),
        Expanded(child: endDateField),
      ],
    ),
  );

  // to add start date
  Widget get startDateField => TextFormField(
    controller: _startDateController,
    readOnly: true,
    onTap: () => _pickDate(_startDateController),
    decoration: InputDecoration(
      label: Text("Start Date"),
      labelStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hintText: "Select start date",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator: (value) {
      if (value == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please select a start date")));
        return "Please enter start date atleast.";
      }
      return null;
    },
  );

  //to add end date of trip
  Widget get endDateField => TextFormField(
    controller: _endDateController,
    readOnly: true,
    onTap: () => _pickDate(_endDateController),
    decoration: InputDecoration(
      label: Text("End Date"),
      labelStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      hintText: "Select end date",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // button to add travel buddy
  Widget get addTravelBuddy => Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF027572)),
          onPressed: () {
            // add feature that enables user to add a travel buddy
            print("Adding travel buddy...");
          },
          child: Text(
            "Add a buddy",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );

  //button to submit and add plan
  Widget get addPlanButton => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFCA4A0C),
      foregroundColor: Colors.white,
      minimumSize: Size(350, 56),
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    onPressed: () async {
      print("Adding new travel plan...");

      // validate Form
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields.")),
        );
        return; // stop if form is invalid
      }

      // validate Location
      if (lat == null || long == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a valid location.")),
        );
        return; // stop if location is invalid
      }

      // validate and parse dates
      DateTime? startDate;
      DateTime? endDate;
      try {
        // check if dates are selected
        if (_startDateController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a start date.")),
          );
          return;
        }
        if (_endDateController.text.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Please select an end date.")));
          return;
        }

        startDate = DateTime.parse(_startDateController.text);
        endDate = DateTime.parse(_endDateController.text);

        // ensure end date is not before start date
        if (endDate.isBefore(startDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("End date cannot be before start date.")),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid date format selected.")),
        );
        print("Date parsing error: $e");
        return; // stop if dates are invalid
      }

      // compute date range
      final List<Timestamp> allDates = [];
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        // only store the date part (set time to 00:00:00)
        DateTime dateOnly = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        allDates.add(Timestamp.fromDate(dateOnly));
        currentDate = currentDate.add(
          const Duration(days: 1),
        ); // move to the next day
      }

      // gets user and save to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("User id: ${user.uid}");
        print("Trip name: ${_tripNameController.text}");
        print("Location name: ${_locationController.text}");
        print("Coordinates: [$lat, $long]");
        print("Calculated Dates (Timestamps): $allDates");

        // create the travel plan object with the computed dates
        TravelPlan newPlan = TravelPlan(
          name: _tripNameController.text.trim(), // trim whitespace
          dates: allDates, // use the calculated array of dates
          location: GeoPoint(lat!, long!),
          userId: user.uid,
        );

        try {
          // use the provider to add the plan
          await context.read<TravelPlanProvider>().addPlan(newPlan);

          // display success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${_tripNameController.text.trim()} plan added successfully!",
              ),
              backgroundColor: Colors.green,
            ),
          );

          // reset form fields
          _resetForm();

          // if the widget is still in the tree, navigate back to the previous page
          if (mounted) {
            Navigator.pop(context);
          }
        } catch (e) {
          print("Error adding plan via provider: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to add travel plan. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Error: User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: User not logged in. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    child: Text(
      "Add",
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  // button to scan QR code
  Widget get scanQRButton => ElevatedButton(
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
    onPressed: () {
      // add feature that enables user to scan a QR code
      // pass current user ID to the QR code scanner
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanQRPage()),
      );
      print("Scanning QR code...");
    },
    child: Text(
      "Scan QR Code",
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  //button to close add plan page
  Widget get closeButton => IconButton(
    icon: Icon(Icons.close, color: Colors.black),
    onPressed: () {
      Navigator.of(context).pop(); //return to previous page
    },
  );

  @override
  void dispose() {
    _tripNameController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
