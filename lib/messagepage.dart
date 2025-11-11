import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class MessagePage extends StatefulWidget {
  final String receiverId;
  final String? fromWhere;
  const MessagePage({super.key, required this.receiverId, this.fromWhere});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  String? sellerEmail;
  bool _hasText = false;
  bool _isAppActive = true;
  bool _isInChat = true;
  Timer? _statusUpdateTimer;
  String? _currentChatRoomId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize chat room ID once
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      List<String> ids = [currentUser.uid, widget.receiverId];
      ids.sort();
      _currentChatRoomId = ids.join('_');
    }
    
    _initializeChat();
    _setupMessageListener();
    _setUserChatStatus(true);
  }

  void _initializeChat() {
    _chatService.initializeIds(_firebaseAuth.currentUser!.uid, widget.receiverId);
    _getEmail(widget.receiverId);
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      final currentHasText = _messageController.text.trim().isNotEmpty;
      if (currentHasText != _hasText) {
        setState(() => _hasText = currentHasText);
      }
    });
  }

  @override
void dispose() {
  _statusUpdateTimer?.cancel();
  _setUserChatStatus(false);
  
  WidgetsBinding.instance.removeObserver(this);
  _messageController.dispose();
  _scrollController.dispose();
  
  super.dispose();
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final wasActive = _isAppActive;
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppActive = true;
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _isAppActive = false;
        break;
    }
    if (wasActive != _isAppActive) {
      _setUserChatStatus(_isInChat);
    }
  }

  Future<void> sendMessage() async {
  final messageText = _messageController.text.trim();
  if (messageText.isEmpty) return;
  
  try {
    await _chatService.sendMessage(widget.receiverId, messageText, _messageController);
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e, 
      stack, 
      reason: 'Message send error to ${widget.receiverId}'
    );
  }
}

  // Debounced version to prevent too many rapid updates
Future<void> _setUserChatStatus(bool isInChat) async {
  // Cancel previous timer to avoid multiple rapid updates
  _statusUpdateTimer?.cancel();
  
  _statusUpdateTimer = Timer(const Duration(milliseconds: 500), () async {
    await _performStatusUpdate(isInChat);
  });
}

Future<void> _performStatusUpdate(bool isInChat) async {
  try {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || _currentChatRoomId == null) return;
    
    final isActiveInChat = isInChat && _isAppActive;
    
    final statusData = {
      'isOnline': isActiveInChat,
      'currentChatRoom': isActiveInChat ? _currentChatRoomId! : '',
      'lastSeen': FieldValue.serverTimestamp(),
    };
    
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('userStatus')
        .doc('status')
        .set(statusData, SetOptions(merge: true));
    
    // Update local state
    _isInChat = isInChat;
    
  } catch (e) {
    print('❌ Error updating user chat status: $e');
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
        onPressed: () {
          // Create a combined key for the switch
          String navigationKey = '${userorseller ? 'seller' : 'user'}_${widget.fromWhere ?? 'normal'}';
          switch (navigationKey) {
            case 'seller_fromNoti':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerMainPage(index: 1)
                ),
                ModalRoute.withName('/')
              );
              break;
              
            case 'user_fromNoti':
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(index: 1)
                ),
                ModalRoute.withName('/')
              );
              break;
              
            case 'seller_normal':
            case 'user_normal':
            default:
              Navigator.of(context).pop();
              break;
          }
        },
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
