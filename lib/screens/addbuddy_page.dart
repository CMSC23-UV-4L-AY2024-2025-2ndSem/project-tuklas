import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBuddyPage extends StatefulWidget {
  static const routeName = '/add-buddy';

  const AddBuddyPage({super.key});

  @override
  State<AddBuddyPage> createState() => _AddBuddyPageState();
}

class _AddBuddyPageState extends State<AddBuddyPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileProvider>().loadCurrentUserProfile();
  }

  ImageProvider _getImageProvider(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        String sanitizedBase64 = imageBase64;
        if (imageBase64.contains(',')) {
          sanitizedBase64 = imageBase64.split(',').last;
        }
        return MemoryImage(base64Decode(sanitizedBase64));
      } catch (e) {
        print("Error decoding base64 image: $e");
        return const AssetImage('assets/images/default_avatar.png');
      }
    }
    return const AssetImage('assets/images/default_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Add Travel Buddy",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 8.0),
            child: Text(
              'Top Travel Buddies',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: context.watch<UserProfileProvider>().userProfileStream,
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    context.read<UserProfileProvider>().currentUserProfile ==
                        null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profileSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error with profile stream: ${profileSnapshot.error}',
                    ),
                  );
                }
                return Consumer<UserProfileProvider>(
                  builder: (context, provider, child) {
                    final similarUsers = provider.similarUsers;
                    final currentProfile = provider.currentUserProfile;
                    if (provider.currentUserProfile == null &&
                        !(profileSnapshot.connectionState ==
                            ConnectionState.waiting)) {
                      return const Center(child: Text('Loading profile...'));
                    }

                    if (currentProfile == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Could not load your profile. Please try again.',
                          ),
                        ),
                      );
                    }
                    if (similarUsers.isEmpty &&
                        provider.currentUserProfile != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No similar users found.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    }
                    if (similarUsers.isEmpty &&
                        provider.currentUserProfile == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      itemCount: similarUsers.length,
                      itemBuilder: (ctx, index) {
                        final matchedUser = similarUsers[index];
                        final user = matchedUser.user;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: _getImageProvider(
                              user.imageBase64,
                            ),
                            backgroundColor: Colors.grey[200],
                            child:
                                (user.imageBase64 == null ||
                                        user.imageBase64!.isEmpty)
                                    ? Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey[400],
                                    )
                                    : null,
                          ),
                          title: Text(
                            user.name.isNotEmpty ? user.name : user.username,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '@${user.username}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              "Add",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCA4A0C),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                              minimumSize: const Size(0, 32),
                            ),
                            onPressed: () {
                              print('Add buddy: ${user.username}');
                              // implement add buddy functionality here
                            },
                          ),
                          onTap: () {
                            print('Tapped on ListTile for ${user.username}');
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
