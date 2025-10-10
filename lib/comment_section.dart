import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/comment_model.dart';

class CommentSection extends StatefulWidget {
  final String sellerUid;
  const CommentSection({
    super.key,
    required this.sellerUid
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}


class _CommentSectionState extends State<CommentSection> {
  // burada bilgileri db den çek
  List<Comment_model> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

   Future<void> fetchComments() async {
    try {
      // Your Firebase fetch logic here
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.sellerUid)
          .collection('rentedUsers')
          .where('comment', isNotEqualTo: null)
          .orderBy('timestamp', descending: true)
          .get();

      List<Comment_model> fetchedComments = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['comment'] != null && data['comment'].toString().trim().isNotEmpty) {
          fetchedComments.add(
            Comment_model(author: data['author'] ?? 'Anonymous', content: data['comment'] ?? '', serverTimestamp: data['timestamp'])
          );
        }
      }

      if (mounted) {
        setState(() {
          comments = fetchedComments;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
      return ListView.builder(
        itemCount: comments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context,index) {
          return CommentWidget(comment: comments[index]);
        },
      );
  }
}

class CommentWidget extends StatelessWidget {
  final Comment_model comment;
  
  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  comment.author.isNotEmpty ? comment.author[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatTimestamp(comment.serverTimestamp), 
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  String formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return 'Bilinmeyen zaman';
  
  DateTime commentTime;
  
  // Handle different timestamp types
  if (timestamp is Timestamp) {
    commentTime = timestamp.toDate();
  } else if (timestamp is DateTime) {
    commentTime = timestamp;
  } else if (timestamp is String) {
    try {
      commentTime = DateTime.parse(timestamp);
    } catch (e) {
      return 'Geçersiz tarih';
    }
  } else {
    return 'Geçersiz tarih';
  }
  
  final now = DateTime.now();
  final difference = now.difference(commentTime);
  
  if (difference.inMinutes < 1) {
    return 'Şimdi';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} dakika önce';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} saat önce';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} gün önce';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks hafta önce';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ay önce';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years yıl önce';
  }
}
}