import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiralik_kaleci/comment_model.dart';
import 'package:kiralik_kaleci/comment_section.dart';
import 'package:kiralik_kaleci/responsive/responsivedesign.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/pageContainerDesktop.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class CommentsPage extends StatefulWidget {
  final String sellerUid;
  final Future<bool> checkIfSameUser;
  const CommentsPage({
    super.key,
    required this.sellerUid,
    required this.checkIfSameUser
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveDesign.isDesktop(context) ? 1300.0 : double.infinity;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Yorumlar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          children: [
            // Comments list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.sellerUid)
                    .collection('rentedUsers')
                    .where('comment', isNotEqualTo: null)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Yorumlar yüklenirken hata oluştu',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Henüz yorum yapılmamış',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  
                  // Process the data
                  List<Comment_model> comments = [];
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['comment'] != null && data['comment'].toString().trim().isNotEmpty) {
                      comments.add(
                        Comment_model(
                          author: data['author'] ?? 'Anonymous',
                          content: data['comment'] ?? '',
                          serverTimestamp: data['timestamp'],
                        ),
                      );
                    }
                  }
        
                  // Return the ListView with proper scrolling
                  return PageContainerDesktop(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentWidget(comment: comments[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            FutureBuilder<bool>(
              future: widget.checkIfSameUser, // Use the passed future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // Don't show anything while loading
                }
                if (snapshot.hasError) {
                  return const SizedBox.shrink(); // Don't show on error
                }
                // Only show comment box if user has rented before
                if (snapshot.hasData && snapshot.data == true) {
                  return PageContainerDesktop(
                    child: CommentBox(
                      sellerUid: widget.sellerUid
                    ),
                  );
                }
                // Don't show comment box if user hasn't rented
                return const SizedBox.shrink();
              }
            ),
          ],
        ),
      ),
    );
  }
}
class CommentBox extends StatefulWidget {
  final String sellerUid;
  const CommentBox({super.key, required this.sellerUid});

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  String? currentUserName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startInitFunctions();
  }

  void startInitFunctions() async {
    await getUserName();
  }

  Future<void> getUserName() async {
  try {
    if (currentUserUid != null) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserUid!)
          .get();
      
      var userData = doc.data();
      if (userData != null && userData.containsKey('fullName')) {
        currentUserName = userData['fullName'];
      }
    }
  } catch (e, stack) {
    reportErrorToCrashlytics(
      e,
      stack,
      reason: 'getUserName error for user ${currentUserUid}',
    );
  }
}

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // if the user is rented then can make a comment
      await addComment(currentUserName!, _commentController.text);
      _commentController.clear();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorumunuz başarıyla gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum gönderilirken bir hata oluştu!'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  Future<void> addComment(final String author, final String content) async {
    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.sellerUid)
        .collection('rentedUsers')
        .doc(currentUserUid)
        .set({
          'author': author,
          'comment': content,
          'timestamp': FieldValue.serverTimestamp()
        });
    } catch (e,stack) {
      await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'getUserName error for user ${currentUserUid}',
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Yorum yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSubmitting ? null : _submitComment,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}