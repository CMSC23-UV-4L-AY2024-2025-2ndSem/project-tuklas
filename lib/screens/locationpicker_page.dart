import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; //to display map
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; //to use latitude and longitude
import 'package:geolocator/geolocator.dart'; //to access location

// this page displays a map, and a user can select/pin a location
// the user must tap the check button to finalize seelcted location
// the map screen will pop after the user finalizes the selected location
class LocationpickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationpickerPage({super.key, this.initialLocation});

  @override
  State<LocationpickerPage> createState() => _LocationpickerPageState();
}

class _LocationpickerPageState extends State<LocationpickerPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String? selectedAddress;
  LatLng? _currentLocation;
  bool _loading = true;

  //for location
  bool locPermissionGranted = false;
  double lat = 0;
  double long = 0;
  //for location permission
  late LocationPermission permission;
  late bool serviceEnabled;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _selectedLocation =
          widget.initialLocation; //initially pin location from search
    }
    _initLocation(); //set current location
  }

  //todo: get user's current location
  Future<void> _initLocation() async {
    try {
      //check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      //check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      //get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _currentLocation = LatLng(14.1570, 121.3105); // fallback: must be UPLB
        _loading = false;
      });
    }
  }

  // method to return place name using coordinates
  // or to convert coordinates into place name, nominatim = 1 query per second
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json',
    ); //parse url
    try {
      // make GET request
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // parse the JSON response
        final data = json.decode(response.body);
        final address =
            data['display_name']; // retrieve the display_name (formatted address)
        return address;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error getting address: $e';
    }
  }

  //todo: create a location picker to be able to select a location
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick your travel location',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation!,
                      initialZoom: 13,
                      onTap: (tapPosition, point) async {
                        final addr = await getAddressFromLatLng(
                          point.latitude,
                          point.longitude,
                        );
                        setState(() {
                          _selectedLocation = point;
                          selectedAddress = addr;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.map_location_picker',
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_pin,
                                color: Color(0xFFCA4A0C),
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (_selectedLocation != null && selectedAddress != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 80,
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: selectedLocation,
                        ),
                      ),
                    ),
                ],
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFCA4A0C),
        onPressed: () async {
          // selected location will be returned to the add location page
          if (_selectedLocation != null) {
            final address = await getAddressFromLatLng(
              _selectedLocation!.latitude,
              _selectedLocation!.longitude,
            );

            final location = {
              'name': address,
              'latitude': _selectedLocation!.latitude,
              'longitude': _selectedLocation!.longitude,
            };

            print("Selected location from map: $location");

            Navigator.pop(
              context,
              location,
            ); //returned value must be a string of location, and coordinates
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please pick a location first!')),
            );
          }
        },
        child: Icon(Icons.done, color: Colors.white),
      ),
    );
  }

  Widget get backButton => IconButton(
    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
    onPressed: () async {
      if (_selectedLocation != null) {
        final address = await getAddressFromLatLng(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
        Navigator.pop(context, address);
      } else {
        Navigator.pop(context);
      }
    },
  );

  //to display coordinates of selected location
  Widget get selectedLocation => Padding(
    padding: EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Text(
          "Address: $selectedAddress",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

// https://medium.com/@paudyal.gaurab11/integrating-open-street-map-in-flutter-3df2da85136f
// https://pub.dev/packages/location_picker_flutter_map
// https://medium.com/@sumaiah.mitu/building-a-smooth-location-search-feature-in-flutter-using-nominatim-api-openstreetmap-893352a70b08
