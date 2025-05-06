import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_plan_model.dart';

class ItineraryScreen extends StatelessWidget {
  final TravelPlan travelPlan;

  const ItineraryScreen({Key? key, required this.travelPlan}) : super(key: key);

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
    final dateRange = _generateDateRange(travelPlan.dates);

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
                          travelPlan.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          _formatLocation(travelPlan.location),
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        if (dateRange.isNotEmpty)
                          Text(
                            '${DateFormat.yMMMd().format(dateRange.first)} - ${DateFormat.yMMMd().format(dateRange.last)}',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text("Share"),
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
          // Itinerary Section
          Expanded(
            child: dateRange.isEmpty
                ? Center(child: Text("No dates available for this trip."))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: dateRange.map((date) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMMEEEEd().format(date),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                      title: Text('Checklist item ${index + 1}'),
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
}
