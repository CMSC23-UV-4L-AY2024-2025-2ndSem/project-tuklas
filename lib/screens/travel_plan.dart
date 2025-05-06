// lib/screens/travel_plan.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/travel_plan_provider.dart';
import '../models/travel_plan_model.dart';

class TravelPlanScreen extends StatelessWidget {
  const TravelPlanScreen({super.key});

  // format date range like "jun 1-7" or "dec 30 - jan 5"
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

  // placeholder images
  final String placeholderImageUrl =
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80';
  final String placeholderAvatarUrl =
      'https://via.placeholder.com/60x60.png?text=P';

  // shows a loading spinner
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF14645B)),
    );
  }

  // shows an error message
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

  // gets user data from firestore based on uid
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  // builds the main screen content structure
  Widget _buildContent(
    BuildContext context,
    String firstName,
    String? photoURL,
    List<TravelPlan> allPlans,
  ) {
    TravelPlan? upcomingPlan; // holds the next upcoming plan
    if (allPlans.isNotEmpty) {
      // Find future plans logic (remains the same)
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
        // fixed header section
        Padding(
          // add padding around the fixed section
          padding: const EdgeInsets.fromLTRB(
            18.0,
            15.0,
            18.0,
            20.0,
          ), // adjust bottom padding as needed
          child: Column(
            // inner Column for fixed items
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // greeting row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good morning,",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          firstName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF14645B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // search Bar
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

        // scrollable section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // upcoming travel plan header
                Text(
                  "Upcoming Travel Plan",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(221, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 12),

                // upcoming plan card
                _buildUpcomingPlanCard(upcomingPlan),
                const SizedBox(height: 28),

                // all travel plans header
                Text(
                  "All Travel Plans",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(221, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 10),

                // list of all plans or "no plans" message
                allPlans.isEmpty
                    ? _buildNoPlansWidget(
                      message: "You have no travel plans yet.",
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

  // builds the card for the single upcoming plan
  Widget _buildUpcomingPlanCard(TravelPlan? upcomingPlan) {
    // ... (implementation remains the same)
    final String defaultImage = placeholderImageUrl; // fallback image

    if (upcomingPlan == null) {
      // show a simple box if no upcoming plan exists
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

    // get the image url or use default
    final String imageUrlToDisplay = upcomingPlan.imageUrl ?? defaultImage;

    // use cliprrect to get rounded corners on the container
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          // background image setup
          image: DecorationImage(
            image: NetworkImage(imageUrlToDisplay), // load image from network
            fit: BoxFit.cover, // make image cover the container
            onError: (exception, stackTrace) {
              /* todo: handle image loading errors properly */
              print('Error loading upcoming plan image: $exception');
            },
          ),
          color: Colors.grey.shade300, // fallback color if image fails
        ),
        // stack allows overlaying text/icons on the image
        child: Stack(
          children: [
            // gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6), // fade to black at bottom
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0], // gradient starts halfway down
                  ),
                ),
              ),
            ),
            // text content (title and date)
            Positioned(
              left: 16,
              bottom: 16,
              right: 80, // space on right to avoid overlap with avatars
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // take minimum space needed
                children: [
                  Text(
                    upcomingPlan.name, // plan title
                    maxLines: 2, // limit to 2 lines
                    overflow:
                        TextOverflow.ellipsis, // add '...' if text overflows
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        // shadow for better readability on images
                        const Shadow(
                          blurRadius: 4.0,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDateRange(
                      upcomingPlan.dates,
                    ), // formatted date range
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      shadows: [
                        // shadow for date text too
                        const Shadow(
                          blurRadius: 3.0,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // participant avatars (placeholder)
            Positioned(
              bottom: 18,
              right: 16,
              child: Row(
                children:
                    List.generate(3, (index) {
                      // generate 3 placeholder avatars
                      return Align(
                        widthFactor: 0.65, // controls how much they overlap
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor:
                              Colors.white, // creates white border effect
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade300,
                            // todo: replace with actual participant data/images
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }).reversed.toList(), // reverse to stack left-to-right visually
              ),
            ),
          ],
        ),
      ),
    );
  }

  // builds the placeholder shown when there are no travel plans
  Widget _buildNoPlansWidget({
    String message = 'No travel plans yet. Add one!',
  }) {
    // ... (implementation remains the same)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            message, // display the provided message
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

  // main build method
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final travelPlanProvider = Provider.of<TravelPlanProvider>(
      context,
      listen: false,
    );

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
        bottom: false, // avoid bottom system bar overlap
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: travelPlanProvider.travelplan,
          builder: (context, planSnapshot) {
            if (planSnapshot.connectionState == ConnectionState.waiting &&
                !planSnapshot.hasData) {
              return _buildLoadingIndicator();
            }
            if (planSnapshot.hasError) {
              print('Plan stream error: ${planSnapshot.error}');
            }

            // fetch user data
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _fetchUserData(currentUser.uid),
              builder: (context, userSnapshot) {
                // loading/error handling for user data
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }
                if (userSnapshot.hasError) {
                  print('User data fetch error: ${userSnapshot.error}');
                  return _buildErrorWidget('Could not load user details.');
                }

                // process user data (default/fallback included)
                String firstName = 'User';
                String? photoURL = currentUser.photoURL;
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data();
                  firstName = userData?['fname'] as String? ?? 'User';
                } else {
                  print('User document not found for uid: ${currentUser.uid}');
                }

                // process plan data (default/fallback included)
                List<TravelPlan> allPlans =
                    (planSnapshot.data?.docs ?? [])
                        .map((doc) {
                          final data = doc.data();
                          data['id'] = doc.id;
                          try {
                            return TravelPlan.fromJson(data);
                          } catch (e) {
                            print(
                              "Error parsing travelplan from firestore: $e, Data: $data",
                            );
                            return null;
                          }
                        })
                        .whereType<TravelPlan>()
                        .toList();

                if (planSnapshot.hasError) {
                  print(
                    "Displaying content despite plan stream error: ${planSnapshot.error}",
                  );
                }

                // muild the main content UI
                return _buildContent(context, firstName, photoURL, allPlans);
              },
            );
          },
        ),
      ),
    );
  }
}

