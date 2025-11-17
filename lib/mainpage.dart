import 'dart:async';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/authpage.dart';
import 'package:kiralik_kaleci/directmessages.dart';
import 'package:kiralik_kaleci/homepage.dart';
import 'package:kiralik_kaleci/profilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:rxdart/rxdart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.index});

  final int index;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<StreamSubscription<DocumentSnapshot>> _listeners = [];

  @override
  void initState() {
    super.initState();
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
    final height = MediaQuery.sizeOf(context).height;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // kullanıcı giriş yaptı
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: screens()[_currentIndex],
            bottomNavigationBar: BottomNavyBar(
              backgroundColor: background,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              containerHeight: height * 0.050,
              items: [
                BottomNavyBarItem(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.home,
                        color: Colors.black,
                      ),
                      StreamBuilder<int>(
                        stream: getUnreadCount(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == 0)
                            return const SizedBox();
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
                    'Ana Sayfa',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                    ),
                  ),
                ),
                BottomNavyBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.mail, color: Colors.black),
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
                    style: GoogleFonts.inter(color: Colors.black),
                  ),
                ),
                BottomNavyBarItem(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      // Add the badge using StreamBuilder
                      StreamBuilder<int>(
                        stream: getSellerUnreadCount(),
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
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // kullanıcı giriş yapmadı demek
          return const AuthPage();
        }
      },
    );
  }

  List<Widget> screens() {
    return [const HomePage(), const DirectMessages(), const ProfilePage()];
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
    if (user == null)
      return Future.error('noUnreadCount'); // Or redirect to login

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

  Stream<int> getSellerUnreadCount() {
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

  Stream<int> getUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .collection('appointmentbuyer')
        .where('appointmentDetails.status', whereIn: ['approved', 'rejected'])
        .where('appointmentDetails.paymentStatus', isEqualTo: 'waiting')
        .where('appointmentDetails.isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
