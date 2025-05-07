// lib/screens/travel_plan.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/travel_plan_provider.dart'; // handles plan data logic
import '../models/travel_plan_model.dart'; // data structure for a plan

class TravelPlanScreen extends StatelessWidget {
  const TravelPlanScreen({super.key});

  // turns a list of firestore timestamps into a readable date range string
  // e.g., "jun 1" or "jun 1–7" or "dec 30–jan 5"
  String _formatDateRange(List<Timestamp>? dates) {
    if (dates == null || dates.isEmpty) return 'n/a'; // nothing to format
    String start = DateFormat(
      'MMM d',
    ).format(dates.first.toDate()); // format the start
    if (dates.length > 1) {
      // if there's more than one date, assume it's a range
      DateTime startDate = dates.first.toDate();
      DateTime endDate = dates.last.toDate(); // using last date for range end
      // if it's actually a single day event marked with two same timestamps
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return start; // just show the single day
      }
      // if end date is in a different month, include month in end string
      String endFormat = (startDate.month == endDate.month) ? 'd' : 'MMM d';
      String end = DateFormat(endFormat).format(endDate);
      return '$start–$end'; // combine start and end
    }
    return start; // only one date, just return it formatted
  }

  // default image url
  final String placeholderImageUrl =
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80';
  final String placeholderAvatarUrl =
      'https://via.placeholder.com/60x60.png?text=P';

  // simple spinning loader widget
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF14645B)),
    );
  }

  // simple error display widget
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'error: $error', // show the error passed in
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.red.shade800),
        ),
      ),
    );
  }

  // displays a message when there are no travel plans
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

  // fetches specific user document from 'users' collection in firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  // main widget that constructs the screen's content based on data
  Widget _buildContent(
    BuildContext context,
    String firstName,
    String? photoURL,
    List<TravelPlan> allPlans, // list of processed travel plan objects
  ) {
    TravelPlan? upcomingPlan; // to store the determined upcoming plan
    if (allPlans.isNotEmpty) {
      // filter plans to find those starting today or in the future
      List<TravelPlan> futurePlans =
          allPlans.where((plan) {
            if (plan.dates.isEmpty) return false; // can't determine if no dates
            DateTime planStartDate = plan.dates.first.toDate();
            DateTime today = DateTime.now();
            DateTime todayStart = DateTime(today.year, today.month, today.day);
            return !planStartDate.isBefore(
              todayStart,
            ); // true if start date is today or later
          }).toList();

      if (futurePlans.isNotEmpty) {
        // sort future plans to get the earliest one first
        futurePlans.sort((a, b) => a.dates.first.compareTo(b.dates.first));
        upcomingPlan = futurePlans.first; // this is our next upcoming plan
      }
    }

    // overall screen layout: fixed header, then scrollable content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // non-scrollable header part
        _GreetingHeader(firstName: firstName, photoURL: photoURL),
        // scrollable part
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // section for the single upcoming plan card
                _UpcomingPlanSection(
                  upcomingPlan: upcomingPlan,
                  formatDateRange:
                      _formatDateRange, // pass down the date formatting function
                  placeholderImageUrl:
                      placeholderImageUrl, // pass down the placeholder
                ),
                const SizedBox(height: 28),
                // section for the list of all plans
                _AllPlansSection(
                  allPlans: allPlans,
                  formatDateRange: _formatDateRange, // pass down date formatter
                  placeholderAvatarUrl:
                      placeholderAvatarUrl, // pass down avatar placeholder
                  // pass down the function that builds the 'no plans' message
                  buildNoPlansWidget:
                      ({String message = 'No travel plans yet. Add one!'}) =>
                          _buildNoPlansWidget(message: message),
                ),
                const SizedBox(
                  height: 100,
                ), // ensures content can scroll above bottom nav bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  // main entry point for building this screen
  @override
  Widget build(BuildContext context) {
    // get current authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;
    // access the travelplanprovider for data logic
    // listen: false here because we are primarily using it to get a stream or call methods,
    // not reacting to its direct state changes in this specific build method.
    // the streambuilder below will handle reacting to data changes.
    final travelPlanProvider = Provider.of<TravelPlanProvider>(
      context,
      listen: false,
    );

    // if no user is logged in, show a prompt
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text("Please log in", style: GoogleFonts.poppins()),
        ),
      );
    }

    // main scaffold for the screen
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ensure content is within visible screen area
        bottom:
            false, // allow content to go behind a potential floating bottom nav bar
        // streambuilder listens to real-time updates for travel plans
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
          stream:
              travelPlanProvider
                  .travelplan, // this stream comes from the provider
          builder: (context, planSnapshot) {
            // builder function re-runs when stream emits new data
            // show loading indicator only on initial connection if no data yet
            if (planSnapshot.connectionState == ConnectionState.waiting &&
                !planSnapshot.hasData) {
              return _buildLoadingIndicator();
            }
            // log errors from the plan stream but try to continue
            if (planSnapshot.hasError) {
              print('plan stream error: ${planSnapshot.error}');
            }
            // handle case where stream might be null or has no data yet (e.g., user logs out)
            // this check is important to prevent errors if currentuser becomes null mid-operation
            if (!planSnapshot.hasData || planSnapshot.data == null) {
              if (FirebaseAuth.instance.currentUser == null) {
                // double check user status
                return Center(
                  child: Text(
                    "user session lost.",
                    style: GoogleFonts.poppins(),
                  ),
                );
              }
              // if stream is just empty but user still logged in, futurebuilder below will handle it
            }

            // futurebuilder fetches user-specific data (like first name) once
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _fetchUserData(
                currentUser.uid,
              ), // call to get user document from firestore
              builder: (context, userSnapshot) {
                // builder re-runs when future completes
                // show loading while user data is being fetched
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }
                // if fetching user data fails, show an error (this is a more critical error)
                if (userSnapshot.hasError) {
                  print('user data fetch error: ${userSnapshot.error}');
                  return _buildErrorWidget('could not load user details.');
                }

                // ---- data processing stage ----
                String firstName = 'User'; // default name
                String? photoURL =
                    currentUser.photoURL; // get photo from auth user data

                // if user document exists in firestore, get first name
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data(); // firestore data map
                  firstName =
                      userData?['fname'] as String? ??
                      'User'; // safely get 'fname'
                  // photoURL = userData?['photoURL'] as String? ?? photoURL; // optionally get photo from firestore too
                } else {
                  // log if user document wasn't found but proceed with defaults
                  print('user document not found for uid: ${currentUser.uid}');
                }

                // process travel plans from the stream data
                List<TravelPlan> allPlans = []; // initialize empty list
                if (planSnapshot.hasData && planSnapshot.data != null) {
                  // ensure stream data is available
                  allPlans =
                      planSnapshot.data!.docs
                          .map((doc) {
                            // iterate over firestore documents
                            final data = doc.data(); // get data from document
                            if (data == null)
                              return null; // safety for null document data
                            data['id'] =
                                doc.id; // IMPORTANT: add firestore document id into the map
                            try {
                              // convert firestore map data to a structured travelplan object
                              return TravelPlan.fromJson(data);
                            } catch (e) {
                              // log any errors during parsing and skip this faulty plan
                              print(
                                "error parsing travelplan from firestore: $e, data: $data",
                              );
                              return null;
                            }
                          })
                          .whereType<TravelPlan>()
                          .toList(); // filter out any nulls from parsing errors
                }

                // log if displaying content despite a plan stream error (for debugging)
                if (planSnapshot.hasError) {
                  print(
                    "displaying content despite plan stream error: ${planSnapshot.error}",
                  );
                }

                // all data (user info, plans) is ready, build the main content ui
                return _buildContent(context, firstName, photoURL, allPlans);
              },
            );
          },
        ),
      ),
    );
  }
}

