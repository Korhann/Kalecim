import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String lastmessage;
  final String receiverfullName;
  final String receiverImage;
  final Timestamp timeStamp;
  final String senderfullName;
  final int? fromMsg;
  final int? toMsg;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.lastmessage,
    required this.receiverfullName,
    required this.receiverImage,
    required this.senderfullName,
    required this.timeStamp,
    required this.fromMsg,
    required this.toMsg,
  });

  Map<String, dynamic> toMap(){
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'lastMessage': lastmessage,
      'receiverfullName': receiverfullName,
      'senderfullName':senderfullName,
      'receiverImage': receiverImage,
      'timestamp': timeStamp,
      'deletedBySender': false,
      'deletedByReceiver': false,
      'from_msg': fromMsg,
      'to_msg': toMsg,
    };
  }
}
