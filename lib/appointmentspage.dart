import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/enterVerificationCode.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'globals.dart';

//todo: Saat 00:00 ı geçmiş olarak alıyor aynı gün içindeyse

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({
    super.key,
    required this.whereFrom
  });

  final String whereFrom;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();

  // randevular da haftalık olaraka silinecek
  Future<void> deleteAppointments() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String currentuser = FirebaseAuth.instance.currentUser!.uid;

    var collectionBuyer = firestore
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentbuyer');
    var collectionSeller = firestore
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentseller');
    var appointmentsBuyer = await collectionBuyer.get();
    var appointmentsSeller = await collectionSeller.get();
    for (var doc in appointmentsBuyer.docs) {
      await doc.reference.delete();
    }
    for (var doc in appointmentsSeller.docs) {
      await doc.reference.delete();
    }
  }
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> appointments = [];
  List<String>? docs;
  Color paymentColor = Colors.green;
  // notification göndermek için
  late String sellerUid;
  late String sellerDocId;

  late Future<void> fetchAppts;

  @override
  void initState() {
    super.initState();
    runMethods();
  }
  void runMethods () {
    if (widget.whereFrom == 'homePage') {
      markSeenAsTrueUser();
    } else if (widget.whereFrom == 'fromSellerHomePage') {
      markSeenAsTrueSeller();
   }
  }

  Future<void> markSeenAsTrueUser() async{
    try {
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await FirebaseFirestore.instance
    .collection('Users')
    .doc(currentuser)
    .collection('appointmentbuyer')
    .where('appointmentDetails.isSeen', isEqualTo: false)
    .get();

    for (final doc in querySnapshot.docs) {
      doc.reference.update({'appointmentDetails.isSeen':true});
    }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'appointmentspage markSeenAsTrueUser error for user $currentuser',
      );
    }
  }

  Future<void> markSeenAsTrueSeller() async{
    try {
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await FirebaseFirestore.instance
    .collection('Users')
    .doc(currentuser)
    .collection('appointmentseller')
    .where('appointmentDetails.isSeen', isEqualTo: false)
    .get();

    for (final doc in querySnapshot.docs) {
      doc.reference.update({'appointmentDetails.isSeen':true});
    }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'appointmentspage markSeenAsTrueSeller error for user $currentuser',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return ConnectivityWithBackButton(
      child: StreamBuilder<QuerySnapshot>(
        stream: appointmentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 40),
              child: AppointmentsShimmer(),
            );
          }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      apptsEmpty();
    }
    // streambuilder in result u
    final docs = snapshot.data!.docs;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            // if its a seller
            if (userorseller) {
              if (widget.whereFrom == 'fromProfile') {
                Navigator.of(context).pop();
              } else if (widget.whereFrom == 'fromNoti') {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const SellerMainPage(index: 2)),
                  ModalRoute.withName('/'),
                );
              } else if (widget.whereFrom == 'fromSellerHomePage') {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => const SellerMainPage(index: 0)),
                  ModalRoute.withName('/'),
                );
              }
              // else if the its a user
            } else {
                if (widget.whereFrom == 'fromPayment') {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext context) => const MainPage(index: 0)),
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Randevularım',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userorseller ? Colors.white : Colors.black,
                ),
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              ),
            ),
            if (userorseller == false)
              buyerStatusInfo()
            else
              sellerStatusInfo(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final appointmentDetails = docs[index].data() as Map<String, dynamic>;
                final name = appointmentDetails['appointmentDetails']['fullName'] ?? appointmentDetails['appointmentDetails']['name'];
                final surname = appointmentDetails['appointmentDetails']['surname'] ?? '';
                final day = appointmentDetails['appointmentDetails']['day'] ?? '';
                final hour = appointmentDetails['appointmentDetails']['hour'] ?? '';
                final field = appointmentDetails['appointmentDetails']['field'] ?? '';
                final status = appointmentDetails['appointmentDetails']['status'] ?? 'pending';
                final paymentStatus = appointmentDetails['appointmentDetails']['paymentStatus'] ?? 'waiting';
                final verificationCode = appointmentDetails['appointmentDetails']['verificationCode'] ?? '';
                final verificationState = appointmentDetails['appointmentDetails']['verificationState'] ?? '';
                final isPastDay = appointmentDetails['appointmentDetails']['isPastDay'] ?? 'false';
                final sellerUid = appointmentDetails['appointmentDetails']['selleruid'] ?? '';
                final startTime = appointmentDetails['appointmentDetails']['startTime'];
                final docId = docs[index].id;

                _checkIfDayIsPast(day, docId, appointmentDetails, startTime);

                Color cardColor = Colors.white;

                if (status == 'approved' && paymentStatus == 'done') {
                  cardColor = Colors.green.shade500;
                } else if (status == 'approved' && paymentStatus == 'waiting' && isPastDay == 'false') {
                  cardColor = Colors.green.shade200;
                } else if (status == 'rejected') {
                  cardColor = Colors.red.shade200;
                } else if (status == 'pending' && paymentStatus == 'waiting' && isPastDay == 'false') {
                  cardColor = Colors.orange.shade200;
                } else if (!userorseller && (paymentStatus == 'taken' || isPastDay == 'true')) {
                  cardColor = Colors.grey;
                } else if (userorseller && (isPastDay == 'true' || status != 'approved')) {
                  cardColor = Colors.grey;
                }

                return AppointmentView(
                  cardColor: cardColor,
                  name: name,
                  surname: surname,
                  day: day,
                  hour: hour,
                  field: field,
                  status: status,
                  paymentStatus: paymentStatus,
                  sellerUid: sellerUid,
                  appointmentDetails: appointmentDetails['appointmentDetails'],
                  verificationCode: verificationCode,
                  verificationState: verificationState,
                  isPastDay: isPastDay,
                  docId: docId,
                  userorseller: userorseller,
                  width: width,
                  height: height,
                  onApprove: () async {
                    await approveAppointment(docId, index);
                  },
                  onReject: () async {
                    await rejectAppointment(docId, index);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  },
)

    );
  }

  Stream<QuerySnapshot> appointmentStream() {
  return _firestore
    .collection('Users')
    .doc(currentuser)
    .collection(userorseller ? 'appointmentseller' : 'appointmentbuyer')
    .snapshots();
}

  void _checkIfDayIsPast(String day, String docId, Map<String, dynamic> appointmentDetails, String startTime) async {
  if (userorseller) {
    await CheckDaysPastSeller.isPast(day, docId, startTime);
  } else {
    await CheckDaysPastUser.isPast(day, docId, startTime);
  }
}
  
  Stream<QuerySnapshot> getAppointmentsStream() {
  return FirebaseFirestore.instance
    .collection('Users')
    .doc(currentuser)
    .collection(userorseller ? 'appointmentseller' : 'appointmentbuyer')
    .snapshots();
}

  // Updates status to 'approved'
  Future<void> approveAppointment(String docId, int index) async {
    String appointmentDetails = 'appointmentDetails';
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({'appointmentDetails.status': 'approved'});

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? appointmentData = documentSnapshot.data();
        if (appointmentData != null && appointmentData.containsKey('appointmentDetails')) {
          String buyerUid = appointmentData['appointmentDetails']['buyerUid'];
          String buyerDocId = appointmentData['appointmentDetails']['buyerDocId'];

          String hour = appointmentData[appointmentDetails]['hour'];
          String day = appointmentData[appointmentDetails]['day'];
          String field = appointmentData[appointmentDetails]['field'];

          // alıcı için status update (renkleri göstermek için - turuncu,yeşil,kırmzı)
          await _firestore
              .collection('Users')
              .doc(buyerUid)
              .collection('appointmentbuyer')
              .doc(buyerDocId)
              .update({'appointmentDetails.status': 'approved'});

          

          // alıcı ödeme yapması için bildirim gönder
          //todo: sellerUid ve sellerDocId yi göndermem lazım verification kontrolü için (manuel)
          await PushHelper.sendPushPayment(
              sellerUid: currentuser,
              buyerUid: buyerUid,
              selectedDay: day,
              selectedHour: hour,
              selectedField: field,
              buyerDocId: buyerDocId,
              sellerDocId: docId
            );
        } else {
          print('appointment details does not exist');
        }
      } else {
        print('document snapshot does not exist');
      }

      setState(() {
        appointments[index]['appointmentDetails']['status'] = 'approved';
      });
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'appointmentspage approveAppointment error for user $currentuser, docId: $docId',
      );
    }
  }

  Future<void> rejectAppointment(String docId, int index) async {
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({'appointmentDetails.status': 'rejected', 'appointmentDetails.paymentStatus': 'denied'});
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? appointmentData = documentSnapshot.data();
        if (appointmentData != null &&
            appointmentData.containsKey('appointmentDetails')) {
          String buyerUid = appointmentData['appointmentDetails']['buyerUid'];
          String buyerDocId = appointmentData['appointmentDetails']['buyerDocId'];

          // alıcı için status update (renkleri göstermek için - turuncu,yeşil,kırmzı)
          await _firestore
              .collection('Users')
              .doc(buyerUid)
              .collection('appointmentbuyer')
              .doc(buyerDocId)
              .update({'appointmentDetails.status': 'rejected'});
        } else {
          print('appointment details does not exist');
        }
      } else {
        print('document snapshot does not exist');
      }

      if (mounted) {
        setState(() {
          appointments[index]['appointmentDetails']['status'] = 'rejected';
        });
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'appointmentspage rejectAppointment error for user $currentuser, docId: $docId',
      );
    }
  }

  
  Widget buyerStatusInfo() {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Alındı',
              style: TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.red.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Reddedildi',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Beklemede',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Ödeme gerekiyor',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Geçmiş',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
          ],
        ),
      ),
    );
  }

  Widget sellerStatusInfo() {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Onaylandı',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.red.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Reddedildi',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Beklemede',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Geçmiş',
              style:TextStyle(color: userorseller ? Colors.white : Colors.black),
              textScaler: textScaler,
            ),
          ],
        ),
      ),
    );
  }
}
//todo: Bu yazıyı değiştir pazar 00:00 'da karanlık ekran ve yazı olarak gözüküyo(not: pazar gecesi 2 de halısaha oluyor kaleci ödemeyi nasıl alacak yenileniyorsa)
class apptsEmpty extends StatelessWidget {
  const apptsEmpty({super.key});

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

class AppointmentView extends StatelessWidget {
  final Color cardColor;
  final String name;
  final String surname;
  final String day;
  final String hour;
  final String field;
  final String status;
  final String paymentStatus;
  final String sellerUid;
  final Map<String, dynamic> appointmentDetails;
  final String verificationCode;
  final String verificationState;
  final String isPastDay;
  final String docId;
  final bool userorseller;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final double height;
  final double width;