// --- widget for the fixed header (greeting and search) ---
class _GreetingHeader extends StatelessWidget {
  final String firstName;
  final String? photoURL;

  const _GreetingHeader({required this.firstName, this.photoURL});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 15.0, 18.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user greeting and avatar
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
                backgroundImage:
                    (photoURL != null && photoURL!.isNotEmpty)
                        ? NetworkImage(photoURL!)
                        : null,
                child:
                    (photoURL == null || photoURL!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // search input field
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
    );
  }
}

// --- widget for the upcoming plan section (header and card) ---
class _UpcomingPlanSection extends StatelessWidget {
  final TravelPlan? upcomingPlan; // can be null if no upcoming plans
  final String Function(List<Timestamp>?)
  formatDateRange; // function for date formatting
  final String placeholderImageUrl; // fallback image url

  const _UpcomingPlanSection({
    this.upcomingPlan,
    required this.formatDateRange,
    required this.placeholderImageUrl,
  });

  // builds the actual card for the upcoming plan
  Widget _buildCard() {
    final String defaultImage = placeholderImageUrl;

    if (upcomingPlan == null) {
      // if no plan, show placeholder
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

    // determine image to display: plan's image or default
    final String imageUrlToDisplay =
        upcomingPlan!.imageUrl ?? defaultImage; // upcomingPlan is not null here

    // card with rounded corners and image background
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrlToDisplay),
            fit: BoxFit.cover,
            onError:
                (exception, stackTrace) =>
                    print('error loading upcoming plan image: $exception'),
          ),
          color: Colors.grey.shade300, // fallback bg if image fails
        ),
        // stack for overlaying text/avatars on the image
        child: Stack(
          children: [
            // bottom gradient for text readability
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
            // plan title and date text
            Positioned(
              left: 16,
              bottom: 16,
              right: 80, // positioned to avoid avatar overlap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    upcomingPlan!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
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
                    formatDateRange(
                      upcomingPlan!.dates,
                    ), // use passed formatter
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      shadows: [
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
            // placeholder participant avatars
            Positioned(
              bottom: 18,
              right: 16,
              child: Row(
                children:
                    List.generate(
                      3,
                      (index) => Align(
                        widthFactor: 0.65, // for overlapping effect
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white, // white border
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
                    ).reversed.toList(), // reversed for correct visual stacking
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Travel Plan",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(221, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(), // build the actual card
      ],
    );
  }
}

// --- widget for the "all plans" list section ---
class _AllPlansSection extends StatelessWidget {
  final List<TravelPlan> allPlans;
  final String Function(List<Timestamp>?) formatDateRange;
  final String placeholderAvatarUrl;
  final Widget Function({String message})
  buildNoPlansWidget; // function to build 'no plans' ui

  const _AllPlansSection({
    required this.allPlans,
    required this.formatDateRange,
    required this.placeholderAvatarUrl,
    required this.buildNoPlansWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "All Travel Plans",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(221, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 10),
        // either show 'no plans' message or the list of plans
        allPlans.isEmpty
            ? buildNoPlansWidget(
              message: "You have no travel plans yet.",
            ) // call passed builder function
            : ListView.builder(
              shrinkWrap:
                  true, // essential for listview inside singlechildscrollview
              physics:
                  const NeverScrollableScrollPhysics(), // disable internal scrolling of listview
              itemCount: allPlans.length,
              itemBuilder: (context, index) {
                final plan = allPlans[index];
                // each item in the list is a travelplanitem widget
                return TravelPlanItem(
                  title: plan.name,
                  date: formatDateRange(plan.dates), // use passed formatter
                  imageUrl:
                      plan.imageUrl ??
                      placeholderAvatarUrl, // fallback to placeholder
                  plan: plan,
                );
              },
            ),
      ],
    );
  }
}

// --- widget for displaying a single travel plan item in the list ---
class TravelPlanItem extends StatelessWidget {
  final String title;
  final String date; // expects an already formatted date string
  final String imageUrl;
  final TravelPlan plan; // the specific plan data for this item

  const TravelPlanItem({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.plan,
  });

  // shows the bottom sheet with options (share, edit, delete) for this item
  void _showOptionsBottomSheet(
    BuildContext context,
    TravelPlan planToShowOptionsFor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows sheet to size by content
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        // bc is the bottom sheet's own context
        return Wrap(
          // wrap content to prevent sheet from taking full height
          children: <Widget>[
            // optional visual drag handle
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
            // share option
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey.shade700),
              title: Text('Share', style: GoogleFonts.poppins(fontSize: 15)),
              onTap: () {
                Navigator.pop(bc); // close sheet using its context
                // todo: implement share functionality
                print('share tapped for plan: ${planToShowOptionsFor.id}');
              },
            ),
            // edit option
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Colors.grey.shade700),
              title: Text('Edit', style: GoogleFonts.poppins(fontSize: 15)),
              onTap: () {
                Navigator.pop(bc); // close sheet
                // todo: implement edit functionality (e.g., navigate to edit screen)
                print('edit tapped for plan: ${planToShowOptionsFor.id}');
              },
            ),
            // delete option
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
                // async because of dialog and delete call
                Navigator.pop(bc); // close bottom sheet before showing dialog

                // show confirmation dialog to prevent accidental deletion
                bool? confirmDelete = await showDialog<bool>(
                  context: context, // use the item's context for the dialog
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Text(
                        'Delete Plan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete "${planToShowOptionsFor.name}"?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          onPressed:
                              () => Navigator.of(
                                dialogContext,
                              ).pop(false), // return false (cancelled)
                        ),
                        TextButton(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          onPressed:
                              () => Navigator.of(
                                dialogContext,
                              ).pop(true), // return true (confirmed)
                        ),
                      ],
                    );
                  },
                );

                // proceed with deletion only if user confirmed in dialog
                if (confirmDelete == true) {
                  final String? planId =
                      planToShowOptionsFor
                          .id; // plan id should be non-null here
                  if (planId == null || planId.isEmpty) {
                    // safety check for plan id, though it should always be present
                    print('error: plan id is null or empty, cannot delete.');
                    if (context.mounted) {
                      // check if widget is still in tree before showing snackbar
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
                    return; // stop if no valid id
                  }
                  try {
                    // call the deleteplan method from the provider
                    // listen: false is important when calling methods that don't need to trigger a rebuild of this specific widget
                    await Provider.of<TravelPlanProvider>(
                      context,
                      listen: false,
                    ).deletePlan(planId);
                    if (context.mounted) {
                      // show success message
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
                    // handle any errors during deletion
                    print(
                      'error deleting plan ui: ${planToShowOptionsFor.id} - $e',
                    );
                    if (context.mounted) {
                      // show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'failed to delete: ${e.toString().replaceFirst("Exception: ", "")}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } else {
                  // log if user cancelled the deletion
                  print(
                    'delete cancelled for plan: ${planToShowOptionsFor.id}',
                  );
                }
              },
            ),
            // padding at the bottom to ensure content visible above system ui/keyboard
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(bc).viewInsets.bottom +
                    MediaQuery.of(bc).padding.bottom,
              ),
            ),
            const SizedBox(height: 10), // small buffer
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // list tile for displaying the plan item
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
      ), // spacing between items
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 8.0,
        ),
        leading: ClipRRect(
          // plan image, rounded
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            // show placeholder on image load error
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
            // show loading indicator while image loads
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // image loaded
              return Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        trailing: IconButton(
          // more options button
          icon: Icon(Icons.more_horiz, color: Colors.grey.shade500),
          onPressed:
              () => _showOptionsBottomSheet(
                context,
                plan,
              ), // trigger bottom sheet
          splashRadius: 20,
          tooltip: 'more options',
        ),
        onTap: () {
          /* todo: implement navigation to plan details page */
          print('tapped on plan item: ${plan.id}');
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
