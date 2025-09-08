import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
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
  bool withDrawRequest = false;
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  late Stream<num> getBalance;
  late Stream<num> getWithdrawalbalance;

  @override
  void initState() {
    super.initState();
    getBalance = _getBalance();
    getWithdrawalbalance = _getWithDrawalbalance();
  }

  @override
  
  Widget build(
  BuildContext context) {
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
                        padding: const EdgeInsets.only(left: 20,top: 10),
                        child: StreamBuilder<num>(
                          stream: getBalance,
                          builder: (context,snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox();
                            } else {
                              balance = snapshot.data!.toInt() ?? 0;
                              return GlobalStyles.textStyle(text: '$balance TL', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white);
                            }
                          } 
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: GlobalStyles.textStyle(text: 'Çekim Taleplerim', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: StreamBuilder(
                          stream: getWithdrawalbalance,
                          builder: (context,snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox();
                            } else {
                              withDrawalBalance = snapshot.data!.toInt() ?? 0;
                              return GlobalStyles.textStyle(text: '$withDrawalBalance TL', context: context, size: 20, fontWeight: FontWeight.w800, color: Colors.white);
                            }
                          } 
                        ),
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
                onPressed: () async {
                  if (balance > 0) {
                    withDrawRequest = true;
                    await sendWithdrawalRequest();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Çekim talebi için hesabınızda birikmiş bakiye olması gerekir !'),
                        backgroundColor: Colors.red,
                      )
                    );
                  }
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
            // bunu yapmamın sebebi pazar günü kullanıcı bakiyesini çekmez ise randevu sıfırlanıyor, onu takip etmem lazım
            await doc.reference.update({
              'appointmentDetails.isWithdrawalButtonPressed':true
            });
            if (withDrawRequest == true && (sellerEarnings is int || sellerEarnings is double || sellerEarnings is num)) {
              withDrawalAmount += sellerEarnings;
              await doc.reference.update({
                'appointmentDetails.sellerEarning': 0
              });
            } 
          }
        }
        if (withDrawalAmount > 0) {
          await insertBalanceToSellersDb(withDrawalAmount);
        }
        withDrawRequest = false;
    } catch (e, stack) {
      await reportErrorToCrashlytics(e, stack, reason: 'withdrawal request error');
    }
  }

  // Future<void> changeButtonPressedbool() async {
  //   try {
  //     QuerySnapshot<Map<String,dynamic>> querySnapshot = await firestore.collection('Users')
  //       .doc(currentuser)
  //       .collection('appointmentseller')
  //       .where('appointmentDetails.verificationState', isEqualTo: 'verified')
  //       .get();

  //       for (var doc in querySnapshot.docs) {
  //         final data = doc.data();
  //         final appointmentDetails = data['appointmentDetails'];
  //         if (appointmentDetails != null) {
  //           await doc.reference.update(
  //             'appointmentD'
  //           )
  //         }
  //       }
  //   } catch (e,stack) {
  //     await reportErrorToCrashlytics(e, stack, reason: 'earningspage button pressed error');
  //   }
  // }

  Future<void> insertBalanceToSellersDb(final withDrawalAmount) async {
  try {
    DocumentReference<Map<String, dynamic>> insertBl = firestore.collection('Users').doc(currentuser);

    DocumentSnapshot<Map<String, dynamic>> seller = await insertBl.get();

    if (seller.exists && seller.data()!.containsKey('sellerDetails')) {
      await insertBl.update({
        'sellerDetails.sellerWithdrawal': FieldValue.increment(withDrawalAmount),
      });
    } else {
      // if sellerDetails or field doesn't exist, initialize it
      await insertBl.set({
        'sellerDetails': {
          'sellerWithdrawal': withDrawalAmount,
        }
      }, SetOptions(merge: true));
    }

    // setState(() {});
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'seller withdrawal error for user $currentuser',
    );
  }
}


  Stream<num> _getBalance() {
  return firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentseller')
      .where('appointmentDetails.verificationState', isEqualTo: 'verified')
      .snapshots()
      .map((querySnapshot) {
        num total = 0;
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final appointmentDetails = data['appointmentDetails'];
          if (appointmentDetails != null) {
            final price = appointmentDetails['sellerEarning'];
            if (price is int || price is double) {
              total += price;
            } else if (price is String) {
              total += num.tryParse(price) ?? 0;
            }
          }
        }
        return total;
      });
}
  
  Stream<num> _getWithDrawalbalance() {
      return firestore.collection('Users')
      .doc(currentuser)
      .snapshots()
      .map((docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data()!.containsKey('sellerDetails')) {
          final sellerDetails = docSnapshot.data()!['sellerDetails'];
          final balance = sellerDetails['sellerWithdrawal'];
          if (balance is int || balance is double) {
            return balance as num;
          } else if (balance is String) {
            return num.tryParse(balance) ?? 0;
          }
        }
        return 0;
      });
  }
}