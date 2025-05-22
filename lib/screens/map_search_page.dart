import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_photon/flutter_photon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for reverse geocoding if needed

// structure to hold selected location details
class SelectedLocation {
  final String name;
  final LatLng coordinates;

  SelectedLocation({required this.name, required this.coordinates});

  // helper to create a map for returning the result
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }
}

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final PhotonApi _photonApi = PhotonApi(); // initialize api
  Timer? _debounce; // for debouncing search queries

  LatLng? _currentDeviceLocation;
  LatLng? _mapCenterLocation; // where the map is currently centered
  SelectedLocation?
  _selectedLocation; // the selected location (sa search or tap)
  List<PhotonFeature> _searchResults = []; // stores list of results (limit: 7)
  bool _isLoadingLocation = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // location handling

  Future<void> _fetchCurrentUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied.');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentDeviceLocation = LatLng(position.latitude, position.longitude);
        _mapCenterLocation =
            _currentDeviceLocation; // center map to current location initially
        _isLoadingLocation = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      // fallback location
      setState(() {
        _currentDeviceLocation = LatLng(
          13.9421,
          121.1619,
        ); // hometown q as of now hahaha
        _mapCenterLocation = _currentDeviceLocation;
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get current location. Showing default area.',
            ),
          ),
        );
      }
    }
  }

  // search handling

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
    });
    try {
      final results = await _photonApi.forwardSearch(
        query,
        limit: 7, // limit suggestions
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print("Search error: $e");
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    }
  }

  // handling selection of suggested location
  void _onSuggestionSelected(PhotonFeature place) {
    final coordinates = LatLng(
      place.coordinates.latitude.toDouble(),
      place.coordinates.longitude.toDouble(),
    );
    final name = [
      place.name,
      place.city,
      place.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    setState(() {
      _selectedLocation = SelectedLocation(
        name: name,
        coordinates: coordinates,
      );
      _mapCenterLocation = coordinates; // update map center
      _searchResults = []; // clear results
      _searchController.clear(); // clear search field
      FocusManager.instance.primaryFocus?.unfocus(); // hide keyboard
    });

    // move map to the new location
    _mapController.move(
      _mapCenterLocation!,
      14.0, // *zoom level
    );
  }

  // reverse geocoding (for map tap and selected suggestion), *integrated dito yung sa location picker page before*
  Future<String> _getAddressFromLatLng(LatLng coords) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}&format=json&addressdetails=1', // addressdetails=1 can give more structured info
    );
    try {
      final response = await http.get(
        url,
        headers: {"User-Agent": "YourAppName/1.0"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Address not found';
      } else {
        print('Nominatim error: ${response.statusCode}');
        return 'Could not fetch address';
      }
    } catch (e) {
      print('Error getting address: $e');
      return 'Error getting address';
    }
  }

  // map tap handling
  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    print("Map tapped at: $point");
    final String address = await _getAddressFromLatLng(point);
    setState(() {
      _selectedLocation = SelectedLocation(name: address, coordinates: point);
      _searchResults = [];
      _searchController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  // confirmation component
  void _confirmSelection() {
    if (_selectedLocation != null) {
      print("Confirming: ${_selectedLocation!.name}");
      Navigator.pop(context, _selectedLocation!.toMap());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location first.')),
      );
    }
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  _buildMap(),
                  _buildSearchBar(),
                  if (_searchResults.isNotEmpty) _buildSearchResultsList(),
                  if (_selectedLocation != null) _buildConfirmationPanel(),
                ],
              ),
    );
  }

  // widget builders

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            _mapCenterLocation ?? LatLng(13.9421, 121.1619), // ensures fallback
        initialZoom: 13.0,
        onTap: _handleMapTap, // handle map taps
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.yourcompany.yourappname', // placeholder package name
        ),
        // adds marker for selected location
        if (_selectedLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLocation!.coordinates,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red, // Use a distinct color
                  size: 40,
                ),
              ),
            ],
          ),
        // adds a marker for the user's current location
        if (_currentDeviceLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentDeviceLocation!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15, // position below status bar
      left: 15,
      right: 15,
      child: Material(
        // material widget for elevation
        elevation: 4.0,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Search for a location...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
              // for the back button
              prefixIcon: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () {
                  print("Back button pressed");
                  Navigator.pop(context); // Navigate back
                },
              ),
              // for loading indicator
              suffixIcon:
                  _isSearching
                      ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      // add a clear button if there is a text in the search controller
                      : (_searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                          : null), // no icon if empty and not searching
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 0,
                top: 15.0,
                bottom: 15.0,
                right: 15.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 75, // below the search bar
      left: 15,
      right: 15,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3, // limit height
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final place = _searchResults[index];
              final title = place.name ?? 'Unknown Name';
              final subtitle = [
                // build subtitle strings
                place.street,
                place.district,
                place.city,
                place.state,
                place.country,
              ].where((s) => s != null && s.isNotEmpty).join(', ');

              return ListTile(
                title: Text(title, style: GoogleFonts.poppins()),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                dense: true,
                onTap: () => _onSuggestionSelected(place),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationPanel() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedLocation!.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Lat: ${_selectedLocation!.coordinates.latitude.toStringAsFixed(5)}, Lon: ${_selectedLocation!.coordinates.longitude.toStringAsFixed(5)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCA4A0C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                  onPressed: _confirmSelection,
                  child: Text(
                    "Confirm Location",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
