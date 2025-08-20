import 'package:hive/hive.dart';
part 'football_field.g.dart';

@HiveType(typeId: 0)
class FootballField {
  @HiveField(0)
  final String city;
  @HiveField(1)
  final String district;
  
  @HiveField(2)
  final List<String> fieldName;

  FootballField({
    required this.city,
    required this.district,
    required this.fieldName
  });

  //todo: Bunu sadece istanbul yap
  static Future<void> storeFields() async {
  var localDb = await Hive.openBox<FootballField>('football_fields');

  // Clear existing data
  await localDb.clear();

  // Define data with cities and districts
  final List<FootballField> fields = [
    // ADANA
    /*
    FootballField(
      city: 'Adana',
      district: 'Çukurova',
      fieldName: ['Adana Fair Play Halı Saha','Adana Park Arena Halı Saha','Adana Şirin Halı Saha','Adana Star Halı Saha','Adana Rakip Halı Saha','Adana Libero Halı Saha','Elsam Halı Saha','Olimpos Kenan Evren Halı Saha','Adana Olimpos Halı Saha','Adana Akdeniz Halı Saha','Adana Göl Arena Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'İmamoğlu',
      fieldName: ['İmamoğlu Çakıroğlu Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Karaisalı',
      fieldName: ['Çeçeli Park Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Kozan',
      fieldName: ['Kozan Ünsal Halı Saha','Gültekin Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Sarıçam',
      fieldName: ['Sarıçam Çakıroğlu Halı Saha','Sarıçam Ünsal Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Seyhan',
      fieldName: ['Adana Kelebek Halı Saha','Adana Güler Halı Saha','Seyhan Ayyıldız Halı Saha','Adana Sular Halı Saha','Seyhan Dikili Arena Halı Saha','Volkan Halı Saha','Yeşilyurt Ünsal Halı Saha','Adana Özdemir Halı Saha','Adana Zöhre 2 Halı Saha','Adana Zöhre 1 Halı Saha','Çağdaş Halı Saha'],
    ),
    FootballField(
      city: 'Adana',
      district: 'Yüreğir',
      fieldName: ['Yüreğir Nehir Halı Saha','Adana Afşin Halı Saha','Yüreğir Gençlerbirliği Halı Saha','Solaklı Kartal Halı Saha'],
    ),
    // ADIYAMAN
    FootballField(
      city: 'Adıyaman',
      district: 'Kahta',
      fieldName: ['Adıyaman Kahta Baraj Halı Saha','Kahta Belediye Halı Saha','Kahta Olimpik Halı Saha','Kahta Arıkent Halı Saha','Doğukent Spor Tesisleri Halı Saha','Kahta Narince Halı Saha'],
    ),
    FootballField(
      city: 'Adıyaman',
      district: 'Merkez',
      fieldName: ['Adıyaman Göksu Halı Saha'],
    ),
    FootballField(
      city: 'Adıyaman',
      district: 'Sincik',
      fieldName: ['Sincik Esat Halı Saha'],
    ),
    // AFYONKARAHİSAR
    FootballField(
      city: 'Adıyaman',
      district: 'Bolvadin',
      fieldName: ['Bolvadin Akcan Arena Halı Saha'],
    ),
    FootballField(
      city: 'Ağrı',
      district: 'Merkez',
      fieldName: ['Ağrı Akademi Halı Saha','Ağrı Öğretmenler Lisesi Halı Saha','Ağrı Kral 2 Halı Saha','Ağrı Kral 4 Halı Saha'],
    ),
    // AKSARAY
    FootballField(
      city: 'Aksaray',
      district: 'Merkez',
      fieldName: ['Aksaray Şampiyon Halı Saha','Aksaray Futbol Park Halı Saha','Aksaray Maraton Halı Saha','Aksaray Metropol Halı Saha','Aksaray Golz Halı Saha','Aksaray Fanatik Halı Saha'],
    ),
    // AMASYA
    FootballField(
      city: 'Amasya',
      district: 'Gümüşhacıköy',
      fieldName: ['Amasya Naturel Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Merkez',
      fieldName: ['Amasya Arena Halı Saha','Amasya Çamlık Halı Saha','Amasya Final Halı Saha','Amasya Çırağan Halı Saha','Sporium05 Halı Saha','Ziyaret Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Merzifon',
      fieldName: ['Merzifon Balkaya Halı Saha','Özdilek Halı Saha']
    ),
    FootballField(
      city: 'Amasya',
      district: 'Suluova',
      fieldName: ['Suluova Şerifzade Halı Saha','Suluova Şeref Halı Saha']
    ),
    // ANKARA
    FootballField(
      city: 'Ankara',
      district: 'Altındağ',
      fieldName: ['Ankara Altınpark Halı Saha']
    ),
    FootballField(
      city: 'Ankara',
      district: 'Çankaya',
      fieldName: ['Yüzünce Yıl Saklıbahçe Halı Saha','Dikmen Merkez Halı Saha','100.yıl Kılıçaslan Halı Saha','Atatürk Anadolu Lisesi Halı Saha','Çankaya Halı Saha','Kurtuluş Parkı Halı Saha','Mesa Koru Halı Saha','Doktorlar 1 Halı Saha','Doktorlar 2 Halı Saha','Talatpaşa Halı Saha','Canberk Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Çubuk',
      fieldName: ['Topkapı Halı Saha Çubuk','Saklı Bahçe Halı Saha Çubuk','Çubuk Spor Halı Saha','Esenboğa Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Etimesgut',
      fieldName: ['Şaşmaz Halı Saha Etimesgut'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Gölbaşı',
      fieldName: ['Gölbaşı Şen Halı Saha','Kampüs Arena Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Kahramankazan',
      fieldName: ['Kahramankazan Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Keçiören',
      fieldName: ['Keçiören Halı Saha','Meteoroloji Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Mamak',
      fieldName: ['Ankara Yıldız Arena Halı Saha','Mamak Birlik Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Nallıhan',
      fieldName: ['Çayırhan Diriliş Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Pursaklar',
      fieldName: ['Avrupa Birliği Parkı Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Sincan',
      fieldName: ['Kırmızı Beyaz Spor Halı Saha'],
    ),
    FootballField(
      city: 'Ankara',
      district: 'Yenimahalle',
      fieldName: ['Batıkent Futbol Park Halı Saha','Yenimahalle Aybesk Halı Saha','Batıkent Arena Halı Saha','Altınbatı Spor Tesisleri Halı Saha'],
    ),
    // ANTALYA
    FootballField(
      city: 'Antalya',
      district: 'DöşemeAltı',
      fieldName: ['44 Demir Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kemer',
      fieldName: ['Çamyuva Meydan Halı Saha','Kemer İdman Yurdu Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kepez',
      fieldName: ['Akev Halı Saha','Pınar Halı Saha','Akdeniz Park Halı Saha','Antalya Tellioğlu Halı Saha','Maç 2000 Halı Saha','Olimpik Halı Saha Kepez','Çamlıbel Halı Saha Kepez','Altınova Halı Saha Kepez','Kepez Ostima Halı Saha','Kepez Şahin Halı Saha','Kepez Şelale Halı Saha','Kepez Koçlar Halı Saha','Gaziler Park Halı Saha'],
    ),
    FootballField(
      city: 'Antalya',
      district: 'Konyaaltı',
      fieldName: ['Cüneyt Çakır Halı Saha','Sporland Halı Saha Antalya']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Kumluca',
      fieldName: ['Bey-kum Halı Saha','Kumluca Maraton Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Manavgat',
      fieldName: ['Manavgat Tatava Halı Saha','Manavgat Birlik Halı Saha Antalya','Manavgat Maraton Arena Halı Saha','Manavgat Sorgun Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Muratpaşa',
      fieldName: ['Levent Kartop Halı Saha','Karnaval Halı Saha']
    ),
    FootballField(
      city: 'Antalya',
      district: 'Serik',
      fieldName: ['Serik Ozan Halı Saha','Serik Bildirler Halı Saha']
    ),
    // ARTVİN
    FootballField(
      city: 'Artvin',
      district: 'Merkez',
      fieldName: ['Artvin Yıldırım Halı Saha','Artvin Utku Halı Saha']
    ),
    // AYDIN
    FootballField(
      city: 'Aydın',
      district: 'Buharkent',
      fieldName: ['Park Cafe Halı Saha','Buharkent Atatürk Şehir Parkı Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Didim',
      fieldName: ['Didim Arena Anadolu Halı Saha','Didim Park Halı Saha','Aytepe Halı Saha','Dididm Yiğit Spor Halı Saha','Didim Arena Turizm Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Efeler',
      fieldName: ['Aydın Çeştepe Halı Saha','Aydın Deport Athletics Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'İncirliova',
      fieldName: ['İncirliova Görkem Halı Saha','İncirliova Erbeyli Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Kuşadası',
      fieldName: ['Kuşadası Derici Halı Saha','Kuşadası Mutlu Halı Saha','Kuşadası Davutlar Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Nazilli',
      fieldName: ['Nazilli Halı Saha','Nazilli Halı Sahalar','Nazilli Açık Halı Saha','Şehitler Halı Saha','Özkatlar Halı Saha']
    ),
    FootballField(
      city: 'Aydın',
      district: 'Söke',
      fieldName: ['Söke Yaşam Park Kapalı Halı Saha','Söke Fatih Halı Saha','Söke Kolej Halı Saha','Söke Korsanlar Halı Saha']
    ),
    // BALIKESİR
    FootballField(
      city: 'Balıkesir',
      district: 'Altıeylül',
      fieldName: ['Park Halı Saha','Nef Halı Saha','Flaş Halı Saha','Korner Halı Saha Sosyal Tesisleri']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Ayvalık',
      fieldName: ['Aymeyo Spor Kompleksi Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Bandırma',
      fieldName: ['Nazende Halı Saha','Panormos Halı Saha','Selvi Halı Saha','Duru Halı Saha Livatya','Gelişim Halı Saha','Marmara Halı Saha','Bandırmagücü Melis Halı Saha','Edincik Santra Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Burhaniye',
      fieldName: ['Sporium Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Edremit',
      fieldName: ['Dağ Halı Saha Edremit','Akçay Vole Halı Saha','Edremit Aki Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Gönen',
      fieldName: ['Gönen Sporium Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'İvrindi',
      fieldName: ['Balıkesir Çakır Halı Saha']
    ),
    FootballField(
      city: 'Balıkesir',
      district: 'Karesi',
      fieldName: ['Karesi Deplasman Halı Saha']
    ),
    // BARTIN
    FootballField(
      city: 'Bartın',
      district: 'Merkez',
      fieldName: ['Santra Halı Saha','Bartın Arena Halı Saha','Yaşam Park Halı Saha','Küre Sporyum Halı Saha','Bartın Güven Halı Saha','Akyemişler Halı Saha']
    ),
    // BATMAN
    FootballField(
      city: 'Batman',
      district: 'Gercüş',
      fieldName: ['Gercüş Arena Halı Saha']
    ),
    FootballField(
      city: 'Batman',
      district: 'Merkez',
      fieldName: ['Batman Arena Halı Saha','MBA Halı Saha','Batman Boğaziçi Halı Saha','Batman Şampiyon Halı Saha','Batman Olimpiyat Halı Saha']
    ),
    // BAYBURT
    FootballField(
      city: 'Bayburt',
      district: 'Merkez',
      fieldName: ['Bayburt Arena Halı Saha']
    ),
    // BİLECİK :)
    FootballField(
      city: 'Bilecik',
      district: 'Osmaneli',
      fieldName: ['Lefke Arena Halı Saha']
    ),
    // BİNGÖL
    FootballField(
      city: 'Bingöl',
      district: 'Merkez',
      fieldName: ['Bingöl Gül Halı Saha','Bingöl Sultan Sarayı Halı Saha','Ahmet Dursun Halı Saha']
    ),
    FootballField(
      city: 'Bingöl',
      district: 'Solhan',
      fieldName: ['Ayça Halı Saha 2']
    ),
    // BOLU
    FootballField(
      city: 'Bolu',
      district: 'Merkez',
      fieldName: ['Soysal Spor Halı Saha','Bolu Olimpik Halı Saha','Ali Baba Halı Saha','Bolu Futbol Park 14 Halı Saha','Bolu Spor Halı Saha']
    ),
    // BUCAK
    FootballField(
      city: 'Burdur',
      district: 'Bucak',
      fieldName: ['Bucak Maraton Arena Halı Saha']
    ),
    FootballField(
      city: 'Burdur',
      district: 'Merkez',
      fieldName: ['Burdur Altıpas Halı Saha','Yeşil Çimen Halı Saha','Burdur Arena Halı Saha','Burdur Spor Park Halı Saha','Burdur Santra Halı Saha']
    ),
    FootballField(
      city: 'Burdur',
      district: 'Tefenni',
      fieldName: ['Tefenni Belediye Halı Saha']
    ),
    // BURSA
    FootballField(
      city: 'Bursa',
      district: 'İnegöl',
      fieldName: ['İnegöl Kafkas Halı Saha','Gençlergücü Halı Saha','İnegöl Zadeler Halı Saha','İnegöl Doğan Halı Saha','İnegöl Kurtuluş Halı Saha','Gümüş Halı Saha İnegöl','Alanyurt Kocatepe Halı Saha','Sanayi Açık Kafkas Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Mudanya',
      fieldName: ['Bursa Timsaha Halı Saha','Çamlık Park Halı Saha Mudanya']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Nilüfer',
      fieldName: ['Ataevler Halı Saha','BPFDD Şükrü Şankaya Futbol Halı Saha','Görükle Oruç Halı Saha','Nilüfer Asya Halı Saha','Çamlıca Halı Saha Nilüfer','Nilüfer Özcan Halı Saha','Nilüfer Egemen Halı Saha','Özlüce Timsaha Halı Saha','Metropol Odunluk Halı Saha','Metropol Doğanköy Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Osmangazi',
      fieldName: ['Altınceylan Timsaha Halı Saha','Bursa Pınarbaşı Halı Saha','As Futbol Park Halı Saha','Bursa Anadolu Lisesi Halı Saha','Osmangazi Arena Halı Saha','Korkut Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Yenişehir',
      fieldName: ['Yenişehir Santra Halı Saha']
    ),
    FootballField(
      city: 'Bursa',
      district: 'Yıldırım',
      fieldName: ['Erikli Halı Saha Yıldırım','Yıldırım Ayyıldız Halı Saha','Atletik Halı Saha','Mimar Sinan Halı Saha','Şükraniye Spor Halı Saha','Mimar Sinan Gençlik ve Spor Halı Saha','Kafe Kafkas Halı Saha']
    ),
    // ÇANAKKALE
    FootballField(
      city: 'Çanakkale',
      district: 'Biga',
      fieldName: ['Havuz Kafe Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'Gelibolu',
      fieldName: ['Gelibolu Dost Halı Saha','Gelibolu 18 Mart Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'İmroz',
      fieldName: ['İmroz Halı Saha']
    ),
    FootballField(
      city: 'Çanakkale',
      district: 'Merkez',
      fieldName: ['Çanakkale Teknopark Halı Saha','Dabakoğlu Halı Saha','TRCUP Deniz Halı Saha','Kepez Spor Halı Saha']
    ),
    // ÇANKIRI
    FootballField(
      city: 'Çankırı',
      district: 'Kurşunlu',
      fieldName: ['Kurşunlu Halı Saha']
    ),
    FootballField(
      city: 'Çankırı',
      district: 'Merkez',
      fieldName: ['Çankırı Aksu Halı Saha','Çankırı Sporyum Halı Saha','Çankırı Akasya Halı Saha']
    ),
    // DENİZLİ
    FootballField(city: 'Denizli', district: 'Çivril', fieldName: ['Çivril Arena Halı Saha']),
    FootballField(city: 'Denizli', district: 'Merkezefendi', fieldName: ['Beyazıt Sport Eren Halı Saha','Beyazıt Sport Kolej Halı Saha','Beyazıt Sport Denizli Arena Halı Saha','Denizli Sporium Halı Saha','Berkay 75.yıl Halı Saha Tesisleri','Denizli Koleji Halı Saha','Beyazıt Spor Aydem Beyaz Halı Saha','Mustafa Kaynak Lisesi Halı Saha','Cinkaya Halı Saha','Denizli Aslantepe Spor Tesisleri']),
    FootballField(city: 'Denizli', district: 'Pamukkale', fieldName: ['Denizli Reel Halı Saha']),
    // DİYARBAKIR
    FootballField(
      city: 'Diyarbakır',
      district: 'Bağlar',
      fieldName: ['Diyarbakır Göksü Halı Saha','Miryıldız Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Bismil',
      fieldName: ['Merkez Dolay Halı Saha','Nokta Dolay Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Kayapınar',
      fieldName: ['Club Marduk Halı Saha']
    ),
    FootballField(
      city: 'Diyarbakır',
      district: 'Yenişehir',
      fieldName: ['Diyarbakır Toki Arena Halı Saha','Tulip Anka Park Halı Saha','Özbek Halı Saha']
    ),
    // DÜZCE
    FootballField(
      city: 'Düzce',
      district: 'Cumayeri',
      fieldName: ['Cumayeri Gözde Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Gölkaya',
      fieldName: ['Gölkaya Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Kaynaşlı',
      fieldName: ['Kaynaşlı Akif Demir Halı Saha']
    ),
    FootballField(
      city: 'Düzce',
      district: 'Merkez',
      fieldName: ['Düzce Alpay Halı Saha','Düzce Stadyum Halı Saha','Genç Halı Saha','Düzce Ayyıldız Halı Saha','Fettah Bey Halı Saha','Düzce Zafer Halı Saha','Düzce Elit Halı Saha','Dü Spor Tesisleri']
    ),
    // EDİRNE
    FootballField(
      city: 'Edirne',
      district: 'Keşan',
      fieldName: ['Uygunlar Halı Saha','Uygunlar F.M Çuhacı Halı Saha','Arena Keşan Halı Saha']
    ),
    // ELAZIĞ
    FootballField(
      city: 'Elazığ',
      district: 'Merkez',
      fieldName: ['Elazığ Menekşe Halı Saha','Elazığ LaLiga Halı Saha','Elazığ Fair Play Halı Saha','Elazığ Futbol Times Halı Saha','Elazığ Sporium 23 Halı Saha','Elazığ Amsterdam Halı Saha']
    ),
    // ERZİNCAN
    FootballField(
      city: 'Erzincan',
      district: 'Merkez',
      fieldName: ['Okumuşlar Halı Saha']
    ),
    // ERZURUM
    FootballField(
      city: 'Erzurum',
      district: 'Aziziye',
      fieldName: ['Erzurum Bora Park Halı Saha']
    ),
    FootballField(
      city: 'Erzurum',
      district: 'Oltu',
      fieldName: ['Topaloğulları Halı Saha']
    ),
    FootballField(
      city: 'Erzurum',
      district: 'Yakutiye',
      fieldName: ['Erzurum Çimsa Halı Saha']
    ),
    // ESKİŞEHİR
    FootballField(
      city: 'Eskişehir',
      district: 'Odunpazarı',
      fieldName: ['EskiŞehir Şah Halı Saha','Es Spor Halı Saha','Es Planet Halı Saha','Es Es Halı Saha Kanlıkavak','Borapark Ömür Halı Saha','Borapark Osmangazi Halı Saha','Sporland Halı Saha','Eskişehir Demir Spor Halı Saha','Eskişehir Deniz Halı Saha']
    ),
    FootballField(
      city: 'Eskişehir',
      district: 'Tepebaşı',
      fieldName: ['Aysu Halı Saha','Ekol Halı Saha']
    ),
    // GAZİANTEP
    FootballField(
      city: 'GaziAntep',
      district: 'Nizip',
      fieldName: ['Nizip Özkayan Halı Saha','Nizip Tuncay Birlik Halı Saha','Nizip Çetin Halı Saha']
    ),
    FootballField(
      city: 'GaziAntep',
      district: 'Şahinbey',
      fieldName: ['Gaziantep Gazişehir Halı Saha','Arena Karataş Halı Saha','Gaziantep Reform Halı Saha','Sefa Spor Central Halı Saha','Karataş Gülşen Batar Halı Saha','Classis Garden Halı Saha']
    ),
    // GİRESUN
    FootballField(
      city: 'Giresun',
      district: 'Görele',
      fieldName: ['Görele İskele Halı Saha']
    ),
    FootballField(
      city: 'Giresun',
      district: 'Merkez',
      fieldName: ['Giresun Arena 1 Kapalı Halı Saha','Giresun Arena 28 Kapalı Halı Saha']
    ),
    FootballField(
      city: 'Giresun',
      district: 'Şebinkarahisar',
      fieldName: ['Best Arena Halı Saha','Fasıl Arena Halı Saha']
    ),
    // GÜMÜŞHANE
    FootballField(
      city: 'Gümüşhane',
      district: 'Kelkit',
      fieldName: ['Osmanlı Halı Saha','Hasan Basri Halı Saha']
    ),
    FootballField(
      city: 'Gümüşhane',
      district: 'Merkez',
      fieldName: ['Gümüşhane Kanka Halı Saha','Gümüşhane Şampiyon Halı Saha','Gümüşhane Arena Halı Saha','Gümüşball Halı Saha']
    ),
    FootballField(
      city: 'Gümüşhane',
      district: 'Şiran',
      fieldName: ['Şiran Gözde Halı Saha']
    ),
    // HAKKARİ
    FootballField(
      city: 'Hakkari',
      district: 'Şemdinli',
      fieldName: ['Hakkari Final Halı Saha','Hakkari Kaya Halı Saha']
    ),
    FootballField(
      city: 'Hakkari',
      district: 'Yüksekova',
      fieldName: ['Dicle Arena Halı Saha','Durna Halı Saha','Aykutlar Halı Saha']
    ),
    // HATAY
    FootballField(
      city: 'Hatay',
      district: 'Antakya',
      fieldName: ['Nisnengi Kampüs Halı Saha Arena','Antakya Defne Halı Saha','Antakya Altın Evler Halı Saha','Antakya Show  Halı Saha','Nisnengi Karaali  Halı Saha','Antakya Kahraman  Halı Saha','Hatay Saraykent  Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Arsuz',
      fieldName: ['Arsuz Sözer Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Defne',
      fieldName: ['Defne Deniz Halı Saha','Defne Harbiye Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Dörtyol',
      fieldName: ['Dörtyol Kapalı Halı Saha','Kuzuculu Kapalı Halı Saha','Berat Kapalı Halı Saha','Gazi Kapalı Halı Saha','İlk Kurşun Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'İskenderun',
      fieldName: ['İskenderun Vipark Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Kırıkhan',
      fieldName: ['Kırıkhan Zambak Arena Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Payas',
      fieldName: ['Payas Ejder Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Reyhanlı',
      fieldName: ['Reyhanlı Cem Halı Saha','Reyhanlı Zirve Halı Saha','Reyhanlı Enver Halı Saha','Reyhanlı Arena Halı Saha','']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Samandağ',
      fieldName: ['Karaçay Yüksel Halı Saha']
    ),
    FootballField(
      city: 'Hatay',
      district: 'Samandağ',
      fieldName: ['Yayladağı Tunç Halı Saha','Üçbeyleri Halı Saha']
    ),
    // IĞDIR
    FootballField(
      city: 'Iğdır',
      district: 'Merkez',
      fieldName: ['Iğdır Vip Class Halı Saha','Iğdır Santral Halı Saha','Iğdır Arena Halı Saha','Iğdır Akademir Halı Saha','Iğdır Gonca Halı Saha','Iğdır Lider Halı Saha']
    ),
    // ISPARTA
    FootballField(
      city: 'Isparta',
      district: 'Merkez',
      fieldName: ['Isparta Sporland Halı Saha','Isparta Demirköprü Halı Saha','Isparta Batıkent Halı Saha','Isparta Fairplay Halı Saha','Yeşil Krampon Halı Saha','Isparta Fatih Halı Saha','Isparta Mavikent Halı Saha','Isparta Arena Park Halı Saha']
    ),
    */
    // İSTANBUL
    FootballField(
      city: 'İstanbul',
      district: 'Arnavutköy',
      fieldName: ['Bolluca Halı Saha','Tellioğlu Halı Saha','Vadi Park Halı Saha','Hadımköy Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Ataşehir',
      fieldName: ['Ferhatpaşa Halı Saha','Umut Halı Saha','Ataşehir Tesisleri','Garden Park Halı Saha','Ataşehir Halı Saha','Biral Halı Saha','Futbol Merkezi Halı Saha','Galatasaray Taç Spor Halı Saha','Atapark Halı Saha','Ferhatpaşa Sportif Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Avcılar',
      fieldName: ['Avcılar Halı Saha','Bahçeşehir Ergün Penbe Halı Saha','Avcılar Olimpik Halı Saha','Dost Halı Saha','Avcılar Park Halı Saha','Avcılar Şahin Halı Saha','Avcılar Maraton Halı Saha','Bay Gol Halı Saha','Avcılar 1 Halı Saha','Avcılar EML Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Bağcılar',
      fieldName: ['Bağcılar Ayar Halı Saha','Bağcılar Doğuş Halı Saha','Üçler Halı Saha','Cfs Bağcılar Halı Saha','Mahmutbey Halı Saha','Bağcılar Ayyıldız Spor Tesisleri']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Bahçelievler',
      fieldName: ['Burak Halı Saha','Çağrı Halı Saha | BFA','Ayar Halı Saha','Kocasinan Arena Halı Saha','Erkan Avcı Halı Saha','B.evler Olimpik Halı Saha','Bahçelievler Esim Halı Saha','Şirinevler Spor Kulübü Halı Saha','Bahçelievler Best Halı Saha','Yaşam Halı Saha Bahçelievler']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Bakırköy',
      fieldName: ['Çiroz Halı Saha','Kartaltepe Spor Kulübü Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Başakşehir',
      fieldName: ['Başakşehir Ergün Penbe Halı Saha','Euro Futbol Halı Saha','Ekol Halı Saha','Başak Kapalı Halı Saha','Başakşehir Spor Parkı Halı Saha','Güvercintepe Spor Parkı Halı Saha','Ayazma İMKB Halı Saha','Başakşehir SK. Halı Saha','Borsa İstanbul Halı Saha','Aktaş Halı Saha','Aymakoop Kapalı Halı Saha','Red White Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Bayrampaşa',
      fieldName: ['Bayrampaşa Arena','Mega Halı Saha','Mehmet Akif Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Beşiktaş',
      fieldName: ['Akatlar Halı Saha','Stop Halı Saha','Etiler Halı Saha','Muradiye Gençler Birliği Halı Saha','Dikilitaş SK Halı Saha','Beşiktaş 34Football Center Halı Saha','Etiler Natural Park Halı Saha','Ziya Kalkavan Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Beykoz',
      fieldName: ['Yunus Emre Spor Tesisleri','Göksu Arena Halı Saha','Merkez Halı Saha','Kavacık S.K Halı Saha','Soğuksu Halı Saha','Paşabahçe Halı Saha','Çavuşbaşı Halı Saha','Gümüşsuyu SK Halı Saha','Omka Halı Saha','Beykoz Özdemir Halı Saha','Beykoz Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Beylikdüzü',
      fieldName: ['Beylikdüzü Siteler Halı Saha','For Life Sport Center','Yakuplu Burak Halı Saha','Gürpınar Arena Halı Saha','Erhaya Spor Halı Saha','Beylikdüzü Allstar Halı Saha','Playdrome Halı Saha','Erbabi Halı Saha','Marina Halı Saha','Serter Halı Saha','Modern Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Beyoğlu',
      fieldName: ['Beyoğlu Star Halı Saha','Fetih Spor Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Büyükçekmece',
      fieldName: ['Final Halı Saha','Cihangir Halı Saha','Olis Halı Saha','Elit Halı Saha','Spor City Halı Saha','World Point Halı Saha','Gümüş Halı Saha','Şafak Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Çatalca',
      fieldName: ['Çatalca Merkez Arena Halı Saha','Atatürk Spor Kompleksi Halı Saha', 'Çatalca Merkez']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Çekmeköy',
      fieldName: ['Günaydın Halı Saha','Çekmeköy Teras Halı Saha','Taşdelen Arena Halı Saha','Orman Park Halı Saha','Çekmeköy Belediye Spor Kulübü Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Esenler',
      fieldName: ['Topçuoğlu Halı Saha-2 ','Taştanlar Spor Tesisleri','Seymen Halı Saha','Esenler Aşiyan Halı Saha','Esenler Kayalr Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Esenyurt',
      fieldName: ['Gaziler Halı Saha','Esenyurt Allstar Halı Saha','Kıraç Euro Futbol Halı Saha','Gözde Halı Saha','Bizim Vadi Halı Saha','EFT Halı Saha','Kaya Halı Saha','Esenyurt Yeşi Vadi Halı Saha','Armada Halı Saha','Esenyurt Fabi Halı Saha','Debey Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Eyüpsultan',
      fieldName: ['Rami Halı Saha','Eyüp Halı Saha','Akşemsettin SK Halı Saha','Eyüp Halı Saha','Alibeyköy Öztürkler Halı Saha','Pierre Loti Spor Tesisleri Halı Saha','Giresun Emeksan Spor Kulübü Halı Saha','Öz Alibeyköy Spor Kulübü Halı Saha','Alibeyköy Spor Kulübü Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Fatih',
      fieldName: ['Fatih Oktaylı Halı Saha','Fatih Görkem Halı Saha','Fatih Zigana Halı Saha','Altınay Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Gaziosmanpaşa',
      fieldName: ['Özkartal Arena Halı Saha','Beşyüzevler Halı Saha','Küçükköy EML Halı Saha','Validesuyu Halı Saha','Albayrak Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Güngören',
      fieldName: ['Güngören Oktay Halı Saha 1','Güngören Oktay Halı Saha','Lider Spor Tesisleri Halı Saha','Şampiyon90 Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Kadıköy',
      fieldName: ['Göztepe Spor Tesisleri Halı Saha','Salı Pazarı Halı Saha','Haydarpaşa EML Halı Saha','Hakan Halı Saha Spor Tesisleri','Cebir Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Kağıthane',
      fieldName: ['Profilo Halı Saha','İhkib AY-TU Halı Saha','VIP Halı Saha','Hasbahçe Halı Saha','Seyrangah Halı Saha','Demir Halı Saha','Seyrantepe Halı Saha','Demir Tekli Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Kartal',
      fieldName: ['Yunus Arena Halı Saha','Kartal Halı Saha Spor Tesisleri','Öncü Halı Saha','Uğur Mumcu Halı Saha','Esentepe Yeşilyurt Halı Saha','Kartal Topselvi Halı Saha','Yakacık Halı Saha','Yakacık Meslek Royal Halı Saha','Vega Halı Saha','Kartal Safir Halı Saha','Kartal Bulvar Spor Halı Saha','Kartal Anadolu Halı Saha','Soğanlık Halı Saha','Oksijen Halı Saha','Kartal Soğanlık Cesur Halı Saha','Kartal Atalar Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Küçükçekmece',
      fieldName: ['Dörtler Halı Saha','Futbol Center Halı Saha','Efor Halı Saha','İst.Atakent SK Halı Saha','Nihat Yüceur Spor Kompleksi Halı Saha','Birlik Halı Saha','Seçkin Marakana Halı Saha','Fevzi Çakmak Halı Saha','Seçkin Marakana 2 Halı Saha','Hayat Park Halı Saha','Kanarya Stadı Halı Saha','Metin Oktay Stadı']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Maltepe',
      fieldName: ['Ay Işığı Halı Saha','Zümrüt Evler Halı Saha','Maltepe Spor Halı Saha','Girnespor Halı Saha','Tempo Halı Saha','Dragos Futbol Halı Saha','Aydınoğlu Halı Saha','Gold Halı Saha','Yeditepe VIP Halı Saha','Gülensu Halı Saha','Esenkent Halı Saha Maltepe']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Pendik',
      fieldName: ['Kurtköy Arena Halı Saha','Aydın Oral Spor Tesisleri Halı Saha','Aynaoğlu Halı Saha','Pendik Çelik Halı Saha','Pendik Emek SK Halı Saha','Şeyhli Toki Halı Saha','Pendikgücü Halı Saha','PKS Halı Saha','Pendik Velibaba Spor Tesisleri Halı Saha','Pendik İstek Halı Saha','Kurtköy Spor Kulübü Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Sancaktepe',
      fieldName: ['Dolunay Halı Saha','Zigana Halı Saha','Zigana Halı Saha - 2','Başak Halı Saha','Uşaklıgil Halı Saha','Gençler Halı Saha','Laliga Halı Saha','Lokman Ergen Halı Saha','Gök Arena Halı Saha','Akademirpark Halı Saha','Alg Arena Halı Saha','Ekin Halı Saha','Sancaktepe Maraton Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Sarıyer',
      fieldName: ['Yeniköy Spor Kulübü - Bağlar','Yeniköy Spor Kulübü - Sahil','Esen Spor Halı Saha','Aktif Halı Saha','Poligon Halı Saha','İstinye Halı Saha','Kireçburnu SK Halı Saha','Baltalimanı Halı Saha','Sarıyer Park Halı Saha','Sarıyer SK Halı Saha','Reşitpaşa SK Halı Saha','Tarabya Spor Kulübü Halı Saha','Ferahevler Spor Kulübü Halı Saha','Dallas Halı Saha','Maslak Garden Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Silivri',
      fieldName: ['Silivri Agena 1 Merkez Halı Saha','Silivri Agena 2 Halı Saha','Silivri Efe Spor Tesisleri Halı Saha','Silivri Şahin Spor Tesisleri','Marmara İdmanyurdu Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Şişli',
      fieldName: ['Feriköy Halı Saha','Zincirlikuyu Halı Saha','Taksim SK Halı Saha','Kuştepe Halı Saha','Şişli Halı Saha','Şişli Olimpia Halı Saha','Mahmut Şevket Paşa Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Şile',
      fieldName: ['Şile İlçe Stadı','Olimpia Halı Saha','Kumbaba Spor Kompleksi','Seri Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Sultanbeyli',
      fieldName: ['Cihan Halı Saha','Merkez Arena Halı Saha','Alaz Spor Tesisi','Sultanbeyli Tellioğlu Halı Saha','Ülker Halı Saha','Sultanbeyli Yıldırım Halı Saha','Nur Center Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Sultangazi',
      fieldName: ['Sultangücü SK Halı Saha','Lider Yılmazlar Halı Saha','Sultangazi SK Halı Saha','Sultangazi Esentepe SK Halı Saha','Gazi Mahallesi SK Halı Saha','Zara Ekinli SK Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Tuzla',
      fieldName: ['Tuzla Bel. Mercan Halı Saha','Tuzla Bel. Orhanlı Halı Saha','Dede Korkut Halı Saha','Orhanlı Okyanus Halı Saha','Kaan Halı Saha','Bahçe Cafe Halı Saha','Berat Tuzla Halı Saha','Tuzla Halı Saha','Fatih Halı Saha','Tuzla Belediyesi Şifa Halı Saha','Tuzla Meslek Lisesi Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Ümraniye',
      fieldName: ['İmes Tuntaş Halı Saha','Asil Halı Saha','Mengiroğlu Halı Saha','Futbol Park Halı Saha','Cengiz Topel Halı Saha', 'Ortaklar Halı Saha','Şal Arena Halı Saha', 'Ümraniye Lisesi Halı Saha','Topçuoğlu Halı Saha','Dudullu Halı Saha','Atalı Spor Tesisleri','Spor Center Halı Saha','Okyanus Halı Saha','Atakent Akademi Halı Saha','Birey Koleji Halı Saha','Dudullu 2 Halı Saha','Karabekir Halı Saha','Çakmak Spor Halı Saha','Kemerdere Spor Tesisleri Halı Saha','Dudullu Arena Halı Saha','Doğa Orman Park Halı Saha','Hazal Halı Saha','Atakent Ümraniye Spor Halı Saha','Kadosan Halı Saha','Yamanevler Avrupa Konutları Halı Saha'
      ]
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Üsküdar',
      fieldName: ['Şahin Spor Tesisleri','Ekspres Halı Saha','Bağlarbaşı Spor Kulübü Tesisleri','Çamlıca Spor Kulübü','Uçar Halı Saha','Ufuk Halı Saha','Çengelköy Halı Saha','Hasan Özaydın Halı Saha','Şampiyon Halı Saha','Halı Saha 2000','Çengelköy SK Halı Saha','Ünalan SK Halı Saha','Çengelköy Kapalı Halı Saha','Erdoğan Kardeşler Halı Saha','Yavuztürk SK Halı Saha','Kirazlıtepe Spor Kulübü Tesisleri','Üsküdar Anka Sk Halı Saha','Küçüksu Gold Halı Saha','İstanbul Kemah Spor Halı Saha','Üsküdar Kulüpler Birliği Halı Saha','VezirSpor Halı Saha Tesisleri','Valide Tayfun Halı Saha']
    ),
    FootballField(
      city: 'İstanbul',
      district: 'Zeytinburnu',
      fieldName: ['Zeytinburnu Batı Trakya Halı Saha','Spor İstanbul Çırpıcı Halı Saha','Demirciler Halı Saha','Kazlıçeşme Spor Tesisleri']
    ),
  ];

  // Add data to the box
  for (var field in fields) {
    await localDb.add(field);
  }
}
}