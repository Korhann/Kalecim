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

class EnterVerificationCode extends StatefulWidget {
  final String docId;
  const EnterVerificationCode({
    super.key,
    required this.docId
  });

  @override
  State<EnterVerificationCode> createState() => _EnterVerificationCodeState();
}

class _EnterVerificationCodeState extends State<EnterVerificationCode> {

  final _key = GlobalKey<FormState>();
  final codeVerifield = TextEditingController();
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);
  bool _showErrorCode = false;

  @override
  void dispose() {
    codeVerifield.dispose();
    super.dispose();
  }

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    TextScaler textScaler = TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sellerbackground,
        foregroundColor: Colors.white,
      ),
      backgroundColor: sellerbackground,
      body: Form(
        key: _key,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              TitleOfPage(),
              const SizedBox(height: 10),
              Container(
                width: width,
                color: userorseller ? sellerbackground : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: GlobalStyles.inputDecoration1(hintText: 'Doğrulama Kodu', showError: _showErrorCode),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    controller: codeVerifield,
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        setState(() {
                          _showErrorCode = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorCode = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),
              if (_showErrorCode && codeVerifield.text.trim().isEmpty)
                errorMessage('Doğrulama kodu boş bırakılamaz'),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      if (await InternetConnection().hasInternetAccess) {
                        if (await checkCodes()) {
                          codeVerifield.clear();
                          if (mounted) {
                            await updateCodeStatus();
                            Showalert(context: context, text: 'İşlem Başarılı').showSuccessAlert();
                          }
                        }else if (mounted) {
                          Showalert(context: context, text: 'Doğrulama Başarısız').showErrorAlert();
                        }
                      } else {
                        if (mounted) {
                          Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                        }
                      }
                    }
                  },
                  style: GlobalStyles.buttonPrimary(context),
                  child: Text(
                    'Onayla',
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: userorseller ? Colors.white : Colors.black,
                    ),
                    textScaler: textScaler,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> checkCodes() async{
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;

    final doc = await FirebaseFirestore.instance
    .collection('Users')
    .doc(currentuser)
    .collection('appointmentseller')
    .doc(widget.docId)
    .get();
    
    if (doc.exists) {
      final data = doc.data();
      final code = data!['appointmentDetails']['verificationCode'];
      if (codeVerifield.text.toUpperCase().trim() == code) {
        return true;
      }
    }
    return false;
  }
  void clearErrors() {
    setState(() {
      _showErrorCode = false;
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
  Future<void> updateCodeStatus() async {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentseller')  
        .doc(widget.docId)
        .update({'appointmentDetails.verificationState': 'verified'});
    } catch (e) {
      print('Error $e');
    }
  }
}

class TitleOfPage extends StatelessWidget {
  const TitleOfPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler= TextScaler.linear(ScaleSize.textScaleFactor(context));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Kodu Giriniz',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white
        ),
        textScaler: textScaler,
      ),
    );
  }
}