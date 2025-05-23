import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_TUKLAS/screens/travel_plan_item.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/travel_plan_provider.dart';
import '../models/travel_plan_model.dart';
import 'user_profile.dart';

class TravelPlanScreen extends StatelessWidget {
  const TravelPlanScreen({super.key});

  String _formatDateRange(List<Timestamp>? dates) {
    if (dates == null || dates.isEmpty) return 'n/a';
    String start = DateFormat('MMM d').format(dates.first.toDate());
    if (dates.length > 1) {
      DateTime startDate = dates.first.toDate();
      DateTime endDate = dates.last.toDate();
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return start;
      }
      String endFormat = (startDate.month == endDate.month) ? 'd' : 'MMM d';
      String end = DateFormat(endFormat).format(endDate);
      return '$start–$end';
    }
    return start;
  }

  final String placeholderImageUrl =
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80';
  final String placeholderAvatarUrl =
      'https://via.placeholder.com/60x60.png?text=P';

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF14645B)),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'error: $error',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.red.shade800),
        ),
      ),
    );
  }

  Widget _buildNoPlansWidget({
    String message = 'No travel plans yet. Add one!',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPlanCard(TravelPlan? upcomingPlan) {
    final String defaultImage = placeholderImageUrl;

    if (upcomingPlan == null) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            'No upcoming plans.',
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final String imageUrlToDisplay = upcomingPlan.imageUrl ?? defaultImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrlToDisplay),
            fit: BoxFit.cover,
          ),
          color: Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upcomingPlan.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDateRange(upcomingPlan.dates),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 18,
              right: 16,
              child: Row(
                children:
                    List.generate(
                      3,
                      (index) => Align(
                        widthFactor: 0.65,
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ).reversed.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // method to change greeting depending on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 18) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  Widget _buildContent(
    BuildContext context,
    String fullName,
    String? photoURL,
    List<TravelPlan> allPlans,
  ) {
    TravelPlan? upcomingPlan;
    if (allPlans.isNotEmpty) {
      List<TravelPlan> futurePlans =
          allPlans.where((plan) {
            if (plan.dates.isEmpty) return false;
            DateTime planStartDate = plan.dates.first.toDate();
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(today.year, today.month, today.day);
            return !planStartDate.isBefore(todayStart);
          }).toList();

      if (futurePlans.isNotEmpty) {
        futurePlans.sort((a, b) => a.dates.first.compareTo(b.dates.first));
        upcomingPlan = futurePlans.first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 15.0, 18.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF14645B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UserProfilePage(
                                username: 'your_username_here',
                              ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUpcomingPlanCard(upcomingPlan),
                const SizedBox(height: 28),
                Text(
                  "All Travel Plans",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF14645B),
                  ),
                ),
                const SizedBox(height: 28),
                allPlans.isEmpty
                    ? _buildNoPlansWidget(
                      message: "No travel plans yet. Add one!",
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allPlans.length,
                      itemBuilder: (context, index) {
                        final plan = allPlans[index];
                        return TravelPlanItem(
                          title: plan.name,
                          date: _formatDateRange(plan.dates),
                          imageUrl: plan.imageUrl ?? placeholderAvatarUrl,
                          plan: plan,
                        );
                      },
                    ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFirstName(
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot,
  ) {
    if (userSnapshot.hasData && userSnapshot.data!.exists) {
      final userData = userSnapshot.data!.data();
      return userData?['fname'] as String? ?? 'User';
    }
    return 'User';
  }

  List<TravelPlan> _parseTravelPlans(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> planSnapshot,
  ) {
    return (planSnapshot.data?.docs ?? [])
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          try {
            return TravelPlan.fromJson(data);
          } catch (e) {
            print("Error parsing travel plan from firestore: $e, Data: $data");
            return null;
          }
        })
        .whereType<TravelPlan>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final travelPlanProvider = Provider.of<TravelPlanProvider>(
      context,
      listen: false,
    );

    // Use provider to get current user
    final currentUser = travelPlanProvider.getCurrentUser();

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text("Please log in", style: GoogleFonts.poppins()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: travelPlanProvider.createdTravelPlans(),
          builder: (context, planSnapshot) {
            if (planSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            }

            if (planSnapshot.hasError) {
              print('Plan stream error: ${planSnapshot.error}');
              return _buildErrorWidget('Failed to load travel plans.');
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  travelPlanProvider
                      .sharedTravelPlans(), // Stream for shared plans
              builder: (context, sharedPlanSnapshot) {
                if (sharedPlanSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                if (sharedPlanSnapshot.hasError) {
                  print(
                    'Shared plan stream error: ${sharedPlanSnapshot.error}',
                  );
                  return _buildErrorWidget(
                    'Failed to load shared travel plans.',
                  );
                }

                // Combine created and shared travel plans
                List<TravelPlan> allPlans = _parseTravelPlans(planSnapshot);
                List<TravelPlan> sharedPlans = _parseTravelPlans(
                  sharedPlanSnapshot,
                );

                allPlans.addAll(sharedPlans);

                // Use provider to fetch user data
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: travelPlanProvider.fetchUserData(currentUser.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingIndicator();
                    }

                    if (userSnapshot.hasError) {
                      print('User data fetch error: ${userSnapshot.error}');
                      return _buildErrorWidget('Could not load user details.');
                    }

                    final firstName = _getFirstName(userSnapshot);
                    final photoURL = currentUser.photoURL;

                    return _buildContent(
                      context,
                      firstName,
                      photoURL,
                      allPlans,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
