import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/addPhoneNo.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:http/http.dart' as http;
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:logging/logging.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String? sellerUid;
  final String? sellerDocId;
  final String? buyerUid;
  final String? selectedDay;
  final String? selectedHour;
  final String? selectedField;
  final String? buyerDocId;
  const PaymentPage({
    super.key,
    this.sellerUid,
    this.sellerDocId,
    this.buyerUid,
    this.selectedDay,
    this.selectedHour,
    this.selectedField,
    this.buyerDocId
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //todo : uygulamadan çıkış yapılmışken bildirime basınca oluyor(null check used on null value)
  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String sellerFullName;
  bool isPaymentLoading = false;

  // this informations are for the payment
  late String buyerName;
  late String buyerLastName;
  late String buyerEmail;
  late int buyerPrice;
  late String buyerIpNo;
  late String buyerPhoneNo;

  late String token;

  final log = Logger('MyClassName');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPaymentInformation();
    final String? buyerUid = widget.buyerUid ?? FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            // birden fazla push olduğu için bunu kullandım
            Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const MainPage(index: 0)),
            // ModalRoute.withName('/'),
            (Route<dynamic> route) => false,
            );
        }, icon: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      'Seçilen gün ve saat',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          _selectedDay(),
                          const Spacer(),
                          _selectedHour()
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Seçilen saha',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: _selectedField(),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Ödenecek Tutar',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Text(
                            'Hizmet Bedeli:',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black
                              ),
                          ),
                          const Spacer(),
                          _price()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: isPaymentLoading 
              ? CircularProgressIndicator() 
              : ElevatedButton(
                onPressed: () async {
                  bool phoneError = await checkPhoneNo();
                  await checkIfDayPast();
                  final results = await Future.wait([
                    checkIfHourTaken(),
                    checkIfHourPast(),
                  ]);
                  bool? hourTaken = results[0];
                  bool isPast = results[1];
                  if (hourTaken == false && isPast == false) {
                    // if the payment is succesfull
                    bool isSuccess = await _processPayment();
                    if (isSuccess) {
                      await _markHourTaken();
                      await rentedUsers(widget.sellerUid);
                      await Showalert(context: context, text: 'İşlem Başarılı').showSuccessAlert();
                      await Future.delayed(Duration(seconds: 1));
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AppointmentsPage(whereFrom: 'fromPayment')),
                          (Route<dynamic> route) => false,
                        );
                      }
                      // if the payment is declined
                    } else {
                      if (phoneError == false) {
                        if (mounted) {
                          await Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                        }
                      } else {
                        if (mounted) {
                          await Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                        }
                      }
                    }
                  } else {
                    if (hourTaken && isPast == false) {
                      await markAppointmentTaken();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat başkası tarafından alınmıştır'),
                        backgroundColor: Colors.red,
                      )
                    );
                    } else if (isPast && hourTaken == false) {
                      await markIsPastDay();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat geçmiştir'),
                        backgroundColor: Colors.red,
                      )
                    );
                    } else {
                      await markAppointmentTaken();
                      await markIsPastDay();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat başkası tarafından alınmış veya geçmiştir'),
                        backgroundColor: Colors.red,
                      )
                    );
                    }
                  }
                }, 
              style: GlobalStyles.buttonPrimary(context),
              child: Text(
                'Ödeme',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectedField() {
    return Text(
      widget.selectedField!,
      style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    );
  }

  Widget _selectedDay() {
  return Text(
    widget.selectedDay!,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}
  Widget _selectedHour() {
  return Text(
    widget.selectedHour!,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}

  Widget _price() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Users').doc(widget.sellerUid).snapshots(),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String,dynamic>;
        if (widget.selectedHour == '00:00-01:00' || widget.selectedHour == '01:00-02:00') {
          var sellerDetails = userData['sellerDetails'];
          var sellerPrice = sellerDetails['sellerPriceMidnight'];


          // appointment page için
          sellerFullName = sellerDetails['sellerFullName'];

          return Text(
            sellerPrice != null ? '${sellerPrice.toString()}TL' : '',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black
            ),
          );
        } else {
          var sellerDetails = userData['sellerDetails'];
          var sellerPrice = sellerDetails['sellerPrice'];

          // appointment page için
          sellerFullName = sellerDetails['sellerFullName'];

          return Text(
            sellerPrice != null ? '${sellerPrice.toString()}TL' : '',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black
            ),
          );
        }
      }
    );
  }

  Future<bool> _processPayment() async { 
  try {
    setState(() {
      isPaymentLoading = true;
    });
    final response = await http.post(
      Uri.parse('https://europe-west2-kiralikkaleci-21f26.cloudfunctions.net/api/checkout-form'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': buyerName,
        'surname': buyerLastName,
        'email': buyerEmail,
        'phone': buyerPhoneNo,
        'price': buyerPrice.toString(),
        'ip': buyerIpNo,
        'sellerId': widget.sellerUid,
        'buyerId': widget.buyerUid,
        'sellerDocId': widget.sellerDocId,
        'buyerDocId': widget.buyerDocId, 
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentPageUrl = data['paymentPageUrl'];
      final token = data['token'];
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Ödeme')),
            body: WebPage(paymentPageUrl: paymentPageUrl, token: token),
          ),
        ),
      );
      if (result == true) {
        bool isPaid = await updatePaymentStatus();
        setState(() {
          isPaymentLoading = false;
        });
        return isPaid;
      } else {
        setState(() {
          isPaymentLoading = false;
        });
        return false;
      }
    } else {
      // the payment is not successfull
      setState(() {
        isPaymentLoading = false;
      });
      return false;
    }
  } catch (e, stack) {
    await FirebaseCrashlytics.instance.recordError(
      e, stack,
      reason: 'Payment exception on mobile data: ip=$buyerIpNo',
      fatal: false,
    );
  }
  return false;
}

