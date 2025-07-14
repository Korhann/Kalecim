import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/userorseller.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'styles/colors.dart';
import 'mainpage.dart';

//TODO: ANİMASYON EKLENECEK !!!

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final style = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);

  bool _showErrorName = false;
  bool _showErrorEmail = false;
  bool _showErrorPhone = false;
  bool _showErrorPassword = false;
  bool _showErrorRePassword = false;
  bool _emailInUse = false;

  void clearErrors() {
    setState(() {
  _showErrorName = false;
  _showErrorEmail = false;
  _showErrorPhone = false;
  _showErrorPassword = false;
  _showErrorRePassword = false;
  _emailInUse = false;
    });
  }

  Future signUpUser() async {
    String email = emailController.text;
    String password = passwordController.text;

    saveUserType('user');
    try {
      if (samePassword()) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;
        await addUser(fullNameController.text.trim(), email, uid, phoneController.text.trim());

        Navigator.push(
            context,
            platformPageRoute(
                builder: (_) => const MainPage(index: 0), context: (context)));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailInUse = true;
        });
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(e, stack, reason: 'Sign up failed');
    }
  }

  bool samePassword() {
    return passwordController.text.trim() == confirmPasswordController.text.trim();
  }

  Future<void> addUser(String fullName, String email, String uid, String phoneNo) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      "fullName": fullName,
      "email": email,
      'phoneNo': phoneNo
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 100
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Form(
                    key: formkey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            "Kayıt Ol",
                            style: GoogleFonts.inter(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
              
                          const SizedBox(height: 25),
              
                          // AD SOYAD
                          SizedBox(
                            width: width,
                            child: TextFormField(
                                controller: fullNameController,
                                key: Key('signup_name'),
                                style: const TextStyle(color: Colors.black, fontSize: 20),
                                decoration: GlobalStyles.inputDecoration1(hintText: 'Ad Soyad', showError: _showErrorName),
                                onChanged: (value) => clearErrors(),
                                validator: (value) {
                                  final nameSurname = value?.trim();
                                  if (nameSurname!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(nameSurname)) {
                                    setState(() {
                                      _showErrorName = true;
                                    });
                                    return '';
                                  } else {
                                    setState(() {
                                      _showErrorName = false;
                                    });
                                    return null;
                                  }
                                }),
                          ),
              
                          if (_showErrorName)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Geçerli bir isim soyisim giriniz",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
              
                          const SizedBox(height: 10),
              
                          // EMAİL
                          SizedBox(
                            width: width,
                            child: TextFormField(
                                controller: emailController,
                                key: Key('signup_email'),
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.black, fontSize: 20),
                                decoration: GlobalStyles.inputDecoration1(hintText: 'Email', showError: _showErrorEmail),
                                onChanged: (value) => clearErrors(),
                                validator: (value) {
                                  final email = value?.trim();
                                  if (email!.isEmpty ||!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) ||_emailInUse) {
                                    setState(() {
                                      _showErrorEmail = true;
                                      _emailInUse = false;
                                    });
                                    return '';
                                  } else {
                                    setState(() {
                                      _showErrorEmail = false;
                                    });
                                    return null;
                                  }
                                }),
                          ),
              
                          // Email başka bir hesap tarafından kullanımda olmasına rağmen hata vermiyor.
                          if (_showErrorEmail)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Girdiğiniz mail hatalı veya kullanımda",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
              
                          const SizedBox(height: 10),

                          // phone no
                          //todo: Telefon no will not be centered
                          SizedBox(
                            width: width,
                            child: TextFormField(
                                controller: phoneController,
                                key: Key('signup_phone'),
                                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.black, fontSize: 20),
                                decoration: GlobalStyles.inputDecorationPhone(
                                   showError: _showErrorPhone,
                                  ),
                                  onChanged: (value) => clearErrors(),
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.length < 10) {
                                    setState(() {
                                      _showErrorPhone = true;
                                    });
                                    return 'Lütfen telefon numaranızı girin';
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

                          if (_showErrorPhone)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Girdiğiniz numara hatalı",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),

                          const SizedBox(height: 10),
              
                          // PAROLA
                          SizedBox(
                            width: width,
                            child: TextFormField(
                              controller: passwordController,
                              key: Key('signup_password'),
                              style: const TextStyle(color: Colors.black, fontSize: 20),
                              decoration: GlobalStyles.inputDecoration1(
                                  hintText: 'Parola', showError: _showErrorPassword),
                                  onChanged: (value) => clearErrors(),
                              validator: (value) {
                                final password = value?.trim();
                                if (password!.isEmpty ||
                                    password.length < 6 ||
                                    password.contains(" ")) {
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
              
                          if (_showErrorPassword &&
                              passwordController.text.trim().length < 6)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Parolanız çok kısa",
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
              
                          if (_showErrorPassword &&
                              passwordController.text.trim().contains(" "))
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Parolada boşluk bulundurmayınız",
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
                          if (_showErrorPassword &&
                              passwordController.text.trim().isEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Parola boş bırakılamaz",
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
              
                          const SizedBox(height: 10),
              
                          // PAROLA TEKRAR
                          SizedBox(
                            width: width,
                            child: Focus(
                              child: TextFormField(
                                controller: confirmPasswordController,
                                key: Key('signup_password_again'),
                                style: const TextStyle(color: Colors.black, fontSize: 20),
                                decoration: GlobalStyles.inputDecoration1(
                                    hintText: 'Parola Tekrar',
                                    showError: _showErrorRePassword),
                                    onChanged: (value) => clearErrors(),
                                validator: (value) {
                                  final repassword = value?.trim();
                                  if (repassword!.isEmpty ||
                                      confirmPasswordController.text.trim() !=
                                          passwordController.text.trim()) {
                                    setState(() {
                                      _showErrorRePassword = true;
                                    });
                                    return '';
                                  } else {
                                    setState(() {
                                      _showErrorRePassword = false;
                                    });
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ),
              
                          const SizedBox(height: 5),
              
                          if (_showErrorRePassword &&
                              passwordController.text.trim().isEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Parola boş bırakılamaz",
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
                          if (_showErrorRePassword &&
                              passwordController.text.trim() !=
                                  confirmPasswordController.text.trim())
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Parola aynı olmalıdır",
                                style: GoogleFonts.inter(
                                    textStyle: GlobalStyles().errorstyle),
                              ),
                            ),
              
                          const SizedBox(height: 20.0),
              
                          Row(
                            children: [
                              PlatformText(
                                "Zaten bir hesabınız var mı?",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: grey),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LogIn()));
                                },
                                child: PlatformText(
                                  "Giriş Yap",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: green),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50.0),
              
                          PlatformElevatedButton(
                            key: Key('signup_button'),
                            onPressed: () async {
                              if (formkey.currentState!.validate()) {
                                await signUpUser();
                              }
                            },
                            child: Text(
                              "Kayıt Ol",
                              style: GoogleFonts.inter(color: Colors.black, textStyle: style)),
                              material: (_, __) => MaterialElevatedButtonData(
                                style: GlobalStyles.buttonPrimary(context)),
                              cupertino: (_, __) => CupertinoElevatedButtonData(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
                );
          },
        )
      ),
    );
  }
}
