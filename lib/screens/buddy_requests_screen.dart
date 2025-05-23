import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/api/user_profile_api.dart';
import 'package:project_TUKLAS/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

// dummy model lang, to be replaced
class UserRequest {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;

  UserRequest({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });
}

class BuddyRequestsScreen extends StatefulWidget {
  static const routeName = '/buddy-requests';

  const BuddyRequestsScreen({super.key});

  @override
  State<BuddyRequestsScreen> createState() => _BuddyRequestsScreenState();
}

class _BuddyRequestsScreenState extends State<BuddyRequestsScreen> {
  final FirebaseUserProfileApi _userApi = FirebaseUserProfileApi();
  List<UserRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final requests = await _userApi.getBuddyRequests(currentUserId);
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  ImageProvider _getImageProvider(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }
    return const AssetImage('assets/images/default_avatar.png');
  }

  Widget _buildNoRequestsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No pending requests.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Buddy Requests", // Screen Title
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
          Expanded(
            child:
                _requests.isEmpty
                    ? _buildNoRequestsWidget()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 0,
                      ),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return _RequestListItem(
                          userRequest: request,
                          onAccept: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Accepted @${request.username}'),
                              ),
                            );
                            await context.read<UserProfileProvider>().processRequest(request.id, true);
                            setState(() {
                              _requests.removeAt(
                                index,
                              ); // Example: remove from list
                            });
                          },
                          onDecline: () async {
                            // Placeholder for decline logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Declined @${request.username}'),
                              ),
                            );

                            await context.read<UserProfileProvider>().processRequest(request.id, false);

                            setState(() {
                              _requests.removeAt(
                                index,
                              ); // Example: remove from list
                            });
                          },
                          getImageProvider: _getImageProvider,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _RequestListItem extends StatelessWidget {
  final UserRequest userRequest;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final ImageProvider Function(String?) getImageProvider;

  const _RequestListItem({
    required this.userRequest,
    required this.onAccept,
    required this.onDecline,
    required this.getImageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: getImageProvider(userRequest.avatarUrl),
            backgroundColor: Colors.grey[200],
            child:
                userRequest.avatarUrl == null
                    ? Icon(Icons.person, size: 30, color: Colors.grey[400])
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '@${userRequest.username}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              "Accept",
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
              minimumSize: const Size(0, 34),
            ),
            onPressed: onAccept,
          ),
          const SizedBox(width: 0),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600], size: 22),
            onPressed: onDecline,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            tooltip: 'Decline Request',
          ),
        ],
      ),
    );
  }
}
