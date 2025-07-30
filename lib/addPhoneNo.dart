import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class PhoneNo extends StatefulWidget {
  const PhoneNo({super.key});

  @override
  State<PhoneNo> createState() => _PhoneNoState();
}

class _PhoneNoState extends State<PhoneNo> {

  TextEditingController phoneController = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _showErrorPhone = false;
  bool isUpdated = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void clearErrors() {
    setState(() {
      _showErrorPhone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
              phoneNo(),
              const SizedBox(height: 5),
              Container(
                width: width,
                color: userorseller ? sellerbackground : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                              width: width,
                              child: TextFormField(
                                  controller: phoneController,
                                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.black, fontSize: 20),
                                  decoration: GlobalStyles.inputDecorationPhoneNotOptional(
                                     showError: _showErrorPhone,
                                    ),
                                  onChanged: (value) => clearErrors(),
                                  validator: (value) {
                                  if (value == null || value.isEmpty || value.length < 10) {
                                    setState(() {
                                      _showErrorPhone = true;
                                    });
                                    return 'Lütfen doğru telefon numaranızı girin';
                                  } else {
                                    setState(() {
                                      _showErrorPhone = false;
                                    });
                                  }
                                  return null;
                                },
                                  onSaved: (value) {
                                    phoneController.text = value!;
                                  }
                                ),
                            ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      if (await InternetConnection().hasInternetAccess) {
                        await addPhoneNo();
                        if (isUpdated) {
                          phoneController.clear();
                          if (mounted) {
                            Showalert(context: context, text: 'İşlem Başarılı').showSuccessAlert();
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
    );
  }
  Future<void> addPhoneNo() async {
    final user = FirebaseAuth.instance.currentUser;
    final String? currentUser = user?.uid;
    String phoneNo = phoneController.text.trim();
    try {
      await FirebaseFirestore.instance.collection('Users').doc(currentUser).update({
        'phoneNo': phoneNo
      });
      isUpdated = true;
    } catch (e,stack) {
      await reportErrorToCrashlytics(e, stack, reason: 'add phone page add phone failed');
    }
  }
}
class phoneNo extends StatelessWidget {
  const phoneNo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        'Telefon numarası',
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