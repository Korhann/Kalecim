import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'sharedvalues.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DirectedMessagePage extends StatefulWidget {
  const DirectedMessagePage({
    super.key,
});
  @override
  State<DirectedMessagePage> createState() => _DirectedMessagePageState();
}

class _DirectedMessagePageState extends State<DirectedMessagePage> with WidgetsBindingObserver {

  final ScrollController _scrollController = ScrollController();

  String uid = sharedValues.sellerUid;
  bool? istapped = sharedValues.onTapped;
  String? sellerEmail;
  bool _hasText = false;
  bool _isAppActive = true;
  bool _isInChat = true;
  Timer? _statusUpdateTimer;
  String? _currentChatRoomId;

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize chat room ID once
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      List<String> ids = [currentUser.uid, uid];
      ids.sort();
      _currentChatRoomId = ids.join('_');
    }
    
    _initializeChat();
    _setupMessageListener();
    _setUserChatStatus(true);
  }
  void _initializeChat() {
    _chatService.initializeIds(_firebaseAuth.currentUser!.uid, uid);
    _getEmail(uid);
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      final currentHasText = _messageController.text.trim().isNotEmpty;
      _hasTextNotifier.value = currentHasText;
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
    
    // Only update status if app active state actually changed
    if (wasActive != _isAppActive) {
      _setUserChatStatus(_isInChat);
    }
  }

  Future<void> sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    
    try {
      await _chatService.sendMessage(uid, messageText, _messageController);
    } catch (e, stack) {
      await reportErrorToCrashlytics(
      e, 
      stack, 
      reason: 'Message send error directedMessage'
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
          _buildMessageInput(),
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
          
          // send button
          ValueListenableBuilder<bool>(
            valueListenable: _hasTextNotifier,
            builder: (context, hasText, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: hasText ? Theme.of(context).primaryColor : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: hasText ? sendMessage : null,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
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