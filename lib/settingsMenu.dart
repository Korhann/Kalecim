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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: userorseller ? Colors.white : Colors.black)),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Menus(text: 'Kullanıcı Adı Değiştir', ontap:() => _navigateToPage('username') ),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Şifre Değiştir', ontap:() => _navigateToPage('password')),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Email Değiştir', ontap:() => _navigateToPage('email')),

            Container(
              height: 1,
              color: sellerwhite,
            ),
            
            Menus(text: 'Telefon numarası', ontap:() => _navigateToPage('phone')),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Hesabı sil', ontap:() => _showMyDialog()),
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
  Future<void> deleteAccount() async{
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // first delete the firestore data of the user
        await FirebaseFirestore.instance.collection('Users').doc(currentUser).delete();
        // delete the user and sign out the account
        await user.delete();
        await FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(index: 0)));
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'settings page deletion error for user $currentUser',
    );
    }
  }
}


class Menus extends StatelessWidget {

  final String text;
  final VoidCallback ontap;

  const Menus({required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
                size: width*0.06,
                color: userorseller ? Colors.white : Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
