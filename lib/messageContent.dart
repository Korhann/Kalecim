import 'package:cloud_firestore/cloud_firestore.dart';

class MessageContent {
  final Timestamp addtime;
  final String message;
  final String uid;
  final String email;


  MessageContent({
    required this.addtime,
    required this.message,
    required this.uid,
    required this.email
  });

  Map<String,dynamic> toMap() {
    return {
      'addtime': addtime,
      'message': message,
      'uid': uid,
      'email': email
    };
  }
}