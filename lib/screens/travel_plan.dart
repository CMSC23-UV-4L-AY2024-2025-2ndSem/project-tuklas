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
    if (dates == null || dates.isEmpty)
      return 'n/a'; // handle null or empty dates
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

  // placeholder for images if none provided
  final String placeholderImageUrl =
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80';
  // placeholder for avatar images
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
          'error: $error', // display the error text
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

  // builds the main screen content, processing plans and user data
  Widget _buildContent(
    BuildContext context,
    String firstName,
    String? photoURL,
    List<TravelPlan> allPlans,
  ) {
    TravelPlan? upcomingPlan; // holds the next upcoming plan, if any
    if (allPlans.isNotEmpty) {
      // find plans starting today or later
      List<TravelPlan> futurePlans =
          allPlans.where((plan) {
            if (plan.dates.isEmpty) return false; // skip plans with no dates
            DateTime planStartDate = plan.dates.first.toDate();
            // compare just the date part, ignore time
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(today.year, today.month, today.day);
            return !planStartDate.isBefore(
              todayStart,
            ); // check if plan date is not before today
          }).toList();

      if (futurePlans.isNotEmpty) {
        // sort future plans by their start date
        futurePlans.sort((a, b) => a.dates.first.compareTo(b.dates.first));
        upcomingPlan =
            futurePlans.first; // the earliest future plan is the 'upcoming' one
      }
    }

    // main scrollable layout
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18.0, 15.0, 18.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user greeting section
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
                      firstName, // user's first name from auth/firestore
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF14645B),
                      ),
                    ),
                  ],
                ),
              ),
              // user avatar display
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                // todo: use actual photoURL when available
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // search bar input field
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
          const SizedBox(height: 30),

          // upcoming travel plan header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Travel Plan",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(221, 0, 0, 0),
                ),
              ),
              // "see all" button
              TextButton(
                onPressed: () {
                  /* todo: implement see all navigation */
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerRight,
                ),
                child: Text(
                  "See all",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF14645B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // display the upcoming plan card (or placeholder)
          _buildUpcomingPlanCard(upcomingPlan),
          const SizedBox(height: 28),

          // "all travel plans" header
          Text(
            "All Travel Plans",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(221, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 10),

          // display list of all plans or a "no plans" message
          allPlans.isEmpty
              ? _buildNoPlansWidget(
                message: "You have no travel plans yet.",
              ) // show message if list empty
              : ListView.builder(
                shrinkWrap: true, // needed inside singlechildscrollview
                physics:
                    const NeverScrollableScrollPhysics(), // disable list scrolling within outer scrollview
                itemCount: allPlans.length,
                itemBuilder: (context, index) {
                  final plan = allPlans[index];
                  // use the travelplanitem widget for each plan
                  return TravelPlanItem(
                    title: plan.name,
                    date: _formatDateRange(plan.dates), // format the date range
                    imageUrl:
                        plan.imageUrl ??
                        placeholderAvatarUrl, // use placeholder if no image
                    plan: plan, // pass the full plan object
                  );
                },
              ),
          const SizedBox(height: 100), // bottom padding
        ],
      ),
    );
  }

  // builds the card for the single upcoming plan
  Widget _buildUpcomingPlanCard(TravelPlan? upcomingPlan) {
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

  // main build method for the screen - handles auth state and data fetching orchestration
  @override
  Widget build(BuildContext context) {
    // get current user and provider instance
    final currentUser = FirebaseAuth.instance.currentUser;
    final travelPlanProvider = Provider.of<TravelPlanProvider>(
      context,
      listen: false,
    );

    // check if user is logged in, show login prompt if not
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text("Please log in xd", style: GoogleFonts.poppins()),
        ),
      );
    }

    // main screen structure
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // avoids notches and system bars
        bottom: false,
        // listen to the stream of travel plans from the provider
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: travelPlanProvider.travelplan, // the stream source for plans
          builder: (context, planSnapshot) {
            // handle initial loading state for plans stream
            if (planSnapshot.connectionState == ConnectionState.waiting &&
                !planSnapshot.hasData) {
              return _buildLoadingIndicator();
            }
            // log errors from the plan stream if any occur
            if (planSnapshot.hasError) {
              print('Plan stream error: ${planSnapshot.error}');
            }

            // fetch user data using futurebuilder - runs concurrently with stream listening
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _fetchUserData(
                currentUser.uid,
              ), // the future source for user data
              builder: (context, userSnapshot) {
                // handle loading state for user data future
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }
                // handle errors fetching user data - this is a blocking error
                if (userSnapshot.hasError) {
                  print('User data fetch error: ${userSnapshot.error}');
                  return _buildErrorWidget('Could not load user details.');
                }
                // handle case where user document doesn't exist in firestore
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  print('User document not found for uid: ${currentUser.uid}');
                  final firstName = 'User'; // fallback name
                  final photoURL =
                      currentUser.photoURL; // use auth photo url if available
                  // still try to process plans even if user data is missing
                  final allPlans =
                      (planSnapshot.data?.docs ?? [])
                          .map((doc) {
                            final data = doc.data();
                            data['id'] = doc.id; // add document id
                            try {
                              return TravelPlan.fromJson(data);
                            } catch (e) {
                              print(
                                "Error parsing travel plan: $e, data: $data",
                              );
                              return null;
                            }
                          })
                          .whereType<TravelPlan>()
                          .toList();
                  // build content with fallback user data but real plan data
                  return _buildContent(context, firstName, photoURL, allPlans);
                }

                // if no errors, extract user data
                final userData = userSnapshot.data!.data();
                final firstName =
                    userData?['fname'] as String? ??
                    'User'; // get first name or use placeholder
                final photoURL =
                    currentUser
                        .photoURL; // TO DO: maybe get from user data if stored there

                // process travel plans from the stream snapshot data
                final allPlans =
                    (planSnapshot.data?.docs ?? []) // use empty list if no docs
                        .map((doc) {
                          final data = doc.data();
                          data['id'] =
                              doc.id; // add document id to map for reference
                          try {
                            // parse firestore map data into a travelplan object
                            return TravelPlan.fromJson(data);
                          } catch (e) {
                            // catch parsing errors, print details, and skip this item
                            print(
                              "Error parsing travelplan from firestore: $e, data: $data",
                            );
                            return null; // return null for failed parsing
                          }
                        })
                        .whereType<
                          TravelPlan
                        >() // filter out any nulls resulting from parsing errors
                        .toList();

                // log if there was a plan stream error but we're showing content anyway
                if (planSnapshot.hasError) {
                  print(
                    "Displaying content despite plan stream error: ${planSnapshot.error}",
                  );
                }

                // finally, build the main content with fetched/processed data
                return _buildContent(context, firstName, photoURL, allPlans);
              },
            );
          },
        ),
      ),
    );
  }
}

// widget for displaying a single travel plan item in a list
class TravelPlanItem extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;
  final TravelPlan plan; // the actual plan data object

  const TravelPlanItem({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    // use container for margin instead of card elevation for flatter look
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 8.0,
        ),
        // leading widget (image)
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10), // rounded corners for image
          child: Image.network(
            imageUrl, // load image from network
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
          overflow: TextOverflow.ellipsis, // add '...' if too long
          maxLines: 1, // limit to one line
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
            date, // the formatted date string
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
            // TO DO: implement options menu (e.g., edit, delete)
          },
          splashRadius: 20,
          tooltip: 'More options', // accessibility tooltip
        ),
        onTap: () {
          // TO DO: implement navigation to plan details screen
          //  pass 'plan' object as argument
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