// TravelPlanItem Widget
class TravelPlanItem extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;
  final TravelPlan plan;

  const TravelPlanItem({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.plan,
  });

  // method to show the options bottom sheet
  void _showOptionsBottomSheet(
    BuildContext context,
    TravelPlan planToShowOptionsFor,
  ) {
    showModalBottomSheet(
      context: context,
      // make it scrollable if content overflows
      isScrollControlled: true,
      // set background color and rounded top corners
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        // use Wrap to constrain content height
        return Wrap(
          children: <Widget>[
            // optional: add a drag handle at the top
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                height: 4.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            // list tiles for the options
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey.shade700),
              title: Text('Share', style: GoogleFonts.poppins(fontSize: 15)),
              onTap: () {
                Navigator.pop(context); // close the bottom sheet
                // TO DO: implement share functionality
                print('Share tapped for plan: ${planToShowOptionsFor.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Colors.grey.shade700),
              title: Text('Edit', style: GoogleFonts.poppins(fontSize: 15)),
              onTap: () {
                Navigator.pop(context); // close the bottom sheet
                // TO DO: implement itinerary screens
                print('Edit tapped for plan: ${planToShowOptionsFor.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade600),
              title: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.red.shade600,
                ),
              ),
              onTap: () async {
                Navigator.pop(bc); // close the bottom sheet first

                // show confirmation dialog
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Text(
                        'Delete Plan',
                        style: GoogleFonts.poppins(
                          // style the title
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ), // adjust color if needed
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete "${planToShowOptionsFor.name}"?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                              Colors.black54, // adjust content color if needed
                        ),
                      ),
                      actions: <Widget>[
                        // cancel button
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          onPressed:
                              () => Navigator.of(dialogContext).pop(false),
                        ),
                        // delete button
                        TextButton(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade600,
                              fontWeight:
                                  FontWeight
                                      .w500, // slightly bolder delete text
                              fontSize: 14,
                            ),
                          ),
                          onPressed:
                              () => Navigator.of(dialogContext).pop(true),
                        ),
                      ],
                    );
                  },
                );

                // proceed with deletion only if user confirmed
                if (confirmDelete == true) {
                  final String? planId = planToShowOptionsFor.id;
                  if (planId == null || planId.isEmpty) {
                    print('Error: Plan ID is null or empty, cannot delete.');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cannot delete plan: Missing ID.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.orange.shade800,
                        ),
                      );
                    }
                    return; // stop execution if id is invalid
                  }
                  try {
                    // access the provider to call the delete method
                    await Provider.of<TravelPlanProvider>(
                      context,
                      listen: false,
                    ).deletePlan(planId);

                    if (context.mounted) {
                      // check if widget is still mounted before showing snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"${planToShowOptionsFor.name}" deleted.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    print(
                      'Error deleting plan UI: ${planToShowOptionsFor.id} - $e',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete: ${e.toString().replaceFirst("Exception: ", "")}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } else {
                  // log if user cancelled deletion
                  print(
                    'Delete cancelled for plan: ${planToShowOptionsFor.id}',
                  );
                }
              },
            ),
            // add some padding at the bottom for safe area insets
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  String _formatDateRange(List<Timestamp>? dates) {
    if (dates == null || dates.isEmpty) {
      return 'n/a'; // handle null or empty dates
    }
    String start = DateFormat(
      'MMM d',
    ).format(dates.first.toDate()); // format start date
    if (dates.length > 1) {
      // check if start and end dates are the same day
      DateTime startDate = dates.first.toDate();
      DateTime endDate = dates.last.toDate();
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return start; // return only start date if single day
      }
      // format end date differently if it's in the same month
      String endFormat = (startDate.month == endDate.month) ? 'd' : 'MMM d';
      String end = DateFormat(endFormat).format(endDate);
      return '$start–$end'; // return range string
    }
    return start; // return start date if only one date exists
  }

  @override
  Widget build(BuildContext context) {
    // ... (implementation remains the same)
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal:
              8.0, // Keep horizontal padding for list tile content alignment
        ),
        // leading widget (image)
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            // widget to display if image fails to load
            errorBuilder:
                (context, error, stackTrace) => Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey.shade400,
                    size: 30,
                  ),
                ),
            // widget to display while image is loading
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null)
                return child; // return image if loaded
              return Container(
                // show placeholder container while loading
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  // show small loading spinner inside
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF14645B),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // main title text
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.poppins(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        // subtitle text (date)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            // date
            _formatDateRange(plan.dates), // call formatter here
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        // trailing widget (more options icon button)
        trailing: IconButton(
          icon: Icon(Icons.more_horiz, color: Colors.grey.shade500),
          onPressed: () {
            _showOptionsBottomSheet(context, plan);
          },
          splashRadius: 20,
          tooltip: 'More options', // accessibility tooltip
        ),
        onTap: () {
          /* todo: implement navigation to plan details screen */
          // potentially pass 'plan' object as argument
          print('Tapped on plan item: ${plan.id}');
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
