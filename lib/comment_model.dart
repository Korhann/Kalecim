import 'package:cloud_firestore/cloud_firestore.dart';

class Comment_model {
  final String author;
  final String content;
  final dynamic serverTimestamp;

  Comment_model({
    required this.author,
    required this.content,
    required this.serverTimestamp
  });
}