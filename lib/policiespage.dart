import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/contactpage.dart';
import 'package:kiralik_kaleci/deliveryandreturnpage.dart';
import 'package:kiralik_kaleci/distantsellingpage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/kiral%C4%B1kkalepage.dart';
import 'package:kiralik_kaleci/privacypolicypage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class PoliciesPage extends StatefulWidget {
  const PoliciesPage({super.key});

  @override
  State<PoliciesPage> createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); 
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black)
        ),
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WhoAreWePage())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Biz Kimiz',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gizlilik Politikası',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactPage())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'İletişim',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeliveryAndReturnPage())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Teslimat ve İade',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DistantSellingPage())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mesafeli Satış Sözleşmesi',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}