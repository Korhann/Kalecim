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
  List<Comment_model> comments = [
    Comment_model(author: 'Korhan Demir', content: 'Çok iyi kaleci!!'),
    Comment_model(author: 'Mehmet Bilgiç', content: 'Kurtarışları mükemmel'),
    Comment_model(author: 'Deniz Demir', content: 'sjfslfjajfla')
  ];

  @override
  Widget build(BuildContext context) {
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
                      '2 saat önce', // You can add timestamp to your model
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
}