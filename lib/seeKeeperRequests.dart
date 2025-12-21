import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/apptRequest.dart';
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
              return GigsEmpty();
            }

            final gigs = snapshot.data!.docs;
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
              body: ListView.builder(
                itemCount: gigs.length,
                itemBuilder: (context, index) {
                  final gigData = gigs[index].data() as Map<String, dynamic>;
                  final day = gigData['userGig']['day'];
                  final district = gigData['userGig']['district'];
                  final field = gigData['userGig']['field'];
                  final hour = gigData['userGig']['hour'];
                  final name = gigData['userGig']['name'];
                  final price = gigData['userGig']['price'];
                  final province = gigData['userGig']['province'];
                  final gigOwner = gigData['userGig']['gigOwner'];

                  return GigView(day: day, district: district, field: field, hour: hour, name: name, price: price, province: province, gigOwner: gigOwner, gigId: gigs[index].id);
                },
              ),
            );
          }
        ),
    );
  }

  Stream<QuerySnapshot> gigStream() {
    return _firestore.collectionGroup('userGig').snapshots();
  }
}

class GigView extends StatelessWidget {
  final String day;
  final String district;
  final String field;
  final String hour;
  final String name;
  final String price;
  final String province;
  final String gigOwner;
  final String gigId;
  const GigView({
    super.key,
    required this.day,
    required this.district,
    required this.field,
    required this.hour,
    required this.name,
    required this.price,
    required this.province,
    required this.gigOwner,
    required this.gigId
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_soccer, color: Colors.blueGrey, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    field,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$price ₺',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  day,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(width: 18),
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  hour,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                const SizedBox(width: 6),
                Text(
                  '$province, $district',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.grey[350],
                    child: GestureDetector(
                      onTap: () {
                        // print(gigId);
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ApptRequest(
                            sellerUid: gigOwner,
                            selectedDay: day,
                            selectedHour: hour,
                            selectedField: field, 
                            selectedPrice: int.tryParse(price)!,
                            whereFrom: 'fromKeeperRequests',
                            gigId: gigId,
                          )
                          )
                        );
                      },
                      child: const Icon(Icons.arrow_forward, size: 24),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GigsEmpty extends StatelessWidget {
  const GigsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Henüz bir kaleci talebi bulunmamaktadır',
              style: GoogleFonts.poppins(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
