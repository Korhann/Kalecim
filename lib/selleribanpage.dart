import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/styles/pageContainerDesktop.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class SellerIbanPage extends StatefulWidget {
  const SellerIbanPage({super.key});

  @override
  State<SellerIbanPage> createState() => SellerIbanPageState();
}

class SellerIbanPageState extends State<SellerIbanPage> {
  // TODO problem text i silince TR kısmında T ve R yazmaya başlıyor !!!

  final formkey = GlobalKey<FormState>();
  
  final _ibanController = TextEditingController();
  final _nameController = TextEditingController();
  final _ibanFocusNode = FocusNode();
  
  bool wrongIBAN = false;
  bool wrongName = false;

  final String _ibanPattern = r'^TR\d{2} \d{4} \d{4} \d{4} \d{4} \d{4} \d{2}$';

  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  late String initialIbanNo = '';
  late String initialName = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final results = await Future.wait([
      getInitialIbanNo(),
      getInitialName()
    ]);
  }

  Future<String> getInitialIbanNo() async {
  try {
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .get();

    if (doc.exists) {
      final data = doc.data();
      final ibanDetails = data?['ibanDetails'];
      if (ibanDetails != null && ibanDetails['ibanNo'] != null) {
        initialIbanNo = ibanDetails['ibanNo'];
        _ibanController.text = initialIbanNo;
        return initialIbanNo;
      }
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'selleraddpage getInitialName error for user $currentUser',
    );
  }
  return '';
}
Future<String> getInitialName() async {
  try {
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .get();

    if (doc.exists) {
      final data = doc.data();
      final ibanDetails = data?['ibanDetails'];
      if (ibanDetails != null && ibanDetails['name'] != null) {
        initialName = ibanDetails['name'];
        _nameController.text = initialName;
        return initialName;
      }
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'selleraddpage getInitialName error for user $currentUser',
    );
  }
  return '';
}


  @override
  void dispose() {
    _ibanController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String formatIban(String input) {
    input = input.replaceAll(' ', '').toUpperCase();
    StringBuffer formatted = StringBuffer();

    if (input.startsWith('TR')) {
      formatted.write('TR');
      input = input.substring(2);
    }

    for (int i = 0; i < input.length; i++) {
      if ((i == 2 || (i > 2 && (i - 2) % 4 == 0)) && i != 0) {
        formatted.write(' ');
      }
      formatted.write(input[i]);
    }

    return formatted.toString();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sellerbackground,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      backgroundColor: sellerbackground,
      body: PageContainerDesktop(
        child: SafeArea(
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height*0.040),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GlobalStyles.textStyle(text: 'IBAN No', context: context, size: 20, fontWeight: FontWeight.w500, color: Colors.white)
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: sellerbackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      decoration: GlobalStyles.inputDecoration1(
                        hintText: 'IBAN', 
                        showError: wrongIBAN,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      controller: _ibanController,
                      focusNode: _ibanFocusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(32), // Including spaces
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String newText = newValue.text.toUpperCase();
                          if (newText.isEmpty || newText == 'T' || newText == 'TR') {
                            newText = 'TR'; // Always keep TR as default when empty
                          } else if (!newText.startsWith('TR')) {
                            newText = 'TR${formatIban(newText)}';
                          } else {
                            newText = '${formatIban(newText.substring(2))}';
                          }
                          
                          return TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(offset: newText.length),
                          );
                        }),
                      ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          wrongIBAN = true;
                        });
                      return 'Zorunlu alan boş bırakılmaz';
                      }
                    
                    final regex = RegExp(_ibanPattern);
                    if (!regex.hasMatch(value)) {
                      setState(() {
                        wrongIBAN = true;
                      });
                      return 'Lütfen geçerli bir iban giriniz';
                    }
                    setState(() {
                      wrongIBAN = false;
                    });
                    return null;
                  },
                  onTap: () {
                    if (_ibanController.text.isEmpty) {
                      setState(() {
                        _ibanController.text = 'TR';
                        _ibanController.selection = TextSelection.collapsed(offset: 2);
                      });
                    }
                  },
                ),
              ),
            ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GlobalStyles.textStyle(text: 'İban Sahibinin Adı', context: context, size: 20, fontWeight: FontWeight.w500, color: Colors.white)
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: sellerbackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      decoration: GlobalStyles.inputDecoration1(hintText: 'Ad Soyad', showError: wrongName),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20
                      ),
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            wrongName = true;
                          });
                          return 'Zorunlu alandır boş bırakılmaz';
                        }
                        setState(() {
                          wrongName = false;
                        });
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: height*0.060),
        
                Center(
                  child: ElevatedButton(
                    onPressed: () async{
                      if (await InternetConnection().hasInternetAccess) {
                        if (formkey.currentState!.validate()) {
                        await _updateIbanNo();
                        }
                      } else {
                        Showalert(context: context, text: 'Ooops...').showErrorAlert();
                      }
                    },
                    style: GlobalStyles.buttonPrimary(context),
                    // child: Text(
                    //   'Kaydet',
                    //   style: GoogleFonts.roboto(
                    //     fontSize: 30,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.white
                    //   ),
                    // )
                    child: GlobalStyles.textStyle(text: 'Kaydet', context: context, size: 30, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateIbanNo() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      String iban = _ibanController.text;
      String name = _nameController.text;

      try {
        Map<String, dynamic> ibanDetails = {
          'ibanNo': iban,
          'name': name
        };

        await FirebaseFirestore
            .instance
            .collection('Users')
            .doc(userId)
            .update({'ibanDetails': ibanDetails});

        Showalert(context: context, text: 'İşlem başarılı bir şekilde gerçeklişmiştir').showSuccessAlert();
        _ibanController.clear();
        _nameController.clear();

      } catch (e, stack) {
        await reportErrorToCrashlytics(
          e,
          stack,
          reason: 'selleribanpage _updateIbanNo error for user $userId',
        );
        Showalert(context: context, text: 'Ooops...').showErrorAlert();
        print('Error $e');
      }
    }
  }
}