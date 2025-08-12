import 'dart:async';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/authpage.dart';
import 'package:kiralik_kaleci/sellerHomepage.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellerdirectmessages.dart';
import 'package:kiralik_kaleci/sellerprofilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({
    super.key,
    required this.index
  });
  final int index;

  @override
  State<SellerMainPage> createState() => SellerMainPageState();
}

class SellerMainPageState extends State<SellerMainPage> {

  late Stream<User?> _authStream;
  int _currentIndex = 0;
  int _unreadMessages = 0;
  List<StreamSubscription<DocumentSnapshot>> _listeners = [];

  @override
  void initState() {
    super.initState();
    // this does not log in sometimes
    _authStream = FirebaseAuth.instance.authStateChanges();
    _currentIndex = widget.index;
    listenToUnreadCount();
  }

  @override
  void dispose() {
    for (var l in _listeners) {
      l.cancel();
    }
    _listeners.clear();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot) {
        if (snapshot.hasData) {
        
        return Scaffold(
        body: screens()[_currentIndex],
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: sellerbackground,
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavyBarItem(
  icon: Stack(
    children: [
      const Icon(Icons.home, color: Colors.white),
      StreamBuilder<int>(
        stream: getUnreadAppointmentCount(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == 0) return SizedBox();
          return Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              child: Text(
                '${snapshot.data}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    ],
  ),
  title: const Text('Ana Sayfa'),
),
            BottomNavyBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.mail,color: Colors.white),
                  if (_unreadMessages > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        child: Text(
                          '$_unreadMessages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              title: const Text('Mesajlar'),
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.person,color: Colors.white),
              title: const Text('Profil'),
            ),
          ],
        ),
      );
      } else {
        return const AuthPage();
      }
      }
    );
  }
  List<Widget> screens() {
    return [const SellerHomePage(), const SellerDirectMessages(), const SellerProfilePage(), const SellerAddPage()];
  }

  void listenToUnreadCount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String currentUser = user.uid;
    final prefs = await SharedPreferences.getInstance();
    List<String>? sharedIds = prefs.getStringList('ids');
    if (sharedIds == null) return;

    Map<String, int> unreadPerChat = {};

    for (var st in sharedIds) {
      List<String> ids = [currentUser, st];
      ids.sort();
      String chatRoomId = ids.join('_');

      var subscription = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc('meta')
          .snapshots()
          .listen((metaDoc) {
        final data = metaDoc.data();
        if (data == null) return;

        int unread = data['senderId'] == currentUser
            ? data['to_msg'] ?? 0
            : data['from_msg'] ?? 0;
        unreadPerChat[chatRoomId] = unread;

        int totalUnread = unreadPerChat.values.fold(0, (a, b) => a + b);

        setState(() {
          _unreadMessages = totalUnread;
        });
      });

      _listeners.add(subscription);
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(e, stack, reason: 'Message counter failed');
  }
}

Stream<int> getUnreadAppointmentCount() {
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