  const AppointmentView({
    Key? key,
    required this.cardColor,
    required this.name,
    required this.surname,
    required this.day,
    required this.hour,
    required this.field,
    required this.status,
    required this.paymentStatus,
    required this.sellerUid,
    required this.appointmentDetails,
    required this.verificationCode,
    required this.verificationState,
    required this.isPastDay,
    required this.docId,
    required this.userorseller,
    this.onApprove,
    this.onReject,
    required this.height,
    required this.width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(10),
                title: nameSurname(name: name, surname: surname),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconDayHour(day: day, hour: hour),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: width*0.06),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            field,
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          ),
                        ),
                        const Spacer(),
                        buildRightSideWidget(context: context ,userorseller: userorseller, status: status, paymentStatus: paymentStatus, verificationCode: verificationCode, docId: docId, appointmentDetails: appointmentDetails, verificationState: verificationState, isPastDay: isPastDay, hour: hour)
                      ],
                    ),
                  ],
                ),
              ),
              if (userorseller && status == 'pending' && isPastDay == 'false')
                sellerApproveOrReject(onApprove: onApprove, onReject: onReject)
            ],
          ),
        ),
      ),
    );
  }
  Widget buildRightSideWidget({
    required BuildContext context,
    required bool userorseller,
    required String status,
    required String paymentStatus,
    required String verificationCode,
    required String verificationState,
    required String isPastDay,
    required String docId,
    required Map<String, dynamic> appointmentDetails,
    required String hour
  }) {
    final style = GoogleFonts.poppins(fontSize: 16, color: Colors.black);
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    // kullanıcı için
  if (!userorseller) {
    //todo: Kullanıcı pazartesi oynadığı maç için salı günü ödeme yapamasın(veya başlangıc saatinden sonra yapamsın)
    if (status == 'approved' && paymentStatus == 'waiting' && isPastDay == 'false') {
      return paymentButton(appointmentDetails: appointmentDetails, docId: docId);
    } else if (status == 'approved' && paymentStatus == 'done') {
      return Text(verificationCode, textScaler: textScaler);
    } else if (isPastDay == 'true' || paymentStatus == 'taken') {
      return showTextBasedOnGreyCard(isPastDay: isPastDay, paymentStatus: paymentStatus);
    } else {
      return showTextBasedOnStatus(status: status);
    }
    // kaleci için
  } else if (userorseller && verificationState == 'notVerified' && status == 'approved' && isPastDay == 'false') {
      return ElevatedButton(
        onPressed: () async{
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnterVerificationCode(docId: docId))
          );
        }, 
        child: Text('Kodu gir')
      );
    
    // todo: buraya kaleci için textleri yap ve kodu girdikten sonra hemen onaylandı olarak gözüksün
  } else if (status == 'rejected') {
    return Text('Reddedildi', style: style, textScaler: textScaler,);
  } else if (status == 'approved' && verificationState == 'verified') {
    return Text('Onaylandı', style: style, textScaler: textScaler,);
  } else if (isPastDay == 'true') {
    return Text('Geçmiş', style: style, textScaler: textScaler);
  }
  else {
    return const SizedBox();
  }
}
}
class CheckDaysPastSeller {
  static Future<void> isPast(String day, String docId, String startTime) async {
    String currentuser = FirebaseAuth.instance.currentUser!.uid;
    List<String> orderedDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    try {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final int currentDayIndex = now.weekday - 1; // Monday = 0
    final int inputDayIndex = orderedDays.indexOf(day);

    bool nightHours = isNightHour(startTime) && (currentDayIndex == inputDayIndex); 

    if (inputDayIndex == -1) {
      throw ArgumentError('Invalid day name: $day');
    }

    bool shouldMarkAsPast = false;

    if (inputDayIndex < currentDayIndex) {
      final isPastHour = isStartTimePast(now,startTime,nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
      // burada aynı gün sadece saatlere bakıp geçmiş mi diye anlıyor
    } else if (inputDayIndex == currentDayIndex && !nightHours) {
      final isPastHour = isStartTimePast(now,startTime, nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
    } else if (nightHours) {
      final isPastHour = isStartTimePast(now,startTime,nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
    }

    if (shouldMarkAsPast) {
      final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentseller')
        .doc(docId);

      final snapshot = await docRef.get();
      final buyerUid = snapshot['appointmentDetails']['buyerUid'] ?? '';
      final buyerDocId = snapshot['appointmentDetails']['buyerDocId'];

      final docRef2 = FirebaseFirestore.instance
        .collection('Users')
        .doc(buyerUid)
        .collection('appointmentbuyer')
        .doc(buyerDocId);

      final snapshot2 = await docRef2.get();

      final isPastDay = snapshot['appointmentDetails']['isPastDay'] ?? false;
      final buyerPaymentStatus = snapshot2['appointmentDetails']['paymentStatus'];

      if (isPastDay == 'false' && buyerPaymentStatus == 'waiting') {
        await docRef.update({
          'appointmentDetails.isPastDay': 'true',
        });
      }
    }
    } catch (e) {
      print('Error in CheckDaysPastSeller: $e');
    }    
  }
}

// 'waiting' olan günlerin geçdiğini gösteriyor
class CheckDaysPastUser {
  static Future<void> isPast(String day, String docId, String startTime) async{
    String currentuser = FirebaseAuth.instance.currentUser!.uid;
    List<String> orderedDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final int currentDayIndex = now.weekday - 1; // Monday is 1
    final int inputDayIndex = orderedDays.indexOf(day);

    bool nightHours = isNightHour(startTime) && (currentDayIndex == inputDayIndex); 

    if (inputDayIndex == -1) {
      throw ArgumentError('Invalid day name: $day');
    }

    bool shouldMarkAsPast = false;

    if (inputDayIndex < currentDayIndex) {
      final isPastHour = isStartTimePast(now,startTime,nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
    } else if (inputDayIndex == currentDayIndex && !nightHours) {
      final isPastHour = isStartTimePast(now,startTime,nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
    } else if (nightHours) {
      final isPastHour = isStartTimePast(now,startTime,nightHours);
      if (isPastHour) {
        shouldMarkAsPast = true;
      }
    }

    if (shouldMarkAsPast) {
      final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentbuyer')
        .doc(docId);
      
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data()?['appointmentDetails'] != null) {
        final isPastDay = snapshot['appointmentDetails']['isPastDay'] ?? false;
        final payStatus = snapshot['appointmentDetails']['paymentStatus'];

          if (isPastDay == 'false' && payStatus == 'waiting') {
            await docRef.update({
              'appointmentDetails.isPastDay': 'true',
            });
          }
      } else {
        return;
      }
    }
  }
}

bool isNightHour(String startTime) {
  return startTime == '00:00' || startTime == '01:00' || startTime == '02:00' || startTime == '03:00';
}

bool isStartTimePast(DateTime now, String startTime, bool isNightHour) {
  final nowInMinutes = now.hour * 60 + now.minute;

  final parts = startTime.split(':');
  final startHour = int.parse(parts[0]);
  final startMinute = int.parse(parts[1]);
  final startInMinutes = startHour * 60 + startMinute;

  // Gece saati ise ertesi günmüş gibi davranıyor
  if (isNightHour) return false;

  return nowInMinutes >= startInMinutes;
}



class iconDayHour extends StatelessWidget {
  final String day;
  final String hour;
  const iconDayHour({
    Key? key,
    required this.day,
    required this.hour,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Row(
      children: [
        Icon(Icons.calendar_month, size: MediaQuery.sizeOf(context).width*0.05,),
        const SizedBox(width: 5),
        Text(day, textScaler: textScaler),
        const Spacer(),
        Icon(Icons.watch_later_outlined, size: MediaQuery.sizeOf(context).width*0.05,),
        const SizedBox(width: 5),
        Text(hour, textScaler: textScaler),
      ],
    );
  }
}
class nameSurname extends StatelessWidget {
  
  final String name;
  final String surname;
  const nameSurname({
    super.key,
    required this.name,
    required this.surname
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name $surname',
      style: GoogleFonts.poppins(
        fontSize: 18,
        color: Colors.black,
      ),
      textScaler :TextScaler.linear(ScaleSize.textScaleFactor(context))
    );
  }
}
class paymentButton extends StatelessWidget {
  final Map<String, dynamic> appointmentDetails;
  final String docId;
  const paymentButton({
    Key? key,
    required this.appointmentDetails,
    required this.docId
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>PaymentPage(
              sellerUid:appointmentDetails['selleruid'],
              sellerDocId: appointmentDetails['sellerDocId'],
              buyerUid: currentUser,
              selectedDay:appointmentDetails['day'],
              selectedHour:appointmentDetails['hour'],
              selectedField:appointmentDetails['field'],
              buyerDocId: docId,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: Text(
        'Ödeme yap',
        style: TextStyle(color: Colors.white),
        textScaler: textScaler,
      ),
    );
  }
}
class showTextBasedOnStatus extends StatelessWidget {
  final String status;
  const showTextBasedOnStatus({Key? key,required this.status}): super(key: key);

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Text(
      status == 'pending' ? 'Beklemede' : status == 'rejected' ? 'Reddedildi' : '',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
      textScaler: textScaler,
    );
  }
}

class showTextBasedOnGreyCard extends StatelessWidget {
  final String isPastDay;
  final String paymentStatus;
  const showTextBasedOnGreyCard({
    super.key,
    required this.isPastDay,
    required this.paymentStatus
  });

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Text(
        isPastDay == 'true' && paymentStatus != 'taken' ? 'Geçmiş'
      : isPastDay == 'false' && paymentStatus == 'taken' ? 'Dolu'
      : 'Dolu',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
      textScaler: textScaler,
    );
  }
}
class sellerApproveOrReject extends StatelessWidget {
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  const sellerApproveOrReject({
    Key? key,
    required this.onApprove,
    required this.onReject
  });

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Onayla', textScaler: textScaler),
                      ),
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Reddet', textScaler: textScaler,),
                      ),
                    ],
                  ),
                );
  }
}


