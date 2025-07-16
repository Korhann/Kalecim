import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'direct2messagepage.dart';

class DirectMessages extends StatefulWidget {
  const DirectMessages({super.key});

  @override
  State<DirectMessages> createState() => _DirectMessagesState();
}

class _DirectMessagesState extends State<DirectMessages> {

  late String currentUser;
  late Stream<int> unreadCount;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
  }
  @override
  void dispose() {

    super.dispose();
  }

//   Stream<List<Map<String, dynamic>>> fetchConversations() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null){return const Stream.empty();}

//     final currentUser = user.uid;
//     Stream<QuerySnapshot> sentStream = FirebaseFirestore.instance
//       .collectionGroup('messages')
//       .where('senderId', isEqualTo: currentUser)
//       .snapshots();
    

//     Stream<QuerySnapshot> receivedStream = FirebaseFirestore.instance
//       .collectionGroup('messages')
//       .where('receiverId', isEqualTo: currentUser)
//       .snapshots();

//     return Rx.combineLatest2(
//     sentStream,
//     receivedStream,
//     (QuerySnapshot sentSnap, QuerySnapshot receivedSnap) async {  
//       Set<String> participantIds = {};

//       for (var doc in sentSnap.docs) {
//         participantIds.add(doc['receiverId']);
//       }

//       for (var doc in receivedSnap.docs) {
//         participantIds.add(doc['senderId']);
//       }

//       List<Map<String, dynamic>> tempConversations = [];

//       for (String participantId in participantIds) {        
//         String lastMessage = await _getLastMessage(participantId);
//         String receiverName = await _getReceiverName(participantId);
//         String? imageUrl = await _getReceiverImage(participantId);
//         int unreadCount = await getUnreadCount(participantId);
//         await addParticipantIdToPrefs(participantId);

//         tempConversations.add({
//           'receiverId': participantId,
//           'receiverName': receiverName,
//           'lastMessage': lastMessage,
//           'imageUrl': imageUrl,
//           'unread': unreadCount
//         });
//       }
//       return tempConversations;
//     },
//   ).asyncMap((futureList) => futureList);
// }

  // Future<void> addParticipantIdToPrefs(String participantId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     List<String> ids = prefs.getStringList('ids') ?? [];

  //     if (!ids.contains(participantId)) {
  //       ids.add(participantId);
  //       await prefs.setStringList('ids', ids);
  //     }
  //   } catch (e, stack) {
  //     await reportErrorToCrashlytics(
  //       e,
  //       stack,
  //       reason: 'directmessages addParticipantIdToPrefs error for participantId: $participantId',
  //     );
  //   }
  // }



Future<Map<String, dynamic>> fetchConversationData(String participantId) async {
  String lastMessage = await _getLastMessage(participantId);
  String receiverName = await _getReceiverName(participantId);
  String? imageUrl = await _getReceiverImage(participantId);
  int unreadCount = await getUnreadCount(participantId);
  // Optionally, add to SharedPreferences here if needed, but avoid if possible
  return {
    'receiverId': participantId,
    'receiverName': receiverName,
    'lastMessage': lastMessage,
    'imageUrl': imageUrl,
    'unread': unreadCount,
  };
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
      print(participantIds);
      return participantIds.toList();
    },
  );
}
  Future<int> getUnreadCount(String participantId) async {
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
    } catch (e,stack) {
      await reportErrorToCrashlytics(e, stack,reason: 'directmessages getUnreadCount error for user $currentUser, participantId: $participantId');
      return 0;
    }
  }

  Future<void> resetUnredMessages(String participantId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.error('noMessagesReset');
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

      Map<String, dynamic> data = metaDoc.data() as Map<String, dynamic>;

      if (data['senderId'] == currentUser) {
        await metaDoc.reference.update({'to_msg': 0});
      } else {
        await metaDoc.reference.update({'from_msg': 0});
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'directmessages resetUnredMessages error for user $currentUser, participantId: $participantId',
      );
    }
  }

  Future<String> _getLastMessage(String receiverId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.error('noLastMessage');
    final currentUser = user.uid;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('senderId', whereIn: [currentUser, receiverId])
          .where('receiverId', whereIn: [currentUser, receiverId])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['lastMessage'];
      }
      return "";
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'directmessages _getLastMessage error for user $currentUser, receiverId: $receiverId',
      );
      return "";
    }
  }

  Future<String> _getReceiverName(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (snapshot.exists) {
        return snapshot['fullName'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'directmessages _getReceiverName error for userId: $userId',
      );
      return 'Unknown';
    }
  }

  Future<String?> _getReceiverImage(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (snapshot.exists && snapshot['sellerDetails']?['imageUrls'] != null) {
        List<dynamic> images = snapshot['sellerDetails']['imageUrls'];
        return images.isNotEmpty ? images.first : null;
      }
      return null;
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'directmessages _getReceiverImage error for userId: $userId',
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final iconSize = width * 0.06;
  return StreamBuilder<List<String>>(
    stream: fetchParticipantIds(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return MessagesShimmer();
      }
      if (snapshot.data!.isEmpty) {
        print('does it enter here');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: iconSize, color: Colors.grey.shade500),
                const SizedBox(height: 10),
                Text(
                'Henüz bir mesajınız bulunmuyor',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black
                ),
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              ),
              ],
            ),
          ),
        );
      }
      var participantIds = snapshot.data!;
      print('ids are $participantIds');
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: GlobalStyles.textStyle(
              text: 'Mesajlar',
              context: context,
              size: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          backgroundColor: background,
          centerTitle: true,
        ),
        backgroundColor: background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return ListView.builder(
              itemCount: participantIds.length,
              itemBuilder: (context, index) {
                final participantId = participantIds[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchConversationData(participantId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      // todo: change the message shimmer
                      return ListTile(
                        title: const SizedBox(),
                      );
                    }
                    var conversation = snapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.055,
                        backgroundImage: conversation['imageUrl'] != null
                            ? NetworkImage(conversation['imageUrl'])
                            : null,
                        child: conversation['imageUrl'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(conversation['receiverName'], style: TextStyle(fontSize: width * 0.045)),
                      subtitle: Row(
                        children: [
                          Text(conversation['lastMessage'], style: TextStyle(fontSize: width * 0.04)),
                          const Spacer(),
                          if (conversation['unread'] > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${conversation['unread']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                        ],
                      ),
                      onTap: () async {
                        await resetUnredMessages(conversation['receiverId']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Direct2Message(receiverId: conversation['receiverId']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      );
    },
  );
}
}



