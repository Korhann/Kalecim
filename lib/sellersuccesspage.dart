import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SellerSuccessPage extends StatefulWidget {
  const SellerSuccessPage({super.key});

  @override
  State<SellerSuccessPage> createState() => _SellerSuccessPageState();
}

class _SellerSuccessPageState extends State<SellerSuccessPage> {

  List<Map<String,dynamic>> userDetails = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    runMethods();
  }

  void runMethods() async {
    await _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

  if (currentUserUid != null && currentUserUid.isNotEmpty) {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserUid)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];

        if (!mounted) return; // important check

        QuickAlert.show(
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // close the alert first
            navigate(sellerDetails, currentUserUid);
          },
          context: context,
          title: 'Başarılı',
          text: 'İlanınız yüklenmiştir',
          type: QuickAlertType.success,
          textColor: Colors.white,
          backgroundColor: sellergrey,
          confirmBtnText: 'Tamam',
          titleColor: Colors.white,
        );
      }
    }
  }
}

  void navigate(Map<String,dynamic> details, String user) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SellerDetailsPage(sellerDetails: details, sellerUid: user, wherFrom: 'fromSuccess')));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
    );
  }
}