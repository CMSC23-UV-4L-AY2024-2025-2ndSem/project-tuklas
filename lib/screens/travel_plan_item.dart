// --- widget for displaying a single travel plan item in the list ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_TUKLAS/models/travel_plan_model.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/itinerary.dart';
import 'package:project_TUKLAS/screens/shareqr_page.dart';
import 'package:provider/provider.dart';

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

  // method to show the options bottom sheet
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
                Navigator.pop(context); // close the bottom sheet
                // TO DO: implement share functionality
                print('Share tapped for plan: ${planToShowOptionsFor.id}');
                // navigate to generate QR page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GenerateQrPage(
                          travelPlanId: planToShowOptionsFor.id,
                        ),
                  ),
                );
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
                    // access the provider to call the delete method
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final message = await Provider.of<TravelPlanProvider>(
                      context,
                      listen: false,
                    ).deletePlan(planId, currentUser!.uid);

                    if (context.mounted) {
                      // show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '"${planToShowOptionsFor.name}": $message',
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
              if (loadingProgress == null) {
                return child; // return image if loaded
              }
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItineraryScreen(travelPlan: plan),
            ),
          );
        },
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
