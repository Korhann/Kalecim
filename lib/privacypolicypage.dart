import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                      'Kiralık Kaleci Uygulaması Gizlilik ve Güvenlik Politikası',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: userorseller ? Colors.white: Colors.black
                        ),
                    ),
                    const SizedBox(height: 20),
        
                    // Genel Bilgiler
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.Genel Bilgiler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Kiralık Kaleci uygulaması olarak, kullanıcılarımızın gizlilik ve güvenliğine büyük önem veriyoruz. Bu Gizlilik ve Güvenlik Politikası, kullanıcılarımızdan topladığımız kişisel bilgilerin nasıl işlendiğini, saklandığını ve korunduğunu açıklamaktadır.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
        
                    // Toplanan Bilgiler
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2.Toplanan Bilgiler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Uygulamamız, yalnızca aşağıdaki kişisel bilgileri toplamaktadır: - İsim \n- Soyisim \n- E-posta adresi \n- Adres \nBu bilgiler, yalnızca uygulamanın sunduğu hizmetlerin sağlanması ve kullanıcıların ihtiyaçlarının karşılanması amacıyla toplanmaktadır.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
        
                    // Kişisel verilerin kullanımı
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3.Kişisel Verilerin Kullanımı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Kişisel bilgileriniz, aşağıdaki amaçlarla kullanılabilir: \n- Uygulama üzerinden rezervasyon ve iletişim süreçlerini yönetmek. \n- Kullanıcı destek taleplerine yanıt vermek. \n- Hizmetle ilgili duyurular veya bilgilendirmeler yapmak (örneğin, rezervasyon onayları).'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
        
                    // Kişisel verilen korunması
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4.Kişisel Verilerin Korunması',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Kiralık Kaleci, kullanıcıların kişisel verilerinin güvenliğini sağlamak için gerekli tüm teknik ve idari önlemleri almaktadır. Toplanan bilgiler: \n- Yetkisiz erişime, değiştirilmeye, ifşaya veya imhaya karşı korunmaktadır. \n- Yalnızca yetkili personel veya hizmetin sağlanması için gerekli taraflarla paylaşılabilir.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
        
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5.Üçüncü Tarafla Paylaşımı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                         ' Kişisel bilgileriniz, aşağıdaki durumlar dışında üçüncü kişilerle paylaşılmaz: \n- Kanuni bir yükümlülük gereği bilgilerinizin açıklanmasının zorunlu olduğu durumlarda. \n- Kullanıcı sözleşmesinin gereklerini yerine getirmek amacıyla. \n- Yetkili adli ve idari makamlar tarafından talep edilmesi halinde.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Ip adresleri ve çerezler
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6.IP Adresleri ve Çerezler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Uygulama, kullanıcıların IP adreslerini yalnızca güvenlik amacıyla ve sorunların çözümüne yardımcı olmak için kaydedebilir. Ayrıca, uygulama deneyimini iyileştirmek ve tercihlerinizi saklamak amacıyla çerezler kullanılabilir.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Kullanıcı hakları
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7.Kullanıcı Hakları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Kullanıcılar, uygulama aracılığıyla paylaşmış oldukları kişisel bilgilerin: \n- Düzeltilmesini, güncellenmesini veya silinmesini talep edebilirler. \n- Kişisel veri işleme faaliyetlerine itiraz etme hakkına sahiptirler.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Kredi kartı bilgileri
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '8.Kredi Kartı Bilgileri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          'Uygulama, kredi kartı bilgilerini toplamaz veya saklamaz. Ödeme işlemleri, güvenilir üçüncü taraf ödeme sağlayıcıları üzerinden gerçekleştirilir.'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Politika değişiklikleri
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '9.Politika Değişiklikleri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Kiralık Kaleci, bu Gizlilik ve Güvenlik Politikası’nda değişiklik yapma hakkını saklı tutar. Yapılan değişiklikler, uygulamada yayımlandığı tarihte yürürlüğe girer..'
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '10.İletişim',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Gizlilik politikamız hakkında sorularınız veya talepleriniz için bizimle iletişime geçebilirsiniz: \n- E-posta: kiraliikkalecii@gmail.com \nBu Gizlilik ve Güvenlik Politikası, kullanıcılarımızın hak ve güvenliğini korumak adına hazırlanmıştır. Politika hükümlerine uygun hareket ettiğimizden emin olabilirsiniz.'
                        )
                      ],
                    ),
                    const SizedBox(height: 80)
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