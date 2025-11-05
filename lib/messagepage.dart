import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';

import 'sharedvalues.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({
    super.key,
});
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  final ScrollController _scrollController = ScrollController();

  // sharedvalues dan gelen değerler null 
  String uid = sharedValues.sellerUid;
  bool? istapped = sharedValues.onTapped;

  // dokunulan kullanıcının maili
  String? sellerEmail;

  bool _hasText = false;

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getEmail(uid);
    _messageController.addListener(() {
      bool currentHasText = _messageController.text.isNotEmpty;
      if (currentHasText != _hasText) {
        setState(() {
          _hasText = currentHasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    // sadece mesaj boş değilse gönder
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(sharedValues.sellerUid, _messageController.text, _messageController);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      title: Text('$sellerEmail'),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Message list section
          Flexible(
            child: _buildMessageList(),
          ),
          // Message input section
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildMessageInput(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMessageList() {
  return StreamBuilder(
    stream: _chatService.getMessages(sharedValues.sellerUid, _firebaseAuth.currentUser!.uid),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("Hata ${snapshot.error}");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Yükleniyor");
      }

      // Scroll to the bottom when the message list updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      return ListView(
        controller: _scrollController,
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    },
  );
}

Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
  Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;

  var alignment = (data['uid'] == _firebaseAuth.currentUser!.uid)
    ? Alignment.centerRight
    : Alignment.centerLeft;

  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: (data["uid"] == _firebaseAuth.currentUser!.uid) 
        ? CrossAxisAlignment.end 
        : CrossAxisAlignment.start,
        children: [
          // sender email is optional, can be removed
          Text(data['email']),
          const SizedBox(height: 5),
          ChatBubble(message: data['message'])
        ],
      ),
    ),
  );
}

Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
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
 Future<void> _getEmail(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      if (snapshot.exists) {
        Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('email')) {
          setState(() {
            sellerEmail = data['email'] as String;
          });
        }
      } else {
        print("email bulunamadı");
      }
    } catch (e) {
      print("Hata $e");
    }
  }
}