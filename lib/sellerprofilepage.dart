import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/addFields.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/earnings.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/settingsMenu.dart';
import 'package:kiralik_kaleci/selleribanpage.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/userorseller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {

  // kullanıcı bilgierli
  String? fullName;
  String? email;
  String? iban;

  int toggleIndex = 1; // Ensure the toggle switch is at the second index

  //final String currentuser = FirebaseAuth.instance.currentUser!.uid;
  Map<String,dynamic> sellerDetails = {};
  @override
  void initState() {
    super.initState();
    printAppVersion();
    getUserDetails();
    saveUserType('seller');
    PushHelper.updateOneSignal();
    userorseller = true;
    
  }

  Future<void> printAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  if (info.version.toString() != '2.0') {
    Showalert(context: context, text: 'En iyi özelliklerden faydalanmak için lütfen güncelleme yapın').showUpgradeAlert();
  }
}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height*0.030),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: UserNameHeaderText(),
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
                      icon: GlobalStyles.iconStyle(context: context, icon: Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
              SizedBox(height: height*0.030),
              BeSellerOrUser(),
              
              SizedBox(height: height*0.030),

              // kullanıcı hesap bilgileri
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GlobalStyles.textStyle(text: 'Hesap', context: context, size: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 10),
              UserName(),

              Container(
                height: 1,
                color: sellerwhite,
              ),

              Email(),
              SizedBox(height: height*0.030),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GlobalStyles.textStyle(text: 'Ödeme', context: context, size: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),

              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerIbanPage())
                  );
                },
                child: Stack(
                    children: [
                      Container(
                      height: height * 0.080,
                      width: double.infinity,
                      color: sellergrey,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlobalStyles.textStyle(text: 'Iban No', context: context, size: 22, fontWeight: FontWeight.w500, color: Colors.white),
                            _getIbanNo()
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 20,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: width*0.06,
                      ),
                    )
                    ],
                  ),
              ),
                Container(
                  height: 1,
                  color: Colors.white,
                ),

                // Kazançlarım sayfası(fiverr daki gibi)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EarningsPage())
                    );
                  },
                  child: OtherBars(
                    text: 'Kazançlarım',
                    icon: Icons.forward,
                    iconColor: Colors.white,
                  )
                ),
              SizedBox(height: height*0.030),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GlobalStyles.textStyle(text: 'Diğer', context: context, size: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsPage(whereFrom: 'fromProfile'))
                  );
                },
                child: OtherBars(
                  text: 'Randevularım',
                  icon: Icons.alarm,
                  iconColor: Colors.white
                )
              ),
              Container(
                height: 1,
                color: Colors.white,
              ),
              GestureDetector(
                onTap: () {
                  final String currentuser = FirebaseAuth.instance.currentUser!.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: currentuser, wherFrom: 'fromSomewhere'))
                  );
                },
                child: OtherBars(
                  text: 'İlanlarım',
                  icon: Icons.diamond,
                  iconColor: Colors.white,
                )
              ),
              Container(
                height: 1,
                color: Colors.white,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFields())
                  );
                },
                child: OtherBars(
                  text: 'Halı Saha Ekle',
                  icon: Icons.add,
                  iconColor: Colors.white,
                )
              ),
              SizedBox(height: height*0.060),

              SignUserOut(),

              SizedBox(height: height*0.030)
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIbanNo() {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        if (userData.containsKey('ibanDetails') && userData['ibanDetails'].isNotEmpty) {
          var ibanDetails = userData['ibanDetails'] as Map<String, dynamic>;
          // return Text(
          //   ibanDetails['ibanNo'] ?? '',
          //   style: GoogleFonts.roboto(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w400,
          //     color: Colors.white
          //   ),
          // );
          return GlobalStyles.textStyle(text: ibanDetails['ibanNo'] ?? '', context: context, size: 16, fontWeight: FontWeight.w400, color: Colors.white);
        } else {
           return GlobalStyles.textStyle(text: 'İban bilgisi yok', context: context, size: 16, fontWeight: FontWeight.w400, color: Colors.white);
        }
      },
    );
    } else {
      return SizedBox.shrink();
    }
  }
  Future<void> getUserDetails() async{
    try{
      final String currentuser = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentuser)
      .get();

      if (documentSnapshot.exists) {
        Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('sellerDetails')) {
          sellerDetails = data['sellerDetails'];
        }
      }
    }catch (e) {
      print('$e');
    }
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.080,
      width: double.infinity,
      color: sellergrey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalStyles.textStyle(text: 'Ad Soyad', context: context, size: 22, fontWeight:FontWeight.w500 , color: Colors.white),
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
        return GlobalStyles.textStyle(text: userData['fullName'] ?? '', context: context, size: 16, fontWeight: FontWeight.w400, color: Colors.white);
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
    if (currentuser != null){
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
          // return Text(userData['fullName'] ?? '',
          //     style: GoogleFonts.roboto(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white),
          //         textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
          //       );
          return GlobalStyles.textStyle(text: userData['fullName'] ?? '', context: context, size: 20, fontWeight: FontWeight.bold,color: Colors.white);
        });
    } else {
      return SizedBox.shrink();
    }
  }
}

