import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_photon/flutter_photon.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_TUKLAS/screens/locationpicker_page.dart';

// this page allows the user to add location to travel plan,
// feature: search results, and auto suggestions from Photon
class AddLocationPage extends StatefulWidget {
  final String initialText;

  const AddLocationPage({super.key, required this.initialText});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final api = PhotonApi(); // to use photon api
  late TextEditingController _controller; // to fetch location name
  List<PhotonFeature> search_results = []; //for search results
  double? lat, long; // to store coordinates

  void _search(String query) async {
    if (query.isEmpty) return;

    final results = await api.forwardSearch(
      query,
    ); //forward search (input: place name , output: coordinates)

    if (!mounted) {
      return;
    }

    setState(() {
      search_results = results;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: tripLocationField,
              ),
              searchResults,
            ],
          ),
        ),
      ),
    );
  }

  // field to search and add location
  Widget get tripLocationField => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        label: Text(
          "Where to?",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        hintText: "Search a location",
        hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        prefixIcon: backButton,
        suffixIcon: pickOnMapButton,
      ),
      onFieldSubmitted: (value) {
        Navigator.pop(
          context,
          value,
        ); //return to add to plan page w/ the inputted value
      },
      onChanged: _search,
    ),
  );

  Widget get backButton => IconButton(
    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
    onPressed: () {
      //return to add to plan page
      if (lat == null || long == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Selected location has invalid coordinates!")),
        );
      }
      final location = {
        'name': _controller.text,
        'latitude': lat,
        'longitude': long,
      };
      print("Selected from search results: $location");

      Navigator.pop(context, location); //return location name and coordinates
    },
  );

  //to display results based on user query
  Widget get searchResults => Expanded(
    child: ListView.builder(
      itemCount: search_results.length,
      itemBuilder: (context, index) {
        final place = search_results[index];

        return ListTile(
          title: Text(place.name ?? 'Unknown'),
          subtitle: Text(
            '${place.city ?? ''}, ${place.country ?? ''}, ${place.district ?? ''}, ${place.houseNumber ?? ''}',
          ),
          onTap: () {
            print(
              'Selected: ${place.name.toString()}, ${place.city.toString()}, ${place.country.toString()}, ${place.coordinates.latitude}, ${place.coordinates.longitude}',
            );
            //set location name
            _controller.text = [
              place.name,
              place.city,
              place.country,
            ].where((e) => e != null && e.isNotEmpty).join(', ');
            //set coordinates
            lat = place.coordinates.latitude as double;
            long = place.coordinates.longitude as double;
          },
        );
      },
    ),
  );

  Widget get pickOnMapButton => IconButton(
    onPressed: () async {
      print("Opening map...");

      if (lat == null || long == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please enter location again.")));
        return;
      }

      //navigate to map to pick location
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => LocationpickerPage(
                initialLocation: LatLng(lat!, long!),
              ), //coordinates of the selected location from search must be initially pinned on map
        ),
      ); //return value: result is a Map<String, Object>

      if (result != null) {
        _controller.text = result['name'] as String;
        lat = result['latitude'] as double;
        long = result['longitude'] as double;
      } // set coordinates and location name from location picked on map
    },
    icon: Icon(Icons.map_rounded),
  );

  @override
  void dispose() {
    _controller.dispose();
    search_results.clear();
    super.dispose();
  }
}

// FOR PLACES AUTOCOMPLETE SUGGESTIONS:
// [reference] https://pub.dev/packages/flutter_photon
// add 'flutter_photon: ^1.0.0' in pubspec.yaml under dependencies,
// then run flutter pub get
// import package, and initialize api
