import 'package:firebase_storage/firebase_storage.dart';

class StorageApi {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Upload the picked image to Firebase Storage, referencing the user's username
  Future<String> uploadImage(dynamic imageFile, String username) async {
    if (imageFile == null) {
      return 'No image file provided';
    }
    try {
      String fileName =
          '$username/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = storage.ref().child(
        fileName,
      ); // reference to Firebase Storage using the user's username

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("Image uploaded successfully. Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return 'Error uploading image: $e';
    }
  }
}
