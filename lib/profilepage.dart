import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/addFields.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/approvedfields.dart';
import 'package:kiralik_kaleci/favouritespage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/policiespage.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/settingsMenu.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/userorseller.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // veri tabanından çektiğim veriler
  String? fullName;
  String? email;
  // appointmentpage ya göndermek için
  late String sellerUid;
  late String buyerUid;

  // authentication of the user
  //final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
  String? cardNumber;
  
  @override
  void initState() {
    super.initState();
    //checkForceUpdate(context);
    try {
      saveUserType('user');
      userorseller = false;
      if (Platform.isIOS) {
        PushHelper.updateOneSignal();
      }
    } catch (e, stack) {
      reportErrorToCrashlytics(
        e,
        stack,
        reason: 'profilepage initState error',
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    double iconSize = (width * 0.06).clamp(20.0, 32.0);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.030),
                    Row(
                      children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: UserNameHeaderText()
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsMenu(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          size: iconSize,
                          color: Colors.black,
                        ),
                      )
                    ]),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.030),

                    BeSellerOrUser(),

                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.030),

                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Hesap",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // kullanıcı adı
                    UserName(),
                  
                    Container(
                      height: 1,
                      color: Colors.black,
                    ),
                  
                    // email
                    Email(),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.030),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "Diğer",
                        style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                      ),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.010),
                  
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AppointmentsPage(whereFrom: 'fromProfile'))
                      );
                      },
                      child: OtherBars(
                        text: 'Randevularım',
                        icons: Icon(Icons.alarm, size: iconSize),
                      ),
                    ),
                  
                    Container(height: 1, color: Colors.black),
                  
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FavouritesPage())
                      );
                      },
                      child: OtherBars(
                        text: 'Favorilerim',
                        icons: Icon(Icons.favorite_border,size: iconSize),
                      ),
                    ),
                  
                    Container(height: 1, color: Colors.black),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddFields())
                      );
                      },
                      child: OtherBars(
                        text: 'Halı Saha Ekle',
                        icons: Icon(Icons.add,size: iconSize),
                      ),
                    ),

                    Container(height: 1, color: Colors.black),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ApprovedFields())
                      );
                      },
                      child: OtherBars(
                        text: 'Onaylı Halı Sahalar',
                        icons: Icon(
                        Icons.location_on,size: iconSize),
                      ),
                    ),
                  
                    Container(height: 1, color: Colors.black),
                  
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PoliciesPage())
                      );
                      },
                      child: OtherBars(
                        text: 'Kalecim',
                        icons: Icon(Icons.handshake_outlined,size: iconSize),
                      ),
                    ),
                  
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.060),
                  
                    SignUserOut(),
                  
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.030)
                  ],
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  //todo: FirebaseException ([cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.)
  // Future<void> getSellerUid() async {
  //   CollectionReference collectionReference = _firestore
  //       .collection('Users')
  //       .doc(currentuser)
  //       .collection('appointmentbuyer');
  //   QuerySnapshot querySnapshot = await collectionReference.get();

  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data() as Map<String, dynamic>;

  //     String? sellerUid = data['appointmentDetails']?['selleruid'];
  //   }
  // }
}

class Email extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.sizeOf(context).height * 0.10,
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email",
              style:GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            ),
            EmailText()
          ],
        ),
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentuser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['email'] ?? '',
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
        );
      },
    );
    } else {
      return SizedBox.shrink();
    }
  }
} 

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ad Soyad",
              style:GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            ),
            UserNameText(),
          ],
        ),
      ),
    );
  }
}

class UserNameText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentuser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(userData['fullName'] ?? '',
            style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class UserNameHeaderText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentuser)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Veri bulunamadı');
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Text(userData['fullName'] ?? '',
              style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              );
        });
    } else {
      return SizedBox.shrink();
    }
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class OtherBars extends StatelessWidget {
  final String text;
  final Icon icons;

  const OtherBars({required this.text, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.070,
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            ),
            icons,
          ],
        ),
      ),
    );
  }
}


class SignUserOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return Center(
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
            onPressed: () async {
              // sign out the user
              await _auth.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Çıkış Yap",
                    style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Icon(Icons.door_back_door, size: 24, color: Colors.black)
                ],
              ),
            )),
      ),
    );
  }
}
class BeSellerOrUser extends StatefulWidget {
  @override
  State<BeSellerOrUser> createState() => _BeSellerOrUserState();
}

class _BeSellerOrUserState extends State<BeSellerOrUser> {
  @override
  Widget build(BuildContext context) {

    final double screenWidth = MediaQuery.of(context).size.width;
final double screenHeight = MediaQuery.of(context).size.height;

// Responsive toggle width and height
final double toggleWidth = (screenWidth * 0.25).clamp(120.0, 220.0);
final double toggleHeight = (screenHeight * 0.045).clamp(32.0, 48.0);

// Responsive badge size and font
final double badgeSize = (toggleHeight * 0.6).clamp(14.0, 22.0);
final double badgeFontSize = (badgeSize * 0.65).clamp(10.0, 14.0);

// Responsive badge position
final double badgeRight = (toggleWidth * 0.1).clamp(8.0, 20.0);
final double badgeTop = (-badgeSize * 0.45).clamp(-16.0, -6.0);

    return Container(
      color: Colors.white,
      height: MediaQuery.sizeOf(context).height * 0.070,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Kaleci Ol",
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500,),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ToggleSwitch(
                  minHeight: toggleHeight,
                  minWidth: toggleWidth,
                  cornerRadius: 20.0,
                  activeBgColors: [
                    [Colors.green[800]!],
                    [Colors.red[800]!]
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: const ['Kullanıcı', 'Kaleci'],
                  radiusStyle: true,
                  onToggle: (index) async {
                    switch (index) {
                      case 0:
                        return;
                      case 1:
                        try {
                          if (await InternetConnection().hasInternetAccess) {
                            userorseller = true;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SellerMainPage(index: 2,)
                              )
                            );
                            break;
                          } else {
                            Showalert(context: context, text: 'Ooops...').showErrorAlert();
                            setState(() {
                              index = 0;
                            });
                          }
                        } catch (e, stack) {
                          await reportErrorToCrashlytics(
                            e,
                            stack,
                            reason: 'profilepage BeSellerOrUser onToggle error',
                          );
                        }
                    }
                  },
                ),
                // Badge overlay for "Kaleci"
                Positioned(
                  right: badgeRight,
                  top: badgeTop,
                  child: StreamBuilder<int>(
                    stream: getUnreadCount(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == 0) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: badgeSize,
                          minHeight: badgeSize,
                        ),
                        child: Text(
                          '${snapshot.data}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
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

