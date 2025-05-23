import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';

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
    // Load current profile and calculate similar users when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserProfileProvider>();
      provider.loadCurrentUserProfile().then((_) {
        provider.calculateAndSetSimilarUsers();
      });
    });
  }

  ImageProvider _getImageProvider(String? imageBase64) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(imageBase64));
      } catch (e) {
        print("Error decoding base64 image: $e");
        // Fallback to a default asset image if decoding fails
        return const AssetImage(
          'assets/images/default_avatar.png',
        ); // Ensure you have this asset
      }
    }
    // Fallback for null or empty base64 string
    return const AssetImage(
      'assets/images/default_avatar.png',
    ); // Ensure you have this asset
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Similar People')),
      body: StreamBuilder(
        // Listen to user profile stream for real-time updates
        stream: context.read<UserProfileProvider>().userProfileStream,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileSnapshot.hasError) {
            return Center(child: Text('Error: ${profileSnapshot.error}'));
          }

          // When profile changes, recalculate similar users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserProfileProvider>().calculateAndSetSimilarUsers();
          });

          return Consumer<UserProfileProvider>(
            builder: (context, provider, child) {
              final similarUsers = provider.similarUsers;
              final currentProfile = provider.currentUserProfile;

              if (currentProfile == null) {
                return const Center(
                  child: Text('Could not load your profile. Please try again.'),
                );
              }

              if (similarUsers.isEmpty) {
                return const Center(child: Text('No similar users found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: similarUsers.length,
                itemBuilder: (ctx, index) {
                  final matchedUser = similarUsers[index];
                  final user = matchedUser.user;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: _getImageProvider(user.imageBase64),
                        child:
                            user.imageBase64 == null ||
                                    user.imageBase64!.isEmpty
                                ? const Icon(Icons.person, size: 30)
                                : null,
                      ),
                      title: Text(
                        user.name.isNotEmpty ? user.name : user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Match Score: ${matchedUser.matchCount}\n'
                        'Interests: ${user.interests?.take(3).join(", ") ?? "N/A"}${(user.interests?.length ?? 0) > 3 ? "..." : ""}\n'
                        'Styles: ${user.styles?.take(3).join(", ") ?? "N/A"}${(user.styles?.length ?? 0) > 3 ? "..." : ""}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                        onPressed: () {
                          print(
                            'Viewing profile of ${user.username} (UID: ${user.uid})',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tapped on ${user.name}')),
                          );
                        },
                        child: const Text('View'),
                      ),
                      onTap: () {
                        print('Tapped on ListTile for ${user.username}');
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
