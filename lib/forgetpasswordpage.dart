import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  // Key for the form
  final formkey = GlobalKey<FormState>();
  // Textstyles
  final hintstyle =const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final style = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
  final textstyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  // Declare the contorller
  final resetController = TextEditingController();

  // Added variable to control error message visibility
  bool _showError = false; 


  void clearErrors() {
    setState(() {
      _showError = false;
    });
  }

  Future<void> sendResetLink() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(
        color: Colors.grey,
      )),
      );
    try {
      final textResetController = resetController.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: textResetController);

      if (mounted) {
        Navigator.of(context).pop();
        resetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email gönderildi'), backgroundColor: Colors.green),
      );
      }
    } catch (e, stack) {
      reportErrorToCrashlytics(e, stack, reason: 'password reset failed');
    }
  }

  @override
  void dispose() {
    super.dispose();
    resetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black)
        ),
      ),
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 160),
                  PlatformText(
                    "Şifreni yenile",
                    style: GoogleFonts.inter(textStyle: style),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: PlatformText(
                      "Email giriniz ve hesabınıza şifrenizi yenilemek için link gönderilecek",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.inter(textStyle: textstyle, color: grey),
                    ),
                  ),
              
                  const SizedBox(height: 10),
              
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                  //   child: _buildTextField(resetController, 'Email', _showError,(value) {
                  //     setState(() => _showError = value.trim().isEmpty ||!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value));
                  //   } ),
                  // ),
                  SizedBox(
                    width: width,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: resetController,
                      onChanged: (value) => clearErrors(),
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      decoration: GlobalStyles.inputDecoration1(hintText: 'Email',showError: _showError),
                      validator: (value) {
                        final email = value?.trim();
                        if (email!.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value!)) {
                          setState(() {
                            _showError = true;
                          });
                          return '';
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 2,),
                  if (_showError) 
                    Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Girdiğiniz mail hatalı',
                              textAlign: TextAlign.start,
                              style: GoogleFonts.inter(
                                textStyle: errorstyle
                              ),
                            ),
                          ),
                  const SizedBox(height: 30),
              
                  ElevatedButton(
                    style: GlobalStyles.buttonPrimary(context),
                    onPressed: () async{
                      if (formkey.currentState!.validate()) {
                        if (resetController.text.trim().isNotEmpty) {
                          await sendResetLink();
                          setState(() {
                            _showError = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      "Yenile",
                      style: GoogleFonts.inter(textStyle: style),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField(
  TextEditingController controller,
  String hintText,
  bool showError,
  Function(String) validator, {
  bool obscureText = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        child: PlatformTextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: (value) => clearErrors(),
          style: const TextStyle(color: Colors.black, fontSize: 20),
          material: (_, __) => MaterialTextFormFieldData(
            decoration: GlobalStyles.inputDecoration1(hintText: hintText, showError: showError)
          ),
          cupertino: (_, __) => CupertinoTextFormFieldData(
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: showError ? Colors.red : Colors.black), // Keep style but change border color
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          validator: (value) {
            validator(value!);
            return showError ? '' : null;
          },
        ),
      ),
      if (showError)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: PlatformText(
            "Geçerli bir $hintText giriniz",
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red),
          ),
        ),
      const SizedBox(height: 17),
    ],
  );
}

// Updated input decoration function
InputDecoration _inputDecoration(String hintText, bool showError) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    hintText: hintText,
    hintStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.normal, color: grey),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    fillColor: const Color(0xFFE5E5E5),
    filled: true,
  );
}

}
