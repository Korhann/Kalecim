import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/messageContent.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';

import 'message.dart';

class ChatService extends ChangeNotifier {

  // TODO: bence unreadmessages fonksiyonu mesajı göndermeden önce çalışaması lazım(yarın yine bak) CHATGPT den dün sormuştun ona bak !!!
  
  late String currentUserId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String,dynamic> ?receiverFullName;
  late String receiverFullNames;
  late String receiverImage;
  late String senderfullName;
  int fromMsg = 0;
  int toMsg = 0;
  late Message newMessage;
  String chatRoomId = '';


  Future<void> initializeIds(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    chatRoomId = ids.join('_');
    if (chatRoomId.isNotEmpty && !sharedValues.idsroom.contains(chatRoomId)) {
      sharedValues.idsroom.add(chatRoomId);
    } 
  }


// Update your sendMessage method in ChatService class:
Future<void> sendMessage(String receiverId, String message, TextEditingController messageController) async {
  // mesajı iki defa göndermemesi için ilk başta temizle
  messageController.clear();

  await initializeIds(_firebaseAuth.currentUser!.uid, receiverId);

  currentUserId = _firebaseAuth.currentUser!.uid;
  final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
  final Timestamp timestamp = Timestamp.now();

  await _getReceiverDetails(receiverId);
  await _getSenderfullName(currentUserId);

  CollectionReference messageDocRef = _firestore
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages');

  DocumentReference documentReference = _firestore
  .collection('chat_rooms')
  .doc(chatRoomId)
  .collection('messages')
  .doc('meta');

  QuerySnapshot messageDocSnapshot = await messageDocRef.get();

  // Retrieve the last message
  String lastMessage = '';
  if (messageDocSnapshot.docs.isNotEmpty) {
    final messageListSnapshot = await documentReference.collection('messageList')
      .orderBy('addtime', descending: true)
      .limit(1)
      .get();
        
    if (messageListSnapshot.docs.isNotEmpty) {
      lastMessage = messageListSnapshot.docs.first.get('message') as String;
    }
  }

  // yoksa yeniden yarat
  if (!messageDocSnapshot.docs.isNotEmpty) {
    Message newMessage = Message(
      senderId: currentUserId, 
      senderEmail: currentUserEmail, 
      receiverId: receiverId, 
      lastmessage: message, // Set the initial message
      receiverfullName: receiverFullNames,
      senderfullName: senderfullName,
      receiverImage: receiverImage,
      timeStamp: timestamp,
      fromMsg: fromMsg,
      toMsg: toMsg
    );
    await messageDocRef.doc('meta').set(newMessage.toMap());
  } else {
    // eğer varsa güncelle
    await messageDocRef.doc('meta').update({
      'lastMessage': message,
      'timeStamp': timestamp
    });
  }

  // messageList koleksiyonuna ekliyor
  MessageContent messageContent = MessageContent(
    addtime: timestamp, 
    message: message, 
    uid: currentUserId,
    email: currentUserEmail
  );

  final messageDocRef1 = _firestore
  .collection('chat_rooms')
  .doc(chatRoomId)
  .collection('messages')
  .doc('meta');

  final messageListRef = messageDocRef1.collection('messageList').doc();

  await messageListRef.set(messageContent.toMap());
  
  // todo: bunu mesajı göndermeden önce göndermem lazım
  await unredMessages(messageListRef, receiverId, messageDocRef1);

  await _sendMessageNotification(receiverId, message);
}

// Add this new method to ChatService class:
Future<void> _sendMessageNotification(String receiverId, String message) async {
  try {
    // Get sender's name for notification
    String senderName = senderfullName.isNotEmpty ? senderfullName : 'Bilinmeyen';
    
    // Truncate message if too long
    String notificationText = message.length > 50 
        ? '${message.substring(0, 50)}...' 
        : message;
    
    // Create notification text
    String fullNotificationText = '$senderName: $notificationText';
    
    // Send push notification using your existing PushHelper
    await PushHelper.sendPushMessage(
      userId: receiverId,
      senderName: senderName,
      message: notificationText,
      senderId: currentUserId,
    );
    
  } catch (e) {
    print('Error sending message notification: $e');
  }
}


  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore.collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc('meta')
      .collection('messageList')
      .orderBy('addtime', descending: false)
      .snapshots();
  }

  Future<void> _getReceiverDetails(receiverId) async {
    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(receiverId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    if (data.isNotEmpty && data.containsKey('fullName')) {
      receiverFullNames = data['fullName'];
    }

    if (data.isNotEmpty && data.containsKey('sellerDetails')) {
      Map<String,dynamic> sellerDetails = data['sellerDetails'];
      if (sellerDetails.isNotEmpty && sellerDetails.containsKey("imageUrls")) {
        List<dynamic> imageUrls = sellerDetails['imageUrls'];
        receiverImage = imageUrls.first;
      }
    }
  }

  Future<void> _getSenderfullName(currentuserId) async {
    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(currentuserId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String,dynamic>;

    if (data.isNotEmpty && data.containsKey('fullName')) {
      senderfullName = data['fullName'];
    }
  }

  Future<void> unredMessages(
  DocumentReference messageListDoc,
  String receiverID,
  DocumentReference messageMetaDoc
) async {
  try {
    final messageListSnapshot = await messageListDoc.get();
    final messageMetaSnapshot = await messageMetaDoc.get();

    if (!messageMetaSnapshot.exists || !messageListSnapshot.exists) return;

    final messageListData = messageListSnapshot.data() as Map<String, dynamic>;
    final messageMetaData = messageMetaSnapshot.data() as Map<String, dynamic>;

    int fromMsg = messageMetaData['from_msg'] ?? 0;
    int toMsg = messageMetaData['to_msg'] ?? 0;

    final senderId = messageMetaData['senderId'];
    final receiverId = messageMetaData['receiverId'];
    final uid = messageListData['uid'];

    if (uid == senderId) {
      fromMsg += 1;
    } else if (uid == receiverId) {
      toMsg += 1;
    }

    await messageMetaDoc.update({
      'from_msg': fromMsg,
      'to_msg': toMsg,
    });

  } catch (e) {
    print("Error in unredMessages: $e");
  }
}

}
