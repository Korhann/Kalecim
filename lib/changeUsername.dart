import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/styles/pageContainerDesktop.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class ChangeUserName extends StatefulWidget {
  const ChangeUserName({super.key});

  @override
  State<ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<ChangeUserName> {
  
  final _key = GlobalKey<FormState>();
  final _newUsername = TextEditingController();
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);
  bool _showErrorUsername = false;

  bool isUpdated = false;

  @override
  void dispose() {
    _newUsername.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back,color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: PageContainerDesktop(
        child: Form(
          key: _key,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                newUserName(),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: userorseller ? sellerbackground : background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      decoration: GlobalStyles.inputDecoration1(hintText: 'Ad Soyad', showError: _showErrorUsername),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      controller: _newUsername,
                      onChanged: (value) => clearErrors(),
                      validator: (value) {
                        final trimmedValue = value?.trim();
                        if (trimmedValue == null ||
                            trimmedValue.isEmpty ||
                            trimmedValue.length < 6) {
                          setState(() {
                            _showErrorUsername = true;
                          });
                          return '';
                        } else {
                          setState(() {
                            _showErrorUsername = false;
                          });
                          return null;
                        }
                      },
                    ),
                  ),
                ),
                if (_showErrorUsername && _newUsername.text.trim().isEmpty)
                  errorMessage('Kullanıcı adı boş bırakılamaz'),
                if (_showErrorUsername && _newUsername.text.trim().length < 6)
                  errorMessage('Kullanıcı adı 6 haneden uzun olmalı'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        if (await InternetConnection().hasInternetAccess) {
                          await changeUsername();
                          if (isUpdated) {
                            _newUsername.clear();
                            if (mounted) {
                              _showUserNameChangeSuccess();
                            }
                          }
                        } else {
                          if (mounted) {
                            Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                          }
                        }
                      }
                      isUpdated = false;
                    },
                    style: GlobalStyles.buttonPrimary(context),
                    child: Text(
                      'Onayla',
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white : Colors.black,
                      ),
                      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget errorMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          message,
          style: GoogleFonts.inter(textStyle: errorstyle),
        ),
      ),
    );
  }

  void clearErrors() {
    setState(() {
      _showErrorUsername = false;
    });
  }

  Future<void> changeUsername() async {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentuser)
            .update({'fullName': _newUsername.text.trim()});
        isUpdated = true;
      } catch (e, stack) {
        await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'change username failed',
      );
      }
    }
  }
  void _showUserNameChangeSuccess() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 30),
          ),
          SizedBox(height: 16),
          Text(
            'Kullanıcı Adı Değiştirildi!',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Kullanıcı adınız başarı ile değiştirildi',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Tamam'),
        ),
      ],
    ),
  );
}
}

class newUserName extends StatelessWidget {
  const newUserName({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        'Yeni Kullanıcı Adı',
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: userorseller ? Colors.white : Colors.black,
        ),
        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      ),
    );
  }
}
