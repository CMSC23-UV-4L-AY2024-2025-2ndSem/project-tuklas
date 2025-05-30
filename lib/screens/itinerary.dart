import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/map_search_page.dart';
import 'package:provider/provider.dart';
import '../models/itinerary_model.dart';
import '../models/travel_plan_model.dart';
import '../providers/itinerary_provider.dart';
import 'addlocation_page.dart';

class ItineraryScreen extends StatefulWidget {
  final TravelPlan travelPlan;
  final List<String> information;

  const ItineraryScreen({
    super.key,
    required this.travelPlan,
    required this.information,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  List<DateTime> _generateDateRange(List<Timestamp> timestamps) {
    if (timestamps.isEmpty) return [];
    timestamps.sort((a, b) => a.toDate().compareTo(b.toDate()));
    DateTime start = timestamps.first.toDate();
    DateTime end = timestamps.last.toDate();

    List<DateTime> dates = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(Duration(days: 1));
    }
    return dates;
  }

  String _formatLocation(GeoPoint? location) {
    if (location == null) return 'Unknown location';
    return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
  }

  int getDayIndex(DateTime day, List<DateTime> dateRange) {
    for (int i = 0; i < dateRange.length; i++) {
      if (_isSameDate(dateRange[i], day)) {
        return i;
      }
    }
    return -1;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // void _loadSharedusers() async {
  //   final fetchedUsers = await context.read<TravelPlanProvider>().getSharedWith(
  //     widget.travelPlan.id,
  //   );
  //   setState(() {
  //     users = fetchedUsers;
  //   });
  // }

  void _displaySharedWith(
    BuildContext context,
    List<Map<String, dynamic>>? users,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Shared With',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
            ),
            content:
                users == null || users.isEmpty
                    ? Text(
                      'No users sharing this plan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          users.map((user) {
                            return ListTile(
                              title: Text(
                                ' ${user['username']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final message = await context
                                      .read<TravelPlanProvider>()
                                      .removeUser(
                                        user['id'],
                                        widget.travelPlan.id,
                                      );

                                  Navigator.of(context).pop(); // close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        message,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor:
                                          message.contains('successfully')
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  Map<int, TextEditingController> locationControllers = {};
  Map<int, TextEditingController> _notesControllers = {};
  double? lat, long;
  List<Map<String, dynamic>>? users;

  @override
  Widget build(BuildContext context) {
    final dateRange = _generateDateRange(widget.travelPlan.dates);
    List<String> information = widget.information;
    List<GlobalKey<FormState>> formKeyList = [];

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            color: const Color.fromARGB(255, 235, 76, 3),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.travelPlan.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _formatLocation(widget.travelPlan.location),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              if (dateRange.isNotEmpty)
                                Text(
                                  '${DateFormat.yMMMd().format(dateRange.first)} - ${DateFormat.yMMMd().format(dateRange.last)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // display name of users and a remove button to remove them
                                users = await context
                                    .read<TravelPlanProvider>()
                                    .getSharedWith(widget.travelPlan.id);
                                if (context.mounted) {
                                  _displaySharedWith(context, users);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  5,
                                  113,
                                  112,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                "Buddy",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.more_vert, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Itinerary Section
          Expanded(
            child:
                dateRange.isEmpty
                    ? Center(
                      child: Text(
                        "No dates available for this trip.",
                        style: GoogleFonts.poppins(),
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children:
                            dateRange.map((date) {
                              Itinerary itinerary = Itinerary();
                              final formKey = GlobalKey<FormState>();
                              formKeyList.add(formKey);
                              int day = getDayIndex(date, dateRange);
                              if (!_notesControllers.containsKey(day)) {
                                _notesControllers[day] = TextEditingController(
                                  text:
                                      information[(day * 2)].isEmpty
                                          ? ''
                                          : information[(day * 2)],
                                );
                              }
                              TextEditingController notesController =
                                  _notesControllers[day]!;

                              if (!locationControllers.containsKey(day)) {
                                locationControllers[day] =
                                    TextEditingController(
                                      text:
                                          information[1 + (day * 2)].isEmpty
                                              ? ''
                                              : information[1 + (day * 2)],
                                    );
                              }
                              TextEditingController locationController =
                                  locationControllers[day]!;

                              return Form(
                                key: formKeyList[day],
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat.yMMMMEEEEd().format(date),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () async {
                                            print(
                                              "Navigating to MapSearchPage...",
                                            );
                                            // navigate to the new MapSearchPage and wait for a result
                                            final result = await Navigator.push<
                                              Map<String, dynamic>
                                            >(
                                              // Expect a Map result
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const MapSearchPage(),
                                              ),
                                            );

                                            // handles the returned result
                                            if (result != null && mounted) {
                                              print(
                                                "Received location result: $result",
                                              );
                                              // ensures the result contains the expected keys and types
                                              if (result.containsKey('name') &&
                                                  result.containsKey(
                                                    'latitude',
                                                  ) &&
                                                  result.containsKey(
                                                    'longitude',
                                                  ) &&
                                                  result['name'] is String &&
                                                  result['latitude']
                                                      is double &&
                                                  result['longitude']
                                                      is double) {
                                                setState(() {
                                                  locationController.text =
                                                      result['name'] as String;
                                                  lat =
                                                      result['latitude']
                                                          as double?; // use nullable assignment
                                                  long =
                                                      result['longitude']
                                                          as double?; // use nullable assignment
                                                  widget
                                                      .travelPlan
                                                      .location = GeoPoint(
                                                    result['latitude'],
                                                    result['longitude'],
                                                  );
                                                });
                                              } else {
                                                // checker
                                                print(
                                                  "Received invalid location result format: $result",
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Invalid location data received.",
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            } else {
                                              print(
                                                "No location selected or page dismissed.",
                                              );
                                            }
                                          },
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: locationController,
                                              decoration: InputDecoration(
                                                labelText: "Location",
                                                prefixIcon: Icon(
                                                  Icons.pin_drop,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color.fromARGB(
                                                  255,
                                                  233,
                                                  232,
                                                  232,
                                                ),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: const Color.fromARGB(
                                                  255,
                                                  233,
                                                  232,
                                                  232,
                                                ),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: const Color.fromARGB(
                                              255,
                                              222,
                                              222,
                                              222,
                                            ),
                                            hintText: '',
                                            hintStyle: GoogleFonts.poppins(
                                              fontSize: 14,
                                            ),
                                          ),
                                          onSaved:
                                              (value) => setState(() {
                                                itinerary.notes = value;
                                              }),
                                          onChanged: (value) {
                                            notesController.text = value;
                                          },
                                          maxLines: 3,
                                          controller: notesController,
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            formKeyList[day].currentState!
                                                .save();

                                            String? id = await context
                                                .read<ItineraryProvider>()
                                                .getId(
                                                  widget.travelPlan.id!,
                                                  date,
                                                );
                                            await context
                                                .read<ItineraryProvider>()
                                                .editItinerary(
                                                  id,
                                                  widget.travelPlan.id!,
                                                  date,
                                                  widget.travelPlan.location,
                                                  itinerary.notes,
                                                );
                                            List<String> updatedInfo =
                                                await context
                                                    .read<ItineraryProvider>()
                                                    .getInfo(
                                                      widget.travelPlan.id!,
                                                    );
                                            setState(() {
                                              information = updatedInfo;
                                              // Optional: update controller again to reflect backend version
                                              _notesControllers[day]?.text =
                                                  updatedInfo[day * 2];
                                              locationControllers[day]?.text =
                                                  updatedInfo[1 + day * 2];
                                            });
                                            // edit itinerary
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(100, 30),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              5,
                                              113,
                                              112,
                                            ),
                                          ),
                                          child: Text(
                                            "Save",
                                            style: GoogleFonts.poppins(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ---- CHECKLIST SECTION ---- not yet implemented !!
                                        // Column(
                                        //   children: List.generate(4, (index) {
                                        //     return CheckboxListTile(
                                        //       value: checkList[index],
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           checkList[index] = value!;
                                        //         });
                                        //       },
                                        //       title: Text('Checklist item ${index + 1}', style: GoogleFonts.poppins()),
                                        //     );
                                        //   }),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
