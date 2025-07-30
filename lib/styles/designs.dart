import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class GlobalStyles {
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  static InputDecoration inputDecoration({required String hintText}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      fillColor: const Color(0xFFE5E5E5),
      filled: true,
    );
  }
  static ButtonStyle buttonPrimary(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.sizeOf(context).height;
  return ElevatedButton.styleFrom(
    minimumSize: Size(screenWidth * 0.85, screenHeight > 1024 ? 70 : 50), 
    backgroundColor: green, 
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );
}

static Text textStyle({
  required String text,
  required BuildContext context,
  required double size,
  required FontWeight fontWeight,
  required Color color
  }) {
  return Text(
    text,
    style: GoogleFonts.roboto(
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
    ),
    textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
  );
}

static Icon iconStyle({
  required BuildContext context,
  required IconData icon,
  required Color color,
}) {
  return Icon(
    icon,
    size: MediaQuery.sizeOf(context).width*0.06,
    color: color,
  );
}

  
Widget buildTextField(

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
        height: 45,
        width: 335,
        child: PlatformTextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 20),
          material: (_, __) => MaterialTextFormFieldData(
            decoration: inputDecoration1(hintText: hintText, showError: showError),
          ),
          cupertino: (_, __) => CupertinoTextFormFieldData(
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: showError ? Colors.red : Colors.black), // Keep style but change border color
            ),
            placeholder: hintText,
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
static InputDecoration inputDecoration1({
  required String hintText,
  required bool showError,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    hintText: hintText,
    hintStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: grey,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    fillColor: const Color(0xFFE5E5E5),
    filled: true,
    errorStyle: const TextStyle(height: 0),
  );
}

static InputDecoration inputDecorationPhone({
  required bool showError,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        '+90 (Opsiyonel)',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    fillColor: const Color(0xFFE5E5E5),
    filled: true,
    errorStyle: const TextStyle(height: 0),
  );
}
static InputDecoration inputDecorationPhoneNotOptional({
  required bool showError,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        '+90',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: showError ? Colors.red : Colors.black),
      borderRadius: BorderRadius.circular(15.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(15.0),
    ),
    fillColor: const Color(0xFFE5E5E5),
    filled: true,
    errorStyle: const TextStyle(height: 0),
  );
}



}