// Firestore'da paymentStatus 'done' olana kadar bekle
Future<bool> waitForPaymentStatus(String docId) async {
  for (int i = 0; i < 10; i++) { // 10 defa dene, 2 saniye arayla
    await Future.delayed(Duration(seconds: 2));
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(docId)
      .get();
    final status = doc['appointmentDetails']['paymentStatus'];
    if (status == 'done') {
      return true;
    }
  }
  return false;
}

  Future<bool> updatePaymentStatus() async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.paymentStatus' : 'done'
      });
      await sendNotificationToSeller();
      return true;
    } catch (e) {
      print('Error updating payment status $e');
      return false;
    }
  }

  Future<void> checkIfDayPast() async{
    try {
      DocumentReference<Map<String, dynamic>> documentReference = _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId);

      final snapshot = await documentReference.get();
      final day = snapshot['appointmentDetails']['day'] ?? '';
      final startTime = snapshot['appointmentDetails']['startTime'];
      await CheckDaysPastUser.isPast(day, widget.buyerDocId!,startTime);
    } catch (e) {
      print('Error checking hour $e');
    }
  }

  Future<void> _markHourTaken() async {
    DocumentReference docref = _firestore.collection('Users').doc(widget.sellerUid);

    try {
      DocumentSnapshot sellerDoc = await docref.get();
      if (!sellerDoc.exists) {
        return;
      }
      Map<String,dynamic>? sellerData = sellerDoc.data() as Map<String,dynamic>;
      List<dynamic> hourList = List.from(sellerData['sellerDetails']['selectedHoursByDay'][widget.selectedDay]);
      for (var hour in hourList) {
        if (hour['title'] == widget.selectedHour) {
          hour['istaken'] = true;
          hour['takenby'] = currentuser;
          break;
        }
      }
      await docref.update({'sellerDetails.selectedHoursByDay.${widget.selectedDay}':hourList});
    } catch (e) {
      print('Error $e');
    }
  }

  Future<bool> checkIfHourPast() async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference = _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId);

      final snapshot = await documentReference.get();
      final isPastDay = snapshot['appointmentDetails']['isPastDay'] ?? false;
      if (isPastDay == 'true') {
        return true;
      } else if (isPastDay == 'false') {
        return false;
      }
    } catch (e) {
      print('Error checking hour $e');
    }
    return false;
  }

  Future<bool> checkIfHourTaken() async {
    try {
      DocumentSnapshot snapshot = await _firestore
        .collection('Users')
        .doc(widget.sellerUid)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];
          if (selectedHoursByDay.containsKey(widget.selectedDay)) {
            List<dynamic> hoursList = selectedHoursByDay[widget.selectedDay];
            var mathcingHour = hoursList.firstWhere((hour) => hour['title'] == widget.selectedHour);
            if (mathcingHour != null) {
              return mathcingHour['istaken'] ?? false;
            }
          }
        }
      }
    }
    }catch (e) {
      print('Error checking is taken value $e');
    }
    return false;
  }

  Future<void> markAppointmentTaken() async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.paymentStatus' : 'taken'
      });
    }catch (e) {
      print('Appointment could not mark as taken');
    }
  }
  Future<void> markIsPastDay() async{
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.isPastDay' : 'true'
      });
    } catch (e) {
      print('is past day could not be marked $e');
    }
  }
  Future<void> sendNotificationToSeller() async {
    await PushHelper.sendPushBefore(userId: widget.sellerUid!, text: 'Ödeme alınmıştır', page: 'appointment');
  }
  Future<void> getPaymentInformation() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(widget.buyerUid).get();

      if (userDoc.exists) {
        buyerName = userDoc['fullName'];
        buyerLastName = userDoc['fullName'];
        buyerEmail = userDoc['email'];
        await getSellerPrice();
        await getPhoneNo();
        await getIpNo();
      }
    } catch (e){
      print('Error getting payment info $e');
    }
  }
  Future<void> getIpNo() async{
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    buyerIpNo = wifiIP ?? '0.0.0.0';
    await FirebaseCrashlytics.instance.log('Network info: wifiIP=$wifiIP, used=$buyerIpNo');
  }
  Future<void> getSellerPrice() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(widget.sellerUid).get();
      var sellerData = snapshot.data() as Map<String,dynamic>;
      if (widget.selectedHour == '00:00-01:00' || widget.selectedHour == '01:00-02:00') {
        buyerPrice = sellerData['sellerDetails']['sellerPriceMidnight'];
      } else {
        buyerPrice = sellerData['sellerDetails']['sellerPrice'];
      }
    } catch (e){
      print('Error getting price $e');
    }
  }
  Future<void> getPhoneNo() async{
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(currentuser).get();
      var data = snapshot.data() as Map<String,dynamic>;
      buyerPhoneNo = data['phoneNo'];
    } catch (e) {
      print('Error getting phone no $e');
    }
  }
  Future<bool> checkPhoneNo() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(currentuser).get();
      var data = snapshot.data() as Map<String,dynamic>;
      buyerPhoneNo = data['phoneNo'];
      if (buyerPhoneNo.isEmpty) {
        // buraya bir pop up dialog koy telefon numarası girmelisiniz de
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Telefon numaranızı ekleyiniz'
            ),
            backgroundColor: Colors.red
          )
        );
        Future.delayed(const Duration(seconds: 1), () async {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PhoneNo())
        );
        });
        return true;
      }
    } catch (e) {
      print('Error getting phone no $e');
    }
    return false;
  }

  Future<void> rentedUsers(String? sellerUid) async {
    await _firestore.collection('Users')
    .doc(sellerUid)
    .collection('rentedUsers')
    .doc(currentuser)
    .set({});
  }
}



class WebPage extends StatefulWidget {
  final String paymentPageUrl;
  final String token;
  const WebPage({super.key, required this.paymentPageUrl, required this.token});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController controller;
  final callbackUrl = "https://europe-west2-kiralikkaleci-21f26.cloudfunctions.net/api/iyzico-callback";
  bool _isPopped = false; 

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            print('onPageStarted: $url');
          },
          onPageFinished: (url) async {
            print('onPageFinished: $url');
            if (_isPopped) return;
            if (url.startsWith(callbackUrl)) {
              final uri = Uri.parse(url);
              Navigator.pop(context, true);
              if (widget.token.isNotEmpty) {
                final response = await http.post(
                  Uri.parse('https://europe-west2-kiralikkaleci-21f26.cloudfunctions.net/api/check-payment'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'token': widget.token}),
                );
                if (response.statusCode == 200) {
                  final result = jsonDecode(response.body);
                  if (result['status'] == 'success') {
                    _isPopped = true;
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    _isPopped = true;
                    Navigator.pop(context, false);
                  }
                } else {
                  _isPopped = true;
                  Navigator.pop(context, false);
                }
              } else {
                _isPopped = true;
                Navigator.pop(context, false);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentPageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
