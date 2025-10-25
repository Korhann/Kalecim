import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class Direct2Message extends StatefulWidget {
  final String receiverId;
  const Direct2Message({super.key, required this.receiverId});

  @override
  State<Direct2Message> createState() => _Direct2MessageState();
}

class _Direct2MessageState extends State<Direct2Message> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? sellerEmail;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _getEmail(widget.receiverId);
    _chatService.initializeIds(_firebaseAuth.currentUser!.uid, widget.receiverId);
    _messageController.addListener(() {
      bool currentHasText = _messageController.text.isNotEmpty;
      if (currentHasText != _hasText) {
        setState(() {
          _hasText = currentHasText;
        });
      }
    });
  }

  void sendMessage() async {
    try {
      if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, _messageController.text);
      _messageController.clear();
    }
    } catch (e, stack) {
      reportErrorToCrashlytics(e, stack, reason: 'direct2messages send message error ${widget.receiverId}');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: userorseller ? sellerbackground : Colors.white,
    resizeToAvoidBottomInset: true, 
    appBar: AppBar(
      backgroundColor: userorseller ? sellerbackground : Colors.white,
      title: Text(
        sellerEmail ?? 'Loading...',
        style: TextStyle(color: userorseller ? Colors.white : Colors.black)),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black,),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Messages List
          Expanded(child: _buildMessageList()),
              
          // Message Input Field wrapped in SafeArea
          SafeArea(
            top: false,
            child: _buildMessageInput(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}



  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
    // bunun document i yanlış olduğu için göstermiyor
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    var alignment = (data['uid'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['uid'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              data['email'] ?? '',
              style: GoogleFonts.inter(
                color: userorseller ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: userorseller ? sellergrey : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Message input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Mesajınızı yazın...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Send button (reactive)
        Container(
          decoration: BoxDecoration(
            color: _hasText
                ? Theme.of(context).primaryColor 
                : Colors.grey[400],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _hasText ? sendMessage : null,
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _getEmail(String receiverId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(receiverId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('email')) {
          setState(() {
            sellerEmail = data['email'] as String;
          });
        }
      } else {
        print("Email not found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
