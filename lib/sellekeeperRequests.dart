import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'shimmers.dart';

class seeUsersKeeperRequests extends StatefulWidget {
  const seeUsersKeeperRequests({super.key});

  @override
  State<seeUsersKeeperRequests> createState() => _seeUsersKeeperRequestsState();
}

class _seeUsersKeeperRequestsState extends State<seeUsersKeeperRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return ConnectivityWithBackButton(
      child: StreamBuilder<QuerySnapshot>(
          stream: gigStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.only(top: 40),
                child: KeeperRequestsShimmer(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              GigsEmpty();
            }
            final docs = snapshot.data!.docs;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: GlobalStyles.textStyle(
                    text: 'Kaleci Talepleri',
                    context: context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: sellerbackground,
                centerTitle: true,
              ),
              backgroundColor: sellerbackground,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final gigDetails = docs[index].data() as Map<String,dynamic>;
                        print('gig details are $gigDetails');
                        // final day = gigDetails['userGig']['day'];
                        // final district = gigDetails['userGig']['district'];
                        // final field = gigDetails['userGig']['field'];
                        // final hour = gigDetails['userGig']['hour'];
                        // final name = gigDetails['userGig']['name'];
                        // final price = gigDetails['userGig']['price'];
                        // final province = gigDetails['userGig']['province'];
                        // final timestamp = gigDetails['userGig']['timestamp'];

                        print('length of docs ${docs.length}');
                      },
                    )
                  ],
                ),
              ),
            );
          }
        ),
    );
  }

  Stream<QuerySnapshot> gigStream() {
    return _firestore
      .collection('Users')
      .where('sellerDetails', isNotEqualTo: null)
      .snapshots();
  }
}

class GigsEmpty extends StatelessWidget {
  const GigsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Randevunuz bulunmamaktadır',
            style: GoogleFonts.poppins(
              fontSize: 26,
              color: userorseller ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
