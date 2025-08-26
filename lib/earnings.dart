import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {

  int balance = 0;
  num withDrawalBalance = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getBalance();
    _getWithDrawalbalance();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sellerbackground,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*0.020),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: height*0.3,
                  color: Colors.blue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: GlobalStyles.textStyle(text: 'Bakiye', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: GlobalStyles.textStyle(text: '$balance TL', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: GlobalStyles.textStyle(text: 'Çekim Taleplerim', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: GlobalStyles.textStyle(text: '$withDrawalBalance TL', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                style: GlobalStyles.buttonPrimary(context),
                onPressed: () async{
                  await sendWithdrawalRequest();
                },
                child: GlobalStyles.textStyle(text: 'Çekim Talebi', context: context, size: 24, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> sendWithdrawalRequest() async{
    try {
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await firestore.collection('Users')
        .doc(currentuser)
        .collection('appointmentseller')
        .where('appointmentDetails.verificationState', isEqualTo: 'verified')
        .get();

        num withDrawalAmount = 0;
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final appointmentDetails = data['appointmentDetails'];
          if (appointmentDetails != null) {
            final sellerEarnings = appointmentDetails['sellerEarning'];
            if (sellerEarnings is int || sellerEarnings is double || sellerEarnings is num) {
              withDrawalAmount += sellerEarnings;
            }
          }
        }
        await insertBalanceToSellersDb(withDrawalAmount);

    } catch (e, stack) {
      await reportErrorToCrashlytics(e, stack, reason: 'withdrawal request error');
    }
  }

  Future<void> insertBalanceToSellersDb(final withDrawalAmount) async{
    try {
      DocumentReference <Map<String,dynamic>> insertBl = firestore.collection('Users').doc(currentuser);
      DocumentSnapshot<Map<String,dynamic>> seller =  await firestore.collection('Users')
      .doc(currentuser)
      .get();
      
      if (seller.exists && seller.data()!.containsKey('sellerDetails')) {
        await insertBl.update({'sellerDetails.sellerWithdrawal':withDrawalAmount});
      } 
      setState(() {});

    } catch (e,stack) {
      await reportErrorToCrashlytics(e, stack,reason: 'seller withdrawal error for user $currentuser');
    }
  }

  
  Future<void> _getBalance() async {
    try {
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await firestore.collection('Users')
        .doc(currentuser)
        .collection('appointmentseller')
        .where('appointmentDetails.verificationState', isEqualTo: 'verified')
        .get();

      num total = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final appointmentDetails = data['appointmentDetails'];
        if (appointmentDetails != null) {
          final price = appointmentDetails['price'];
          if (price is int || price is double) {
            total += price;
          } else if (price is String) {
            total += num.tryParse(price) ?? 0;
          }
        }
      }
      setState(() {
        balance = total.toInt();
      });
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'earnings _getBalance error',
      );
    }
  }

  Future<void> _getWithDrawalbalance() async{
    try {
      DocumentSnapshot<Map<String,dynamic>> sellerDetails =  await firestore.collection('Users')
      .doc(currentuser)
      .get();
      
      if (sellerDetails.exists && sellerDetails.data()!.containsKey('sellerDetails')) {
        withDrawalBalance = sellerDetails['sellerDetails.sellerWithdrawal'];
      } 
      setState(() {});

    } catch (e,stack) {
      await reportErrorToCrashlytics(e, stack,reason: 'seller withdrawal error for user $currentuser');
    }
  }
}