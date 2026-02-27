import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class WhoAreWePage extends StatelessWidget {
  const WhoAreWePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = userorseller;
    final bgColor = isDark ? sellerbackground : background;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biz Kimiz?',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Halısahada kaleci bulmanın bu kadar zor olduğu bir zamanda, '
                  'halısaha tutkunları ile kalecileri kolay ve hızlı bir şekilde bir araya getirmeyi hedefliyoruz. '
                  'Kalecim, futbol severlerin son dakikada kaleci arama derdine son veriyor ve güvenilir bir hizmet sunuyor.',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Amacımız',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Futbol keyfinizi yarıda bırakmamak ve kalecisiz maç yapma derdini ortadan kaldırmak. '
                'Kalecim ile birkaç dokunuşla uygun kaleciyi bulabilir, maçınıza odaklanabilirsiniz.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
