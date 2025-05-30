import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges();
  }

  String getCurrentUserId() {
    if (auth.currentUser == null) {
      return 'User not logged in!';
    }
    return auth.currentUser!.uid;
  }

  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return 'Success!';
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> signUp(String email, String username, String password) async {
    try {
      UserCredential userCreds = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCreds.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'id': uid,
        'username': username,
      });

      return 'Success!';
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<bool> checkUsername(String username) async {
    final snapshot =
        await FirebaseFirestore
            .instance // snapshot of db with usernames similar to user input username
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

    if (snapshot.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<String?> findEmail(String username) async {
    String? email;
    await FirebaseFirestore
        .instance // snapshot of db with usernames similar to user input username
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            email = null;
          } else {
            email = querySnapshot.docs[0]['email'];
          }
        });
    return email;
  }
}