class OtherBars extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const OtherBars({required this.text, required this.icon,this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  MediaQuery.sizeOf(context).height * 0.070,
      width: double.infinity,
      color: sellergrey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlobalStyles.textStyle(text: text, context: context, size: 22, fontWeight: FontWeight.w500, color: Colors.white),
            GlobalStyles.iconStyle(context: context, icon: icon, color: Colors.white)
          ],
        ),
      ),
    );
  }
}

class Email extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.080,
      width: double.infinity,
      color: sellergrey,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            GlobalStyles.textStyle(text: 'Email', context: context, size: 22, fontWeight: FontWeight.w500, color: Colors.white),
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
        return GlobalStyles.textStyle(text: userData['email'] ?? '', context: context, size: 16, fontWeight: FontWeight.w400, color: Colors.white);
      },
    );
    } else {
      return SizedBox.shrink();
    }
  }
}

class BeSellerOrUser extends StatefulWidget {
  const BeSellerOrUser({super.key});

  @override
  State<BeSellerOrUser> createState() => _BeSellerOrUserState();
}

class _BeSellerOrUserState extends State<BeSellerOrUser> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Container(
                color: sellergrey,
                height: height*0.070,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlobalStyles.textStyle(text: 'Kaleci Ol', context: context, size: 18, fontWeight: FontWeight.w500, color: Colors.white),
                      ToggleSwitch(
                        minWidth: width*0.25,
                        minHeight: height*0.045,
                        cornerRadius: 20.0,
                        activeBgColors: [
                          [Colors.green[800]!],
                          [Colors.red[800]!]
                        ],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: const ['Kullanıcı', 'Kaleci'],
                        radiusStyle: true,
                        onToggle: (index) async{
                          // case 0 aynı sayfada kalacak case 1 satıcı sayfasına geçecek
                          switch (index) {
                            // aynı sayfada kal
                            case 0:
                              // settings in rengini değiştirmek için(beyaz yapıyor)
                              if (await InternetConnection().hasInternetAccess) {
                                userorseller = false;
                                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MainPage(index: 2)),
                              );
                              break;
                              } else {
                                Showalert(context: context, text: 'Ooops...').showErrorAlert();
                                setState(() {
                                    index = 1;
                                  });
                              }
                            // satıcı sayfasına geç
                            case 1:
                              return;
                          }
                        },
                      ),
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
            style: ElevatedButton.styleFrom(backgroundColor: sellergrey),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Çıkış Yap",
                  style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Icon(Icons.door_back_door, size: 24, color: Colors.white)
              ],
            )),
      ),
    );
  }
}
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: sellergrey);
  }
}