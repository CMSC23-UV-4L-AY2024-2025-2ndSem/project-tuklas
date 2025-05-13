import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/map_search_page.dart';
import 'package:provider/provider.dart';
import '../models/travel_plan_model.dart';

class ItineraryScreen extends StatefulWidget {
  final TravelPlan travelPlan;

  const ItineraryScreen({super.key, required this.travelPlan});

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
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

  @override
  Widget build(BuildContext context) {
    final dateRange = _generateDateRange(widget.travelPlan.dates);

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            color: const Color.fromARGB(255, 235, 76, 3),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.travelPlan.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formatLocation(widget.travelPlan.location),
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        if (dateRange.isNotEmpty)
                          Text(
                            '${DateFormat.yMMMd().format(dateRange.first)} - ${DateFormat.yMMMd().format(dateRange.last)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 113, 112),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text("Share"),
                    ),
                    IconButton(
                      onPressed: () {
                        _showEditModal(context, widget.travelPlan);
                      },
                      icon: Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Itinerary Section
          Expanded(
            child:
                dateRange.isEmpty
                    ? Center(child: Text("No dates available for this trip."))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children:
                            dateRange.map((date) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat.yMMMMEEEEd().format(date),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Text("Add Location"),
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Add notes here',
                                        ),
                                        maxLines: 3,
                                      ),
                                      SizedBox(height: 8),
                                      Column(
                                        children: List.generate(4, (index) {
                                          return CheckboxListTile(
                                            value: false,
                                            onChanged: (_) {},
                                            title: Text(
                                              'Checklist item ${index + 1}',
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
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

  void _showEditModal(BuildContext context, TravelPlan travelPlan) {
    final nameController = TextEditingController(text: travelPlan.name);
    final locationController = TextEditingController(
      text:
          travelPlan.location != null
              ? 'Lat: ${travelPlan.location!.latitude}, Lng: ${travelPlan.location!.longitude}'
              : '',
    );
    final startDateController = TextEditingController(
      text:
          travelPlan.dates.isNotEmpty
              ? DateFormat.yMMMd().format(travelPlan.dates.first.toDate())
              : '',
    );

    final endDateController = TextEditingController(
      text:
          travelPlan.dates.isNotEmpty
              ? DateFormat.yMMMd().format(travelPlan.dates.last.toDate())
              : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Trip',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Trip Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                readOnly: true,
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapSearchPage(),
                    ),
                  );
                  if (result != null &&
                      result.containsKey('latitude') &&
                      result.containsKey('longitude')) {
                    setState(() {
                      locationController.text =
                          'Lat: ${result['latitude']}, Lng: ${result['longitude']}';
                    });
                  }
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: startDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Start Date'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    startDateController.text = DateFormat.yMMMd().format(
                      picked!,
                    );
                  });
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: endDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'End Date'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    endDateController.text = DateFormat.yMMMd().format(picked!);
                  });
                },
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final startDate = DateFormat.yMMMd().parse(
                    startDateController.text,
                  );
                  final endDate = DateFormat.yMMMd().parse(
                    endDateController.text,
                  );

                  final updatedPlan = TravelPlan(
                    id: travelPlan.id,
                    name: nameController.text,
                    dates: [
                      Timestamp.fromDate(startDate),
                      Timestamp.fromDate(endDate),
                    ],
                    location: GeoPoint(
                      double.parse(
                        locationController.text
                            .split(',')[0]
                            .split(':')[1]
                            .trim(),
                      ),
                      double.parse(
                        locationController.text
                            .split(',')[1]
                            .split(':')[1]
                            .trim(),
                      ),
                    ),
                    userId: travelPlan.userId,
                    imageUrl: travelPlan.imageUrl,
                  );

                  // Update plan using the TravelPlanProvider
                  await context.read<TravelPlanProvider>().editPlan(
                    updatedPlan.id!,
                    updatedPlan.name,
                    updatedPlan.dates,
                    updatedPlan.location!,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
