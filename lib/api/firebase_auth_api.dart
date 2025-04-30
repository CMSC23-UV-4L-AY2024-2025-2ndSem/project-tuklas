import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthAPI {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> getUserStream() {
    return auth.authStateChanges();
  }

  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return 'Success!';
    } on FirebaseAuthException catch (e) {
      return "${e.code}";
    }
  }

  Future<String> signUp(
    String email,
    String password,
    String fName,
    String lName,
    String uName,
  ) async {
    try {
      UserCredential userCreds = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCreds.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fname': fName,
        'lname': lName,
        'username': uName,
        'email': email,
        'id': uid,
      });

      return 'Success!';
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
