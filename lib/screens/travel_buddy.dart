import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_TUKLAS/api/user_profile_api.dart';
import 'package:project_TUKLAS/screens/buddy_requests_screen.dart';
import 'package:project_TUKLAS/screens/user_profile.dart';
import 'package:provider/provider.dart';
import '../models/travel_buddy_model.dart';
import '../providers/travel_plan_provider.dart';

class TravelBuddyScreen extends StatefulWidget {
  const TravelBuddyScreen({super.key});

  @override
  State<TravelBuddyScreen> createState() => _TravelBuddyScreenState();
}

class _TravelBuddyScreenState extends State<TravelBuddyScreen> {
  final FirebaseUserProfileApi _userApi = FirebaseUserProfileApi();
  List<UserRequest> _buddies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTravelBuddies();
  }

  Future<void> _loadTravelBuddies() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final fetchedBuddies = await _userApi.getTravelBuddies(uid);
      setState(() {
        _buddies = fetchedBuddies;
        _isLoading = false;
      });
    } catch (e) {
      // handle errors
      setState(() {
        _buddies = [];
        _isLoading = false;
      });
    }
  }
  
  // method to change greeting depending on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 18) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
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

  Widget _buildNoBuddiesWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            "No travel buddies yet.",
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

  Widget _buildHeader(BuildContext context, String fullName, String? photoURL) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
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
                      (context) =>
                          UserProfilePage(username: 'your_username_here'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final travelPlanProvider = Provider.of<TravelPlanProvider>(
      context,
      listen: false,
    );
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
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: travelPlanProvider.fetchUserData(currentUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF14645B)),
              );
            }

            if (userSnapshot.hasError) {
              return Center(
                child: Text(
                  'Could not load user details.',
                  style: GoogleFonts.poppins(color: Colors.red.shade800),
                ),
              );
            }

            final firstName = _getFirstName(userSnapshot);
            final photoURL = currentUser.photoURL;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, firstName, photoURL),
                  // Search Bar
                  TextField(
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF14645B),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Travel Buddies",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.people_outline_rounded,
                          size: 18,
                        ),
                        label: Text(
                          "Requests",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCA4A0C),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuddyRequestsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child:
                        _buddies.isEmpty
                            ? _buildNoBuddiesWidget()
                            : ListView.builder(
                              itemCount: _buddies.length,
                              itemBuilder: (context, index) {
                                final buddy = _buddies[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: buddy.avatarUrl != null && buddy.avatarUrl!.isNotEmpty
                                        ? NetworkImage(buddy.avatarUrl!)
                                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  ),
                                  title: Text('@${buddy.username}'),
                                );
                              }
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TravelBuddyItem extends StatelessWidget {
  final TravelBuddy buddy;

  const TravelBuddyItem({super.key, required this.buddy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Clicked details for ${buddy.name}.')),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  Colors
                      .grey
                      .shade300, //buddy.avatarUrl != null ? Colors.transparent : Colors.grey.shade300,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buddy.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    buddy.username,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF14645B)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('More options for ${buddy.name}.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
