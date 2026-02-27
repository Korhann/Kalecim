import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:kiralik_kaleci/loginpage.dart";
import "package:kiralik_kaleci/signuppage.dart";

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool showLoginPage = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        _syncUserEmailWithFirestore(user);
      }
    });
  }

  Future<void> _syncUserEmailWithFirestore(User user) async {
    try {
      // Get current Firestore data
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        String firestoreEmail = userData['email'] ?? '';
        
        // If emails don't match, update Firestore
        if (firestoreEmail != user.email) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({
            'email': user.email,
          });
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email başarıyla güncellendi: ${user.email}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error syncing email with Firestore: $e');
    }
  }

  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LogIn();
    } else{
      return SignUp();
    }
  }
}