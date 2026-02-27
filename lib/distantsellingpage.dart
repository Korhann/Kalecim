import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class DistantSellingPage extends StatelessWidget {
  const DistantSellingPage({super.key});

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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesafeli Satış Sözleşmesi',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Taraflar
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.Taraflar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Hizmet Sağlayıcı (Satıcı):\n- Adı/Unvanı: [Hizmet Sağlayıcı Adı] \n- Adres: [Hizmet Sağlayıcı Adresi] \n- Telefon: [Telefon Numarası] \n- E-posta: [E-posta Adresi]'
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Hizmet Alan (Alıcı):\n- Adı/Soyadı: [Alıcı Adı Soyadı] \n- Adres: [Alıcı Adresi] \n- Telefon: [Telefon Numarası]\n- E-posta: [E-posta Adresi]'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Tanımlar
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2.Tanımlar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '- Hizmet: Alıcı tarafından belirlenen bir maç için belirli süreli kaleci kiralama hizmeti.\n- Sözleşme: İşbu mesafeli satış sözleşmesi.\n- Taraflar: Hizmet Sağlayıcı ve Alıcı.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Konu
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3.Konu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'İşbu sözleşmenin konusu, Alıcı’nın Hizmet Sağlayıcı’dan belirli bir tarih ve saat için kiraladığı kaleci hizmetinin detaylarını ve tarafların hak ve yükümlülüklerini düzenler.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Hizmet Niteliği ve Ücreti
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4.Hizmet Niteliği ve Ücreti',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '- Hizmet: Kaleci kiralama (belirtilen maç tarih ve saati için). \n- Süre: [Belirtilen saat aralığı]. \n- Ücret: [Hizmet bedeli] (KDV dahil). \n-Ek Masraflar: Alıcı talep ederse, ulaşım masrafları ücrete eklenir.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Ödeme Şekli ve Teslimat
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5.Ödeme Şekli ve Teslimat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '\n- Ödeme: Hizmet ücreti, sözleşmenin onaylanmasıyla birlikte peşin olarak yapılır. \n- Teslimat: Hizmet, belirtilen tarih ve saatte başlar.'
                        )
                      ],
                    ),
                    
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}