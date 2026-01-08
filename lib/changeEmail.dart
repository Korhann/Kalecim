import 'dart:async';

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
import 'package:kiralik_kaleci/verifyEmailpage.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  // Software choose emulator graphics i olmuyorsa !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  //
  final _key = GlobalKey<FormState>();
  //
  bool _showErrorEmail = false;
  bool _showErrorPassword = false;
  //
  String _reauthErrorMessage = '';
  bool isUpdated = false;
  //
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  // mail değiştirmek için olan veriler
  bool _isWaitingForVerification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
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
                const SizedBox(height: 30),
                newEmail(),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: userorseller ? sellerbackground : background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      decoration: GlobalStyles.inputDecoration1(
                          hintText: 'Email', showError: _showErrorEmail),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      controller: _emailController,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => clearErrors(),
                      validator: (value) {
                        final currentTrimmedemail = value?.trim();
                        if (currentTrimmedemail!.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(currentTrimmedemail)) {
                          setState(() {
                            _showErrorEmail = true;
                          });
                          return '';
                        } else {
                          setState(() {
                            _showErrorEmail = false;
                          });
                          return null;
                        }
                      },
                    ),
                  ),
                ),
                if (_showErrorEmail)
                  errorMessage('Girdiğiniz mail hatalı veya kullanımda'),
                const SizedBox(height: 30),
                currentPassword(),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: userorseller ? sellerbackground : background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      decoration: GlobalStyles.inputDecoration1(
                          hintText: 'Şifre', showError: _showErrorPassword),
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      controller: _currentPasswordController,
                      obscureText: true,
                      onChanged: (value) => clearErrors(),
                      validator: (value) {
                        final currentTrimmedPassword = value?.trim();
                        if (currentTrimmedPassword!.isEmpty ||
                            currentTrimmedPassword.length < 6 ||
                            currentTrimmedPassword.contains(" ")) {
                          setState(() {
                            _showErrorPassword = true;
                          });
                          return '';
                        } else {
                          setState(() {
                            _showErrorPassword = false;
                          });
                          return null;
                        }
                      },
                    ),
                  ),
                ),
                if (_showErrorPassword &&
                    _currentPasswordController.text.trim().length < 6)
                  errorMessage("Parolanız çok kısa"),
                if (_showErrorPassword &&
                    _currentPasswordController.text.trim().contains(" "))
                  errorMessage("Parolada boşluk bulundurmayınız"),
                if (_showErrorPassword &&
                    _currentPasswordController.text.trim().isEmpty)
                  errorMessage("Parola boş bırakılamaz"),
                if (_reauthErrorMessage.isNotEmpty)
                  errorMessage(_reauthErrorMessage),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isWaitingForVerification ? null : () async {
                      if (_key.currentState!.validate()) {
                        if (await InternetConnection().hasInternetAccess) {
                          await changeEmail();
                        } else {
                          if (mounted) {
                            Showalert(context: context, text: 'İnternet bağlantısı yok').showErrorAlert();
                          }
                        }
                      }
                    },
                    style: GlobalStyles.buttonPrimary(context),
                    child: _isWaitingForVerification 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Doğrulama Bekleniyor...'),
                          ],
                        )
                      : Text(
                          'Onayla',
                          style: GoogleFonts.roboto(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: userorseller ? Colors.white : Colors.black,
                          ),
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

  void clearErrors() {
    setState(() {
      _showErrorEmail = false;
      _reauthErrorMessage = '';
    });
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

  Future<void> changeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    String email = _emailController.text.trim();
    String password = _currentPasswordController.text.trim();

    if (user == null || user.email == null) {
      setState(() {
        _reauthErrorMessage = 'Kullanıcı oturumu açılmadı';
      });
      return;
    }

    // Check if new email is same as current
    if (user.email == email) {
      setState(() {
        _reauthErrorMessage = 'Yeni email mevcut email ile aynı';
      });
      return;
    }

    final cred = EmailAuthProvider.credential(
      email: user.email.toString(), 
      password: password
    );

    await doUpdateOperations(user, email, cred, currentuser);
  }

  Future<void> doUpdateOperations(User user, String email, final cred, String? currentuser) async {
    try {
      // Step 1: Reauthenticate with current credentials FIRST
      await user.reauthenticateWithCredential(cred);
      
      // NOTE: This will sign out the user automatically!
      await user.verifyBeforeUpdateEmail(email);

      // await updateFirestoreData(currentuser,email);
      
      // Step 3: User is now signed out - show manual verification dialog
      setState(() {
        _isWaitingForVerification = true;
      });
      
      // Step 4: Show manual verification dialog (no automatic checking)
      _showEmailVerificationDialog(email);
      
    } catch (e, stack) {
      print('❌ Error in doUpdateOperations: $e');
      
      if (e.toString().contains('email-already-in-use')) {
        setState(() {
          _reauthErrorMessage = 'Bu email adresi zaten kullanımda';
        });
      } else if (e.toString().contains('wrong-password')) {
        setState(() {
          _reauthErrorMessage = 'Mevcut şifreniz yanlış';
        });
      } else {
        setState(() {
          _reauthErrorMessage = 'Email değiştirilirken hata oluştu';
        });
      }
      
      await reportErrorToCrashlytics(e, stack, reason: 'Email change error');
    }
  }

  Future<void> updateFirestoreData(String? currentuser, String email) async {
    try {
      await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentuser)
      .update({'email': email});
    } catch (e) {
      print('Error updating email');
    }
  }

  // Remove the automatic timer and use manual verification only
  void _showEmailVerificationDialog(String newEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Email Doğrulaması'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yeni email adresinize doğrulama linki gönderildi:',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                newEmail,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Önemli:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Güvenlik nedeniyle oturumunuz kapatıldı. Email doğruladıktan sonra yeni email adresinizle giriş yapın.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Adımlar:\n1. Email kutunuzu kontrol edin\n2. Doğrulama linkine tıklayın\n3. Yeni email ile giriş yapın',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _navigateToLogin(); // Go to login page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Giriş Sayfasına Git'),
          ),
        ],
      ),
    );
  }

  // Add this method to navigate to login
  void _navigateToLogin() {
    setState(() {
      _isWaitingForVerification = false;
    });
    
    // Sign out any remaining session
    FirebaseAuth.instance.signOut();
    
    // Navigate to login page
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Email değiştirme işlemi başlatıldı. Lütfen email kutunuzu kontrol edin.',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    // Remove timer disposal since we're not using it
    _emailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}


class newEmail extends StatelessWidget {
  const newEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        'Yeni Email',
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

class currentPassword extends StatelessWidget {
  const currentPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        'Mevcut Şifre',
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
