import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class DeliveryAndReturnPage extends StatelessWidget {
  const DeliveryAndReturnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = userorseller;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? sellerbackground : background;

    TextStyle sectionTitleStyle = GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    TextStyle boldUnderline = TextStyle(
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      color: textColor,
    );

    TextStyle bodyStyle = TextStyle(color: textColor, fontSize: 15);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teslimat ve İade Koşulları', style: sectionTitleStyle),
                const SizedBox(height: 20),

                _Section(
                  title: '1. Hizmet Teslimatı',
                  content:
                      'Kiraladığınız kaleci, rezervasyon sırasında belirtilen tarih, saat ve lokasyonda hazır bulunur. Teslimat, hizmet başlangıcı anında gerçekleşmiş sayılır.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                _Section(
                  title: '2. Hizmet Kapsamı',
                  content:
                      '- Kaleci sadece belirtilen maç süresi boyunca görev yapar.\n- Teslimat hizmetin başlamasını, tamamlanması ise maçın sona ermesini ifade eder.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                _Section(
                  title: '3. Gecikme Durumları',
                  content:
                      'Olağanüstü durumlar (hava durumu, trafik, vb.) nedeniyle oluşabilecek gecikmelerde kullanıcı bilgilendirilir ve alternatif çözümler sunulur.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text('İade Politikası', style: sectionTitleStyle),
                const SizedBox(height: 15),

                _Section(
                  title: '1. Ödeme Güvenliği ve Onay',
                  content:
                      'Uygulamamızda doğrudan iade işlemi yapılmamaktadır. Bunun yerine, ödeme yalnızca hizmet tamamlandıktan ve kaleci tarafından doğrulama kodu girildikten sonra gerçekleştirilir.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                _Section(
                  title: '2. Kod Girilmezse Ne Olur?',
                  content:
                      'Eğer satıcı (kaleci) doğrulama kodunu girmezse, ödeme başarıyla tamamlanmaz ve hesabınızdan herhangi bir ücret tahsil edilmez.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                _Section(
                  title: '3. Memnuniyetsizlik Durumu',
                  content:
                      'Hizmetle ilgili yaşadığınız memnuniyetsizlik durumlarını destek ekibimize 48 saat içinde bildirmeniz durumunda konuyu değerlendiririz.',
                  titleStyle: boldUnderline,
                  contentStyle: bodyStyle,
                ),

                const SizedBox(height: 20),
                Text('İletişim', style: sectionTitleStyle),
                const SizedBox(height: 10),
                Text(
                  'Her türlü soru ve destek talebi için bizimle iletişime geçebilirsiniz:\n\n'
                  '- E-Posta: kiraliikkalecii@gmail.com',
                  style: bodyStyle,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle titleStyle;
  final TextStyle contentStyle;

  const _Section({
    required this.title,
    required this.content,
    required this.titleStyle,
    required this.contentStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 5),
          Text(content, style: contentStyle),
        ],
      ),
    );
  }
}
