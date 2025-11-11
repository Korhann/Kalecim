import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'bildirim_model.dart';

class PushHelper {
  //Writen by Hakan Kayacı

  static Future<void> sendPushBefore({required String userId,required String text,required String page}) async {
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final userData = userSnapshot.data();
    if(userData != null){
      String? notificationToken = userData['notificationToken'];

    if (notificationToken != null) {
      sendPush(text: text, id: notificationToken, data: {'page':page});
      //_writePush(text: text, targetEmail: targetEmail); Gönderilen bildirim sisteme kaydedilecekse çalışmalı.
    } else {
      print('notification token is null');
    }
    } else {
      print('user data is null');
    }
  }


  static Future<void> sendPushPayment({
    required String sellerUid,
    required String buyerUid,
    required String selectedDay,
    required String selectedHour,
    required String selectedField,
    required String buyerDocId,
    required String sellerDocId
  }) async{
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(buyerUid).get();
    final userData = userSnapshot.data();

    if (userData != null) {
      String? notificationToken = userData['notificationToken'];
      if (notificationToken != null) {
        sendPush(
          text: 'Kalecin maçı onayladı! Ödeme yapmanı bekliyor!',
          id: notificationToken,
          data :{
            'page': 'payment',
            'sellerUid': sellerUid,
            'buyerUid':buyerUid,
            'selectedDay':selectedDay,
            'selectedHour':selectedHour,
            'selectedField':selectedField,
            'buyerDocId': buyerDocId,
            'sellerDocId' : sellerDocId,
          }
        );
      }
    }
  }

  static Future<void> deleteAllPushes({required List<BildirimModel> bm}) {
    //Kaydedilen bildirimleri sistemden silmek için kullanılan fonksiyon

    // final batch = FirebaseFirestore.instance.batch();
    // for (int i = 0; i < bm.length; i++) {
    //   batch.delete(FirebaseFirestore.instance
    //       .collection(Collections.users)
    //       .doc(FirebaseAuth.instance.currentUser!.email!)
    //       .collection(Collections.bildirimler)
    //       .doc(bm[i].id));
    // }
    // return batch.commit();
    return Future.value();
  }

  static Future<List<BildirimModel>> getPushes() async {
    //Kaydedilen bildirimleri sistemden çekmek için kullanılan fonksiyon
    // final value = await FirebaseFirestore.instance
    //     .collection(Collections.users)
    //     .doc(FirebaseAuth.instance.currentUser!.email!)
    //     .collection(Collections.bildirimler)
    //     .get();
    // List<BildirimModel> bm = [];
    // for (DocumentSnapshot ds in value.docs) {
    //   final data = ds.data() as Map<String, dynamic>;
    //   final b = BildirimModel.fromMap(data: data);
    //   bm.add(b);
    // }
    // return Future.value(bm);
    return Future.value([]);
  }

  static _writePush({required String text, required String targetEmail}) {
    //Bildirimleri sisteme kaydetmek için kullanılan fonksiyon
    // String id = Uuid().v1();
    // FirebaseFirestore.instance
    //     .collection(Collections.users)
    //     .doc(targetEmail)
    //     .collection(Collections.bildirimler)
    //     .doc(id)
    //     .set(BildirimModel.toMap(
    //         bildirimmodel: BildirimModel(id, text, Timestamp.now())));
  }

  static Future<void> sendPush({required String text, required String id, required Map<String,dynamic> data}) async {
    try {
      // ignore: unused_local_variable
    var result = await http.post(Uri.parse('https://onesignal.com/api/v1/notifications'),
            headers: {
              "Authorization": 'key os_v2_app_3yelu3d7avbqjefmupb4d5vzjvwbwfbhecpexh5qehnhbt47sbxrosgootl4rbues6sgipme3wsdz234kxdzcsb4o3fd7toscmcs7ra',
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "app_id": "de08ba6c-7f05-4304-90ac-a3c3c1f6b94d",
              "include_subscription_ids": [id],
              "contents": {"en": text},
              'data': data
            })
        );
        print('OneSignal response: ${result.statusCode} ${result.body}');
    } catch (e){
      print('Error send push $e');
    }
  }

  static Future<void> updateOneSignal() async {
    Timer(const Duration(seconds: 5), () async {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email != null) {
        await OneSignal.login(FirebaseAuth.instance.currentUser!.email!);

        String? oneSignal = OneSignal.User.pushSubscription.id;
        var mFirestore = FirebaseFirestore.instance;

        final userSnapshot = await mFirestore
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;
          String userId = userDoc.id;
          mFirestore
              .collection('Users')
              .doc(userId)
              .update({'notificationToken' : oneSignal}).then((value) {
          }).onError((error, stackTrace) {
            debugPrint('oneSignal: $error');
          });
        } else {
          print('its empty');
        }
      } else {
        print('email is null');
      }
    });
  }
  // Add this method to your PushHelper class in push_helper.dart:

static Future<void> sendPushMessage ({
  required String userId,
  required String senderName, 
  required String message,
  required String senderId,
}) async {
  try {
    
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    
    // Check if user document exists
    if (!userSnapshot.exists) {
      return;
    }
    
    final userData = userSnapshot.data();
    
    // Check if user data is not null
    if (userData == null) {
      return;
    }
    
    // Check if user has notification token
    String? notificationToken = userData['notificationToken'];
    
    if (notificationToken == null || notificationToken.isEmpty) {
      return;
    }
    
    // Create notification text
    String notificationText = '$senderName: $message';
    
    // Send the push notification
    await sendPush(
      text: notificationText,
      id: notificationToken,
      data: {
        'page': 'messagepage',
        'senderId': senderId,
        'senderName': senderName,
        'chatRoomId': '${senderId}_${userId}',
      }
    );
    
    print('✅ Push notification sent successfully to $userId');
    
  } catch (e, stackTrace) {
    print('❌ Critical error sending message push notification:');
    print('   - Error: $e');
    print('   - UserId: $userId');
    print('   - SenderId: $senderId');
    print('   - SenderName: $senderName');
    print('   - StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
  }
}
}