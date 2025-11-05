import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

import 'sharedvalues.dart';

class SellerMessagePage extends StatefulWidget {
  final String receiverId;
  const SellerMessagePage({super.key, required this.receiverId});

  @override
  State<SellerMessagePage> createState() => _SellerMessagePageState();
}

class _SellerMessagePageState extends State<SellerMessagePage> {


  final ScrollController _scrollController = ScrollController();

  // sharedvalues dan gelen değerler null 
  String uid = sharedValues.sellerUid;
  bool? istapped = sharedValues.onTapped;

  // dokunulan kullanıcının maili
  String? sellerEmail;

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getEmail(uid);
  }

  void sendMessage() async {
    // sadece mesaj boş değilse gönder
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, _messageController.text,_messageController);
      // gönderdikten sonra temizle
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        backgroundColor: sellerbackground,
        title: Text(
          '$sellerEmail',
          style: GoogleFonts.inter(
            color: Colors.white
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back),color: Colors.white,),
      ),
      body: Column(
        children: [
          // mesajlar
          Expanded(
            child: _buildMessageList(),
          ),

          // kullanıcı input u
          _buildMessageInput(),
          const SizedBox(height: 20)
        ],
      )
    );
  }
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Hata ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Yükleniyor");
        }

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

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
    ? Alignment.centerRight
    : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data["senderId"] == _firebaseAuth.currentUser!.uid) 
          ? CrossAxisAlignment.end 
          : CrossAxisAlignment.start,
          children: [
            // sender maili göstermese de olur. Kaldırabilir sin
            Text(
              data['senderEmail'],
              style: GoogleFonts.inter(
                color: Colors.white
              ),
            ),
            const SizedBox(height: 5),
            ChatBubble(message: data['message'])
          ],
        ),
      ),
    );
  }
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              obscureText: false,
            ),
          ),
      
          // gönder butonu
          IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
        ],
      ),
    );
  } 
  // email çekme yöntemini değiştir sadece
  Future<void> _getEmail(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(widget.receiverId).get();
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
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'sellermessagepage _getEmail error for uid $uid',
      );
    }
  }
}