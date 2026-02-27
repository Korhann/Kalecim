import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = userorseller;
    final bgColor = isDarkMode ? sellerbackground : background;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: GlobalStyles.textStyle(text: 'İletişim', context: context, size: 20, fontWeight: FontWeight.w700, color: textColor),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.email_outlined, size: 32, color: textColor),
              const SizedBox(height: 12),
              GlobalStyles.textStyle(text: 'Mail Adresi', context: context, size: 16, fontWeight: FontWeight.w500, color: textColor),
              const SizedBox(height: 4),
              SelectableText(
                "kiraliikkalecii@gmail.com",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              Divider(color: textColor),
              const SizedBox(height: 20),
              GlobalStyles.textStyle(text: 'Destek almak için mail adresimize ulaşabilirsiniz.', context: context, size: 16, fontWeight: FontWeight.w400, color: textColor)
            ],
          ),
        ),
      ),
    );
  }
}
