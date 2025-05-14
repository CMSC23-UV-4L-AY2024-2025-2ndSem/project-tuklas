import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_profile.dart';

class TravelBuddyScreen extends StatefulWidget {
  const TravelBuddyScreen({super.key});

  @override
  State<TravelBuddyScreen> createState() => _TravelBuddyScreenState();
}

class _TravelBuddyScreenState extends State<TravelBuddyScreen> {
  final List<Map<String, String>> buddies = [
    {
      'name': 'Aliyah Gabrielle',
      'username': '@gab',
      'photoUrl': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'King Dela Cruz',
      'username': '@king',
      'photoUrl': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Paulene Aguilar',
      'username': '@pau',
      'photoUrl': 'https://i.pravatar.cc/150?img=3',
    },
  ];

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  void _showOptionsBottomSheet(BuildContext context, String buddyName) async {
    final confirmDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text('Share', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(context, false),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text('Edit', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(context, false),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        buddies.removeWhere((buddy) => buddy['name'] == buddyName);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"$buddyName" deleted.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildContent(
    BuildContext context,
    String firstName,
    String? photoURL,
    List<Map<String, String>> allBuddies,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                  GestureDetector(
                    onTap: () {
                      // Navigate to the UserProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(username: 'your_username_here'), // Pass the username or any identifier
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
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Search travel buddies...',
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Travel Buddies',
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Request feature not implemented yet."),
                        ),
                      );
                    },
                    icon: Icon(Icons.person_add_alt_1, size: 20, color: Color(0xFF14645B)),
                    label: Text(
                      "Request",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF14645B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: allBuddies.length,
                  itemBuilder: (context, index) {
                    final buddy = allBuddies[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(buddy['photoUrl']!),
                        ),
                        title: Text(
                          buddy['name']!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          buddy['username']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                          onPressed: () => _showOptionsBottomSheet(context, buddy['name']!),
                          splashRadius: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not signed in")),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _fetchUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: \${snapshot.error}')),
          );
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User data not found")),
          );
        }

        final userData = snapshot.data!.data()!;
        final firstName = userData['firstName'] ?? 'User';
        final photoURL = userData['photoURL'];

        return _buildContent(context, firstName, photoURL, buddies);
      },
    );
  }
}

