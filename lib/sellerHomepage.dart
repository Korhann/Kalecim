import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/earnings.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {

  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  Map<String,dynamic> sellerDetails = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sellerbackground,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: GlobalStyles.textStyle(text: 'Satıcı Ana Sayfa', context: context, size: 20, fontWeight: FontWeight.w700, color: Colors.white)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height*0.030),
                SellerQuickMenus(text: 'İlan Ekle/Düzenle', ontap: () => _navigateToPage('sellerAdd'), icon: Icons.add),
                const SizedBox(height: 10),
                NoOfAppointments(onTap: () => _navigateToPage('appointments')),
                const SizedBox(height: 10),
                SellerQuickMenus(text: 'İlanlarım', ontap: () => _navigateToPage('posts'), icon: Icons.diamond),
                const SizedBox(height: 10),
                SellerQuickMenus(text: 'Kazançlarım', ontap: () => _navigateToPage('earnings'), icon: Icons.attach_money)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(String menuOption) async {
    Widget page;
    switch (menuOption) {
      case 'sellerAdd':
        page = const SellerAddPage();
        break;
      case 'appointments':
        page = const AppointmentsPage(whereFrom: 'fromSellerHomePage');
        break;
      case 'posts':
        page = SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: currentUser, wherFrom: 'fromSomewhere');
        break;
      case 'earnings':
        page = const EarningsPage();
        break;
      default:
        return; 
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'sellerHomepage _navigateToPage error for user $currentUser, menuOption: $menuOption',
      );
    }
  }

  Future<void> getUserDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .get();

      if (documentSnapshot.exists) {
        Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('sellerDetails')) {
          sellerDetails = data['sellerDetails'];
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'sellerHomepage getUserDetails error for user $currentUser',
      );
    }
  }
}


class SellerQuickMenus extends StatelessWidget {

  final String text;
  final VoidCallback ontap;
  final IconData icon;

  const SellerQuickMenus({required this.text, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: ontap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height*0.080,
          width: width,
          color: sellergrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GlobalStyles.textStyle(text: text, context: context, size: 18, fontWeight: FontWeight.w400, color: Colors.white),
                const Spacer(),
                GlobalStyles.iconStyle(context: context, icon: icon, color: Colors.white)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoOfAppointments extends StatelessWidget {
  final VoidCallback onTap;

  const NoOfAppointments({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: height*0.080,
          width: width,
          color: sellergrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GlobalStyles.textStyle(text: 'Randevularım', context: context, size: 18, fontWeight: FontWeight.w400, color: Colors.white),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GlobalStyles.iconStyle(context: context, icon: Icons.notifications, color: Colors.white),
                    StreamBuilder<int>(
                      stream: getUnreadCount(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == 0) return SizedBox();
                        return Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<int> getUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .collection('appointmentseller')
        .where('appointmentDetails.status', isEqualTo: 'pending')
        .where('appointmentDetails.isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}


