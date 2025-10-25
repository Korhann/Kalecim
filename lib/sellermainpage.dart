import 'dart:async';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/authpage.dart';
import 'package:kiralik_kaleci/sellerHomepage.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellerdirectmessages.dart';
import 'package:kiralik_kaleci/sellerprofilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({super.key, required this.index});
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
        builder: (context, snapshot) {
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
                            if (!snapshot.hasData || snapshot.data == 0)
                              return SizedBox();
                            return Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 15, minHeight: 15),
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
                        const Icon(Icons.mail, color: Colors.white),
                        StreamBuilder<List<String>>(
                          stream: fetchParticipantIds(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox();
                            }
                            var participantIds = snapshot.data!;
                            return FutureBuilder<int>(
                                future: _calculateTotalUnread(participantIds),
                                builder: (context, unreadSnapshot) {
                                  if (!unreadSnapshot.hasData ||
                                      unreadSnapshot.data == 0) {
                                    return const SizedBox();
                                  }
                                  return Positioned(
                                    right: 0,
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 10, minHeight: 10),
                                      child: Text(
                                        '${unreadSnapshot.data}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 8),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                });
                          },
                        )
                      ],
                    ),
                    title: Text(
                      'Mesajlar',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                  BottomNavyBarItem(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      // Add the badge using StreamBuilder
                      StreamBuilder<int>(
                        stream: getBuyerUnreadCount(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == 0) return const SizedBox();
                          return Positioned(
                            right: 0,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 10, minHeight: 10),
                              child: Text(
                                '${snapshot.data}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  title: Text(
                    'Profil',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                    ),
                  ),
                ),
                ],
              ),
            );
          } else {
            return const AuthPage();
          }
        });
  }

  List<Widget> screens() {
    return [
      const SellerHomePage(),
      const SellerDirectMessages(),
      const SellerProfilePage(),
      const SellerAddPage()
    ];
  }

  Stream<List<String>> fetchParticipantIds() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final currentUser = user.uid;

    Stream<QuerySnapshot> sentStream = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderId', isEqualTo: currentUser)
        .snapshots();

    Stream<QuerySnapshot> receivedStream = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: currentUser)
        .snapshots();

    return Rx.combineLatest2(
      sentStream,
      receivedStream,
      (QuerySnapshot sentSnap, QuerySnapshot receivedSnap) {
        Set<String> participantIds = {};
        for (var doc in sentSnap.docs) {
          participantIds.add(doc['receiverId']);
        }
        for (var doc in receivedSnap.docs) {
          participantIds.add(doc['senderId']);
        }
        return participantIds.toList();
      },
    );
  }

  Future<int> getUnreadMessages(String participantId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.error('noUnreadCount'); // Or redirect to login

    final currentUser = user.uid;

    try {
      List<String> ids = [currentUser, participantId];
      ids.sort();
      String chatRoomId = ids.join('_');

      DocumentSnapshot metaDoc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc('meta')
          .get();

      if (!metaDoc.exists) return 0;

      Map<String, dynamic> data = metaDoc.data() as Map<String, dynamic>;

      if (data['senderId'] == currentUser) {
        return data['to_msg'] ?? 0;
      } else {
        return data['from_msg'] ?? 0;
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(e, stack,
          reason:
              'directmessages getUnreadCount error for user $currentUser, participantId: $participantId');
      return 0;
    }
  }

  Future<int> _calculateTotalUnread(List<String> participantIds) async {
    int totalUnread = 0;

    for (String participantId in participantIds) {
      try {
        int unreadCount = await getUnreadMessages(participantId);
        totalUnread += unreadCount;
      } catch (e) {
        continue;
      }
    }
    return totalUnread;
  }

  Stream<int> getBuyerUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .collection('appointmentbuyer')
        .where('appointmentDetails.status', isEqualTo: 'pending')
        .where('appointmentDetails.isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
