import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/addPhoneNo.dart';
import 'package:kiralik_kaleci/changeEmail.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/changePassword.dart';
import 'package:kiralik_kaleci/changeUsername.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    double iconSize = (width * 0.06).clamp(20.0, 32.0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: userorseller ? Colors.white : Colors.black)),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Menus(text: 'Kullanıcı Adı Değiştir', ontap:() => _navigateToPage('username'), iconSize: iconSize),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Şifre Değiştir', ontap:() => _navigateToPage('password'),iconSize: iconSize),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Email Değiştir', ontap:() => _navigateToPage('email'),iconSize: iconSize),

            Container(
              height: 1,
              color: sellerwhite,
            ),
            
            Menus(text: 'Telefon numarası', ontap:() => _navigateToPage('phone'),iconSize: iconSize),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Hesabı sil', ontap:() => _showMyDialog(),iconSize: iconSize),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(String menuOption) async {
    Widget page;
    switch (menuOption) {
      case 'username':
        page = const ChangeUserName();
        break;
      case 'password':
        page = const ChangePassword();
        break;
      case 'email':
        page = const ChangeEmail(); 
        break;
      case 'phone':
        page = const PhoneNo();
      default:
        return; 
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _showMyDialog() async {
  if (Platform.isIOS) {
    // iOS style dialog
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text('Hesabınızı silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Sil'),
              onPressed: () async{
                await deleteAccount();
              },
            ),
          ],
        );
      },
    );
  } else {
    // Android style dialog
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text('Hesabınızı silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () async{
                await deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }
}
  Future<void> deleteAccount() async {
  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      
      // Close dialog and show loading
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Hesap siliniyor...'),
            ],
          ),
        ),
      );

      // Create batch for efficient deletion
      final batch = FirebaseFirestore.instance.batch();

      // Delete main user document
      batch.delete(FirebaseFirestore.instance.collection('Users').doc(currentUser));

      // Get and delete user's subcollections
      final collections = ['ratings', 'appointmentbuyer', 'favourites', 'rentedUsers'];
      
      for (String collectionName in collections) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser)
              .collection(collectionName)
              .get();

          for (var doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
        } catch (e) {
          // Continue with next collection if one fails
          continue;
        }
      }

      // Delete chat rooms and messages (handle separately due to nested structure)
      try {
        final userChats = await FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('users', arrayContains: currentUser)
            .get();
        
        for (var chatDoc in userChats.docs) {
          try {
            // Delete messages first
            final messages = await chatDoc.reference.collection('messages').get();
            for (var messageDoc in messages.docs) {
              batch.delete(messageDoc.reference);
            }
            // Delete chat room
            batch.delete(chatDoc.reference);
          } catch (e) {
            continue;
          }
        }
      } catch (e) {
        // Continue even if chat deletion fails
      }

      // Commit the batch
      await batch.commit();

      // Delete user authentication
      await user.delete();
      await FirebaseAuth.instance.signOut();

      // Close loading and navigate
      Navigator.of(context).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage(index: 0)),
        (route) => false,
      );

    }
  } catch (e, stack) {
    // Close any open dialogs
    Navigator.of(context).pop();
    
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'settings page deletion error for user $currentUser',
    );

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hesap silinirken bir hata oluştu. Lütfen tekrar deneyin.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}


class Menus extends StatelessWidget {

  final String text;
  final VoidCallback ontap;
  final double iconSize;

  const Menus({required this.text, required this.ontap, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: height*0.065,
        width: double.infinity,
        color: userorseller ? sellergrey : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                text,
                style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: userorseller ? Colors.white : Colors.black),
                    textScaler: textScaler,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                size: iconSize,
                color: userorseller ? Colors.white : Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
