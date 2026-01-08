import 'package:cloud_firestore/cloud_firestore.dart';
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

class AddFields extends StatefulWidget {
  const AddFields({super.key});

  @override
  State<AddFields> createState() => _AddFieldsState();
}

class _AddFieldsState extends State<AddFields> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _fieldNameController = TextEditingController();

  bool _showErrorDistrict = false;
  bool _showErrorFieldName = false;

  bool isReccommendationsent = false;

  @override
  void dispose() {
    _districtController.dispose();
    _fieldNameController.dispose();
    super.dispose();
  }

  void clearErrors() {
    setState(() {
      _showErrorDistrict = false;
      _showErrorFieldName = false;
    });
  }

  Future<void> submitRecommendation() async {
    try {
      await FirebaseFirestore.instance.collection('field_recommendations').add({
      'district': _districtController.text.trim(),
      'fieldName': _fieldNameController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    isReccommendationsent = true;
    _districtController.clear();
    _fieldNameController.clear();
    } catch (e, stack) {
        await reportErrorToCrashlytics(
          e,
          stack,
          reason: 'add field reccommendation faield',
        );
    }
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
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: PageContainerDesktop(
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                addFieldText(),
                const SizedBox(height: 20),
                // District input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _districtController,
                    decoration: GlobalStyles.inputDecoration1(
                      hintText: 'İlçe',
                      showError: _showErrorDistrict,
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        setState(() {
                          _showErrorDistrict = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorDistrict = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
                if (_showErrorDistrict && _districtController.text.trim().isEmpty)
                  errorMessage('İlçe boş bırakılamaz'),
                const SizedBox(height: 15),
                // Field name input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _fieldNameController,
                    decoration: GlobalStyles.inputDecoration1(
                      hintText: 'Halı Saha Adı',
                      showError: _showErrorFieldName,
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty) {
                        setState(() {
                          _showErrorFieldName = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorFieldName = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
                if (_showErrorFieldName && _fieldNameController.text.trim().isEmpty)
                  errorMessage('Halı saha adı boş bırakılamaz'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (await InternetConnection().hasInternetAccess) {
                          await submitRecommendation();
                          if (isReccommendationsent) {
                            if (mounted) {
                              Showalert(context: context, text: 'Tavsiye Gönderildi').showSuccessAlert();
                            }
                          }
                        }
                      } else {
                        if (mounted) {
                          Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                        }
                      }
                      isReccommendationsent = false;
                    },
                    style: GlobalStyles.buttonPrimary(context),
                    child: Text(
                      'Gönder',
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white : Colors.black,
                      ),
                      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                    ),
                  ),
                ),
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
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class addFieldText extends StatelessWidget {
  const addFieldText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        'Halı Saha Tavsiye Et',
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