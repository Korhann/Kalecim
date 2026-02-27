import 'package:firebase_analytics/firebase_analytics.dart';

class Firebaseanalytics {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> firebasePaymentNotification(String userId, String sellerId) async{
    print('user id is $userId');
    print('seller id is $sellerId');
    await analytics.logEvent(
    name: "payment",
    parameters: {
        "buyer": userId,
        "keeper": sellerId,
    },
    );
  }
}