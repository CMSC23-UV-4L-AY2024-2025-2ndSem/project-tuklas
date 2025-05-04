import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/travel_plan_model.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/addlocation_page.dart';
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

    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Row(children: [closeButton, SizedBox(width: 20), title]),
              tripNameField,
              findlocation,
              dateFields,
              SizedBox(height: 20),
              addTravelBuddy,
              SizedBox(height: 20),
              Center(child: addPlanButton),
              SizedBox(height: 20),
            ],
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
        width: 300, // Limit the overall width
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextFormField(
            controller: _tripNameController,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Color(0xFFCA4A0C),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "Enter trip name",
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: Color(0xFFCA4A0C),
                fontWeight: FontWeight.bold,
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFCA4A0C), //orange colored field or trip name
                  width: 2,
                ),
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

  //field that pop ups a new screen for location input
  Widget get findlocation => GestureDetector(
    onTap: () async {
      // navigate to full-screen input and wait for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  AddLocationPage(initialText: _locationController.text),
        ),
      );

      // set returned text back to the main field
      if (result != null) {
        _locationController.text = result['name'] as String;
        lat = result['latitude'] as double;
        long = result['longitude'] as double;
      }
    },
    child: AbsorbPointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            label: Text("Where to?"),
            labelStyle: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            hintText: "Search a location",
            hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
          ),
          onTap: () async {
            //push new screen to select location
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddLocationPage(initialText: "Search a location"),
              ),
            );

            if (result != null) {
              _locationController.text = result['name'] as String;
              lat = result['latitude'] as double;
              long = result['longitude'] as double;
            }
          },
          validator: (value) {
            if (value == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Please enter location")));
            } else {
              return;
            }
          },
        ),
      ),
    ),
  );

  //start and end date fields in one row
  Widget get dateFields => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

      if (_formKey.currentState!.validate()) {
        // validate location
        if (lat == null || long == null) {
          //no location selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invalid coordinates on selected location!"),
            ),
          );
          return;
        }
        try {
          //parse dates
          final DateTime startDate = DateTime.parse(_startDateController.text);
          final DateTime endDate = DateTime.parse(_endDateController.text);

          // add plan to database referenced to user
          final user = FirebaseAuth.instance.currentUser;

          // to check output
          print("Trip name: ${_tripNameController.text}");
          print("Start date: $startDate");
          print("End date: $endDate");
          print(
            "Location name: ${_locationController.text}",
          ); // must be converted into coordinates
          print("Coordinates: [$lat, $long]");

          if (user != null) {
            print("User id: ${user.uid}");

            TravelPlan newPlan = TravelPlan(
              name: _tripNameController.text,
              dates: [
                Timestamp.fromDate(startDate),
                Timestamp.fromDate(endDate),
              ],
              location: GeoPoint(
                lat!,
                long!,
              ), //_locationcontroller has address name, convert it back to coordinates when saving
              userId: user.uid, //adding userId when saving travel plan
            );

            //add item to travel plan provider
            context.read<TravelPlanProvider>().addPlan(newPlan);
            //display success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Item successfully added to travel plans!"),
              ),
            );

            //reset formfields
            _resetForm();

            //navigate back to previous page
            Navigator.pop(context);
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("invalid date format.")));
          print("Date parsing error: $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter all required fields!")),
        );
      }
    },
    child: Text(
      "Add",
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
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
