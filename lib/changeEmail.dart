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
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

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
      body: Form(
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
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      if (await InternetConnection().hasInternetAccess) {
                        await changeEmail();
                        if (isUpdated) {
                          _emailController.clear();
                          _currentPasswordController.clear();
                          if (mounted) {
                            Showalert(context: context, text: 'İşlem Başarılı')
                                .showSuccessAlert();
                          }
                        }
                      } else {
                        if (mounted) {
                          Showalert(context: context, text: 'Ooopps...')
                              .showErrorAlert();
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

    if (user == null && user!.email == null) {
      setState(() {
        _reauthErrorMessage = 'Kullanıcı oturumu açılmadı';
      });
    } else {
      final cred = EmailAuthProvider.credential(email: user.email.toString(), password: password);
      try {
        await user.reauthenticateWithCredential(cred);
        // bu yeni güncellenen mail
        // hata yazısına dikkatlice bak anlamaya çalış
        await user.verifyBeforeUpdateEmail(email);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentuser)
            .update({'email': email});
        isUpdated = true;
      } catch (e, stack) {
        setState(() {
          _reauthErrorMessage = 'Geçerli bir mail giriniz';
        });
        await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'approvedfield approvedFields error',
      );
      }
    } 
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
