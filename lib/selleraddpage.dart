import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/sellersuccesspage.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';


class SellerAddPage extends StatefulWidget {
  const SellerAddPage({super.key});

  @override
  State<SellerAddPage> createState() => _SellerAddPageState();
}

//TODO: gün ve sahaları beraber bir array'e yükle 

class _SellerAddPageState extends State<SellerAddPage> {

  bool isLoading = true;
  
  // Kullanıcı bilgileri
  TextEditingController sellerFullName = TextEditingController();
  TextEditingController sellerPrice = TextEditingController();
  TextEditingController sellerPriceAfterMidnight = TextEditingController();
  TextEditingController sellerGig = TextEditingController();

  // for inserting the users earning
  int sellerEarning = 0;
  int sellerEarningMidnight = 0;

  final _formKey = GlobalKey<FormState>();

  // galeriden resim seçmek için
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  // sıradaki resime geçmek için
  int currentIndex = 0;

  // new dropdown menu
  List<String> cities = [];
  List<String> districts = [];
  List<dynamic> cityData = [];
  // for inserting to database
  String? selectedCity;
  String? selectedDistrict;
  String? selectedField;
  Set<String> multFields = {};
  String? value1;

  // this shows the inital and selected fields
  Set<String> selectedFields = {};

  // this is the inital values of textfields for düzenle
  late String initialName = '';
  late int initialPrice = 0; 
  late int initialPriceMidnight = 0;
  late String initialGig = '';
  // this three is for printing the initial district
  late String initialDistrict = '';
  String districtFromDb = '';
  bool initialD = true;

  // for selecting the fields according to the districts
  List<String> fields = [];

  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  bool userisSeller = false;

  final GlobalKey<_AmenitiesState> mondayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> tuesdayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> wednesdayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> thursdayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> fridayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> saturdayKey = GlobalKey();
  final GlobalKey<_AmenitiesState> sundayKey = GlobalKey();

  late Future<bool> sellerCheckFuture;

  final String defaultImageUrl = 'https://firebasestorage.googleapis.com/v0/b/kiralikkaleci-21f26.appspot.com/o/images%2Fdefault_1754929226518.jpg?alt=media&token=4c611bc8-4761-45db-b4e4-7015e5b63374';
  //final String defaultDevImageUrl = 'https://firebasestorage.googleapis.com/v0/b/kiralikkaleci-dev.firebasestorage.app/o/images%2Fdefault_1750425664401.jpg?alt=media&token=fe58a3fc-4fe4-4779-acaa-fa3af9bd14c3';

  @override
  void initState() {
    super.initState();
    initData();
    sellerPrice.addListener(() {
      setState(() {}); 
    });
    sellerPriceAfterMidnight.addListener(() {
      setState(() {});
    });
    sellerCheckFuture = checkIfUserIsAlreadySeller();
  }

//   Future<void> initData() async {
//   await fetchCities(); 
//   onCitySelected('İstanbul');
//   await getInitialName();
//   await getInitialPrice();
//   await getInitialPriceMidnight();
//   districtFromDb = await getInitialDistrict();
//   setState(() {
//     selectedDistrict = districtFromDb;
//   });
//   await getInitialFields();
//   await getInitialDayHours();
//   FootballField.storeFields();
//   userorseller = true;
//   setState(() {
//   isLoading = false;
//   });

// }
  
  Future<void> initData() async {
  await fetchCities(); // This is needed first for cityData
  onCitySelected('İstanbul'); // This can be called after cities are fetched

  // Fetch all Firestore data in parallel
  final results = await Future.wait([
    getInitialName(),
    getInitialPrice(),
    getInitialPriceMidnight(),
    getInitialDistrict(),
    getInitialFields(),
    getInitialDayHours(),
    getInitialGig()
  ]);

  districtFromDb = results[3] as String;
  setState(() {
    selectedDistrict = districtFromDb;
    isLoading = false;
  });

  FootballField.storeFields();
  userorseller = true;
}

  @override
  void dispose() {
    super.dispose();
    // veriyi cloud a yolladıktan sonra hepsini sil
    sellerFullName.dispose();
    sellerPrice.dispose();
  }

  void _clearImageandText() {
    if (mounted) {
      setState(() {
        imageFileList.clear();
        sellerFullName.clear();
        sellerGig.clear();
        sellerPrice.clear();
        multFields.clear();
        selectedCity = null;
        selectedDistrict = null;
        mondayKey.currentState?.resetSelection();
        tuesdayKey.currentState?.resetSelection();
        wednesdayKey.currentState?.resetSelection();
        thursdayKey.currentState?.resetSelection();
        fridayKey.currentState?.resetSelection();
        saturdayKey.currentState?.resetSelection();
        sundayKey.currentState?.resetSelection();
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    if (isLoading) {
      return const SellerAddPageShimmer();
    }
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sellerbackground,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: buildButton(),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GlobalStyles.textStyle(text: 'Fotoğraf Ekle', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      const SizedBox(width: 5),
                      GlobalStyles.textStyle(text: '(Opsiyonel)', context: context, size: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ],
                  )
                ),
                const SizedBox(height: 10),

                // image picker
                PickImageGallery(
                  imageFileList: imageFileList,
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        imageFileList.add(image);
                      });
                    }
                  },
                ),

                SizedBox(height: height*0.020),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child :GlobalStyles.textStyle(text: 'Ad Soyad', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 10),

                NameField(
                  controller: sellerFullName,
                ),

                /*
                Seçilen şehire göre ilçeler updateDistrictOptions() fonksiyonu ile popüle ediliyor
                */
                
                SizedBox(height: height*0.040),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GlobalStyles.textStyle(text: 'Açıklama', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      const SizedBox(width: 5),
                      GlobalStyles.textStyle(text: '(Opsiyonel)', context: context, size: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ],
                  )
                ),

                const SizedBox(height: 10),

                gigField(
                  controller: sellerGig,
                  height: 130,
                ),

                SizedBox(height: height*0.040),

                Padding(
                  padding: const EdgeInsets.only(left: 10), 
                  child: GlobalStyles.textStyle(text: 'İlçe', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 15),
                DistrictDropDown(
                  districtFromDb: districtFromDb,
                  isInitial: initialD,
                  selectedDistrict: selectedDistrict,
                  districts: districts,
                  onDistrictSelected: (value) {
                    selectedDistrict = value;
                    fetchFields(value.toString());
                  },
                  multFields: multFields
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child:GlobalStyles.textStyle(text: 'Halı Sahalar', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 15),

                FieldsDropDown(
                  multFields: selectedFields,
                  fields: fields, 
                  onSelectionChanged: (updatedFields) {
                    setState(() {
                      selectedFields = updatedFields;
                    });
                  },
                ),
          
          const SizedBox(height: 10),

          showFields(multFields: selectedFields),

            const SizedBox(height: 5),
                // SAAT BİLGİLERİNİ GİR
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GlobalStyles.textStyle(text: 'Saatler', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(height: height*0.020),
                SizedBox(
                  width: width,
                  child: FutureBuilder<Map<String,dynamic>>(
                    future: getInitialDayHours(),
                    builder: (context,snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final initialData = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Pazartesi', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: mondayKey,
                                  day: 'Pazartesi',
                                  initials: List<Map<String, dynamic>>.from(initialData['Pazartesi'] ?? []),
                                  ),
                  
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Salı', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: tuesdayKey,
                                  day: 'Salı',
                                  initials: List<Map<String, dynamic>>.from(initialData['Salı'] ?? []),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Çarşamba', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: wednesdayKey,
                                  day: 'Çarşamba',
                                  initials: List<Map<String, dynamic>>.from(initialData['Çarşamba'] ?? []),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Perşembe', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: thursdayKey,
                                  day: 'Perşembe',
                                  initials: List<Map<String, dynamic>>.from(initialData['Perşembe'] ?? []),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Cuma', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: fridayKey,
                                  day: 'Cuma',
                                  initials: List<Map<String, dynamic>>.from(initialData['Cuma'] ?? []),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Cumartesi', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: saturdayKey,
                                  day: 'Cumartesi',
                                  initials: List<Map<String, dynamic>>.from(initialData['Cumartesi'] ?? []),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                GlobalStyles.textStyle(text: 'Pazar', context: context, size: 15, fontWeight: FontWeight.w400, color: Colors.white),
                                Amenities(
                                  key: sundayKey,
                                  day: 'Pazar',
                                  initials: List<Map<String, dynamic>>.from(initialData['Pazar'] ?? []),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 5),
                //   child: SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     child: Row(
                //       children: [
                //         const SizedBox(width: 10),
                //           Column(
                //             children: [
                //               Text(
                //                 "Pazartesi",
                //                 style: GoogleFonts.inter(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.white
                //                 ),
                //               ),
                //               Amenities(key: mondayKey ,day: 'Pazartesi',),
                //             ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Salı",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //             Amenities(key: tuesdayKey ,day: 'Salı')
                //           ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Çarşamba",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //             Amenities(key: wednesdayKey ,day: 'Çarşamba')
                //           ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Perşembe",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //             Amenities(key: thursdayKey ,day: 'Perşembe',)
                //           ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Cuma",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //             Amenities(key: fridayKey ,day: 'Cuma')
                //           ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Cumartesi",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //              Amenities(key: saturdayKey ,day: 'Cumartesi')
                //           ],
                //         ),
                //         const SizedBox(width: 10),
                //         Column(
                //           children: [
                //             Text(
                //               "Pazar",
                //               style: GoogleFonts.inter(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.white
                //               ),
                //             ),
                //             Amenities(key: sundayKey ,day: 'Pazar')
                //           ],
                //         ),
                //         const SizedBox(width: 5),
                //       ],
                //     ),
                //   ),
                // ), 
                
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GlobalStyles.textStyle(text: 'Fiyat', context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white)
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                priceField(controller: sellerPrice),
                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: YourEarning(earnedPrice: sellerPrice, sellerEarning: sellerEarning,),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      GlobalStyles.textStyle(text: "Fiyat (00:00'dan sonra)", context: context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                priceFieldAfterMidnight(controller: sellerPriceAfterMidnight),

                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: YourEarning(earnedPrice: sellerPriceAfterMidnight, sellerEarning: sellerEarningMidnight,),
                ),
                
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                      style: GlobalStyles.buttonPrimary(context),
                      onPressed: () async {
                        try {
                          if (await InternetConnection().hasInternetAccess) {
                            bool isInserted = await _insertSellerDetails(context);
                            if (isInserted) {
                              _clearImageandText();
                            }
                          } else {
                            Showalert(context: context, text: 'Ooops...').showErrorAlert();
                          }
                        } catch (e) {
                          Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz?').showErrorAlert();
                        }
                      },
                      child: GlobalStyles.textStyle(text: 'Onayla', context: context, size: 24, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> fetchFields(String selectedDistrict) async {
    try {
      var localDb = await Hive.openBox<FootballField>('football_fields');
      var field = localDb.values.firstWhere((f) => f.district == selectedDistrict);
      setState(() {
        fields = field.fieldName;
        selectedField = null;
      });
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage fetchFields error for district $selectedDistrict',
      );
      if (mounted) {
        setState(() {
          fields = [];
          selectedField = null;
        });
      }
    }
  }

  Future<void> fetchCities() async {
    try {
      var response = await http.get(Uri.parse('https://turkiyeapi.dev/api/v1/provinces'));
      if (response.statusCode == 200) {
        final List<dynamic> citiesData = jsonDecode(response.body)['data'];
        List<String> cityNames = citiesData.map((city) => city['name'].toString()).toList();
        if (mounted) {
          setState(() {
            cities = cityNames;
            cityData = citiesData;
          });
        }
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage fetchCities error',
      );
    }
  }

  // checks if the seller is currently has an active ad
  Future<bool> checkIfUserIsAlreadySeller() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance.collection('Users').doc(currentUser).get();
      userisSeller = documentSnapshot.data()?['sellerDetails'] != null;
      return userisSeller;
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage checkIfUserIsAlreadySeller error for user $currentUser',
      );
      return false;
    }
  }

  Widget buildButton() {
  return FutureBuilder<bool>(
    future: sellerCheckFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }

      if (snapshot.hasData) {
        return Text(
          snapshot.data! ? 'İlanı Düzenle' : 'İlan Ekle',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        );
      }

      return Text('Hata', style: GoogleFonts.inter(fontSize: 20));
    },
  );
}


  // to populate with districts
  void onCitySelected(String selectedCity) {
    // todo: Burada selectedCity istanbul olacak
    final city = cityData.firstWhere((city) => city['name'].toString() == selectedCity);
    if (city != null) {
      final districtsData = city['districts'];
      if (districtsData != null) {
        final List<String> districtNames = (districtsData as List<dynamic>).map((district) => district['name'].toString()).toList();

        setState(() {
          this.selectedCity = selectedCity;
          districts = districtNames;
          selectedDistrict = null; // Reset selected district
        });
      }
    }
  }

  Future<bool> _insertSellerDetails(BuildContext context) async {
    bool hasSelectedAnyHour = _AmenitiesState.selectedHoursByDay.values.any((list) => list.isNotEmpty);
    if (_formKey.currentState!.validate() && hasSelectedAnyHour && selectedFields.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.grey,
            ),
          );
        }
      );

      // burada sorun satıcı ilanı düzenleyince istaken değeri ve takenby değeri de yenileniyor
      try {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        if (userId.isNotEmpty) {
          // Fetch previous sellerDetails from Firestore
          final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
          final prevSellerDetails = userDoc.data()?['sellerDetails'];
          final prevSelectedHoursByDay = prevSellerDetails?['selectedHoursByDay'] ?? {};

          Map<String, dynamic> formattedData = {};
          _AmenitiesState.selectedHoursByDay.forEach((day, selectedHours) {
            if (selectedHours.isNotEmpty) {
              formattedData[day] = selectedHours.map((hour) {
                // Try to find previous hour data
                final prevDayHours = prevSelectedHoursByDay[day] as List<dynamic>? ?? [];
                final prevHour = prevDayHours.firstWhere(
                  (h) => h['title'] == hour.title,
                  orElse: () => null,
                );
                if (prevHour != null) {
                  // Keep previous istaken and takenby
                  return {
                    'title': hour.title,
                    'istaken': prevHour['istaken'],
                    'takenby': prevHour['takenby'],
                  };
                } else {
                  // New hour, set defaults
                  return {
                    'title': hour.title,
                    'istaken': false,
                    'takenby': 'empty',
                  };
                }
              }).toList();
            } 
          });
          List<String> dayNames = formattedData.keys.toList();
          // for easier querying (Hasan Özaydın_Cuma), combines fields with days
          List<String> querytags = await filterTags(selectedFields,dayNames);

          int? price = int.tryParse(sellerPrice.text);
          int? priceAfterMidnight = int.tryParse(sellerPriceAfterMidnight.text);

          Map<String, dynamic> sellerDetails = {
            "sellerFullName": sellerFullName.text,
            'sellerGig': sellerGig.text,
            "sellerPrice": price,
            'sellerPriceMidnight': priceAfterMidnight,
            'sellerEarning': price! - (price * 0.10),
            'sellerEarningMidnight': priceAfterMidnight! - (priceAfterMidnight * 0.10),
            "city": selectedCity,
            "district": selectedDistrict ?? districtFromDb,
            'fields': selectedFields,
            "imageUrls": await _uploadImagesToStorage(),
            'chosenDays': formattedData.keys.toList(),
            'queryTags' : querytags,
            "selectedHoursByDay": formattedData,
          };

          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userId)
              .update({"sellerDetails": sellerDetails});

          setState(() {
            _AmenitiesState.selectedHoursByDay.clear();
          });

          Navigator.of(context).pop();
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => SellerSuccessPage()));
        }
        return true;
      } catch (e, stack) {
        Navigator.of(context).pop();
        await reportErrorToCrashlytics(
          e,
          stack,
          reason: 'selleraddpage _insertSellerDetails error for user $currentUser',
        );
        Showalert(context: context, text: 'Ooops...').showErrorAlert();
        return false;
      }
    } else {
      Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz?').showErrorAlert();
      return false;
    }
  }

  Future<List<String>> filterTags(Set<String> selectedFields,List<String> days) async {
    List<String> filtertags = [];
    if (selectedFields.isNotEmpty && days.isNotEmpty) {
      for (var field in selectedFields) {
        for (var day in days) {
          filtertags.add('${field}_$day');
        }
      } 
      return filtertags;
    } else {
      return [];
    }
  }


Future<List<String>> _uploadImagesToStorage() async {
  List<String> imageUrls = [];
  if (imageFileList.isNotEmpty) {
    for (XFile imageFile in imageFileList) {
      try {
        File file = File(imageFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e, stack) {
        await reportErrorToCrashlytics(
          e,
          stack,
          reason: 'selleraddpage _uploadImagesToStorage error',
        );
      }
    }
  } else {
    imageUrls.add(defaultImageUrl);
  }
  return imageUrls;
}

  Future<File> getDefaultImageFile() async {
    try {
      final byteData = await rootBundle.load('lib/images/defImage.jpg');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/imageDefault.jpg');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage getDefaultImageFile error',
      );
      rethrow;
    }
  }

  Future<String> getInitialName() async {
  try {
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .get();

    if (doc.exists) {
      final data = doc.data();
      final sellerDetails = data?['sellerDetails'];
      if (sellerDetails != null && sellerDetails['sellerFullName'] != null) {
        initialName = sellerDetails['sellerFullName'];
        sellerFullName.text = initialName;
        return initialName;
      }
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'selleraddpage getInitialName error for user $currentUser',
    );
  }
  return '';
}

  Future<String> getInitialGig() async {
  try {
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .get();

    if (doc.exists) {
      final data = doc.data();
      final sellerDetails = data?['sellerDetails'];
      if (sellerDetails != null && sellerDetails['sellerGig'] != null) {
        initialGig = sellerDetails['sellerGig'];
        sellerGig.text = initialGig;
        return initialGig;
      }
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'selleraddpage getInitialName error for user $currentUser',
    );
  }
  return '';
}

  Future<String> getInitialDistrict() async {
    try {
      final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .get();

      if (doc.exists) {
        final data = doc.data();
        final sellerDetails = data?['sellerDetails'];
        if (sellerDetails != null && sellerDetails['district'] != null) {
          initialDistrict = sellerDetails['district'];
          selectedDistrict = initialDistrict;
          fetchFields(initialDistrict.trim());
          return initialDistrict.trim();
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage getInitialDistrict error for user $currentUser',
      );
    }
    return '';
  }

  Future<void> getInitialFields() async {
    try {
      final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .get();

      if (doc.exists) {
        final data = doc.data();
        final sellerDetails = data?['sellerDetails'];
        if (sellerDetails != null && sellerDetails['fields'] != null) {
          selectedFields = Set.from(sellerDetails['fields']);
          setState(() {});
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage getInitialFields error for user $currentUser',
      );
    }
  }

  Future<Map<String, dynamic>> getInitialDayHours() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final sellerDetails = data?['sellerDetails'];
        if (sellerDetails != null && sellerDetails['selectedHoursByDay'] != null) {
          final hoursDays = sellerDetails['selectedHoursByDay'];
          return Map<String, dynamic>.from(hoursDays);
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage getInitialDayHours error for user $currentUser',
      );
    }
    return {};
  }

  Future<int> getInitialPrice() async {
  try {
    final doc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .get();

    if (doc.exists) {
      final data = doc.data();
      final sellerDetails = data?['sellerDetails'];
      if (sellerDetails != null && sellerDetails['sellerPrice'] != null) {
        initialPrice = sellerDetails['sellerPrice'];
        sellerPrice.text = initialPrice.toString();
        return initialPrice;
      }
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'selleraddpage getInitialPrice error for user $currentUser',
    );
  }
  return 0;
}

  Future<int> getInitialPriceMidnight() async {
    try {
      final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .get();

      if (doc.exists) {
        final data = doc.data();
        final sellerDetails = data?['sellerDetails'];
        if (sellerDetails != null && sellerDetails['sellerPriceMidnight'] != null) {
          initialPriceMidnight = sellerDetails['sellerPriceMidnight'];
          sellerPriceAfterMidnight.text = initialPriceMidnight.toString();
          return initialPriceMidnight;
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'selleraddpage getInitialPriceMidnight error for user $currentUser',
      );
    }
    return 0;
  }
}
/*
  BURDAN SONRAKİ TEXTLER KULLANICI İÇİN SAAT SEÇİCİ OLACAK
*/
class CheckContainerModel {
  final String title;
  bool isCheck;

  CheckContainerModel({required this.title, this.isCheck = false});

  CheckContainerModel copyWith({String? title, bool? isCheck}) {
    return CheckContainerModel(
      title: title ?? this.title,
      isCheck: isCheck ?? this.isCheck,
    );
  }
}

class Amenities extends StatefulWidget {
  
  final String day;
  final List<Map<String,dynamic>>? initials;

  const Amenities({
    super.key, 
    required this.day,
    this.initials
  });

  @override
  State<StatefulWidget> createState() {
    return _AmenitiesState();
  }
}

class _AmenitiesState extends State<Amenities> {

  static Map<String, List<CheckContainerModel>> selectedHoursByDay = {
    'Pazartesi': [],
    'Salı': [],
    'Çarşamba': [],
    'Perşembe': [],
    'Cuma': [],
    'Cumartesi': [],
    'Pazar': [],
  };

  List<CheckContainerModel> checkContainers = [
    CheckContainerModel(title: '18:00-19:00', isCheck: false),
    CheckContainerModel(title: '19:00-20:00', isCheck: false),
    CheckContainerModel(title: '20:00-21:00', isCheck: false),
    CheckContainerModel(title: '21:00-22:00', isCheck: false),
    CheckContainerModel(title: '22:00-23:00', isCheck: false),
    CheckContainerModel(title: '23:00-00:00', isCheck: false),
    CheckContainerModel(title: '00:00-01:00', isCheck: false),
    CheckContainerModel(title: '01:00-02:00', isCheck: false),
  ];

  List<CheckContainerModel> selectedHours = [];

   @override
  void initState() {
    super.initState();
    if (!selectedHoursByDay.containsKey(widget.day)) {
      selectedHoursByDay[widget.day] = [];
    }
    if (widget.initials != null) {
  final List<Map<String, dynamic>> initialList = List<Map<String, dynamic>>.from(widget.initials!);

  for (var selected in initialList) {
    final title = selected['title'];
    for (var container in checkContainers) {
      if (container.title == title) {
        container.isCheck = true;

        // ✅ Prevent duplicate additions
        if (!selectedHoursByDay[widget.day]!.any((c) => c.title == container.title)) {
          selectedHoursByDay[widget.day]!.add(container);
        }
      }
    }
  }
}

  }


void onCheckTap(CheckContainerModel container) {
  final index = checkContainers.indexWhere(
    (element) => element.title == container.title, 
  );

  bool previousIsCheck = checkContainers[index].isCheck;
  checkContainers[index].isCheck = !previousIsCheck;

  // Ensure the list is initialized
  selectedHoursByDay[widget.day] ??= [];

  if (checkContainers[index].isCheck) {
    selectedHoursByDay[widget.day]!.add(checkContainers[index]);
    selectedHours.add(checkContainers[index]);
  } else {
    selectedHoursByDay[widget.day]!.removeWhere(
      (element) => element.title == checkContainers[index].title,
    );
  }
  
  if (mounted) {
    setState(() {});
  }
}
  void resetSelection() {
  checkContainers = checkContainers.map((container) {
    return container.copyWith(isCheck: false); // Create a new instance with isCheck = false
  }).toList(); // Convert back to list

  //selectedHoursByDay[widget.day]?.clear(); // Clear the selected list for the day
  if (mounted) {
    setState(() {}); // Refresh the UI
  }
}



@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: checkContainers.map((container) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          splashColor: Colors.cyanAccent,
          onTap: () => onCheckTap(container),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            padding: const EdgeInsets.all(8),
            color: container.isCheck ? Colors.green : Colors.white, // seçim rengini yeşil yap
            // child: Text(
            //   container.title,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: container.isCheck ? Colors.white : Colors.black,
            //   ),
            // ),
            child: GlobalStyles.textStyle(text: container.title, context: context, size: 14, fontWeight: FontWeight.normal, color: container.isCheck?Colors.white:Colors.black),
          ),
        ),
      );
    }).toList(),
  );
  }
}
class PickImageGallery extends StatefulWidget {
  final List<XFile> imageFileList;
  final VoidCallback onTap;

  const PickImageGallery({
    Key? key,
    required this.imageFileList,
    required this.onTap,
  }) : super(key: key);

  @override
  _PickImageGalleryState createState() => _PickImageGalleryState();
}

class _PickImageGalleryState extends State<PickImageGallery> {
  int currentIndex = 0;

  void _removeImage(int index) {
    setState(() {
      widget.imageFileList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: sellergrey, 
      height: 110,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: 100,
                  height: 90,
                  color: Colors.white, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        "Fotoğraf",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Ekle",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 100,
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.imageFileList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                              });

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      child: CarouselSlider(
                                        options: CarouselOptions(
                                          aspectRatio: 1,
                                          viewportFraction: 1,
                                          enableInfiniteScroll: false,
                                          padEnds: false,
                                          initialPage: currentIndex,
                                        ),
                                        items: widget.imageFileList.map((imageFile) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return Image.file(
                                                File(imageFile.path),
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.file(
                              File(widget.imageFileList[index].path),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _removeImage(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class gigField extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  const gigField({
    required this.controller,
    required this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
        return Text(
          "$currentLength / ${200} karakter",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          );
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(200)
        ],
        maxLines: null,
        minLines: null,
        expands: true,
        textAlign: TextAlign.start,
        controller: controller,
        validator: (value) {
          // user can leave the gig empty 
          return null;
        },
        style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300
                      ),
                    decoration: InputDecoration(
                        hintText: "İletişim bilgisi paylaşan kullanıcıların hesapı kapatılacaktır !",
                        hintStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w200
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
                        fillColor: sellergrey,
                        filled: true,
                    ),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  const NameField({
    required this.controller,
    super.key
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
                  controller: controller,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return "Boş Bırakılamaz !";
                    }
                    return null;
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                  decoration: InputDecoration(
                      hintText: "İsminizi giriniz",
                      hintStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      fillColor: sellergrey,
                      filled: true,
                  ),
                );
  }
}
class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final List<String> cities;
  final ValueChanged<String?> onCitySelected;
  final Set<String> ?multFields;

  const CityDropdown({
    super.key,
    required this.selectedCity,
    required this.cities,
    required this.onCitySelected,
    required this.multFields
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        isExpanded: true,
                        value: selectedCity,
                        items: cities.map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.inter(
                              color: Colors.black
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onCitySelected(value);
                          }
                          multFields!.clear();
                        },
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Text(
                            'Şehir seçin'
                          ),
                        ),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(height: 0),
                          ),
                        validator: (value) {
                          if (value == null) {
                            return '';
                          } else {
                            return null;
                          }
                        },
                      ),
                    const SizedBox(height: 2),
                    if (selectedCity == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Text(
                        'Lütfen bir şehir seçin',
                        style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    ],
                  ),
                );
  }
}

class DistrictDropDown extends StatelessWidget {
  final String? selectedDistrict;
  final List<String> districts;
  final ValueChanged<String?> onDistrictSelected;
  final Set<String>? multFields;
  final bool isInitial;
  final String districtFromDb;

  const DistrictDropDown({
    super.key,
    required this.selectedDistrict,
    required this.districts,
    required this.onDistrictSelected,
    required this.multFields,
    required this.isInitial,
    required this.districtFromDb,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: (selectedDistrict != null && districts.contains(selectedDistrict)) ? selectedDistrict
                : (districtFromDb.isNotEmpty && districts.contains(districtFromDb))
                ? districtFromDb
                : null,
            items: districts.map((district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(
                  district,
                  style: GoogleFonts.inter(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              onDistrictSelected(value);
              multFields?.clear();
            },
            isExpanded: true,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('İlçe seçin'),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              errorStyle: const TextStyle(height: 0),
            ),
            validator: (value) {
              if (value == null) return '';
              return null;
            },
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class FieldsDropDown extends StatelessWidget {
  final Set<String> multFields;
  final List<String> fields;
  final ValueChanged<Set<String>> onSelectionChanged; // Callback to parent

  const FieldsDropDown({
    super.key,
    required this.multFields,
    required this.fields,
    required this.onSelectionChanged, // Receive function from parent
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 45,
          width: MediaQuery.sizeOf(context).width,
          color: Colors.white,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, _setState) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView(
                          children: fields.map((e) {
                            return CheckboxListTile(
                              title: Text(e),
                              value: multFields.contains(e),
                              onChanged: (isSelected) {
                                _setState(() { // First, update the modal UI
                                if (isSelected == true) {
                                  multFields.add(e);
                                } else {
                                  multFields.remove(e);
                                }
                              });
                              // Then, notify the parent about the change
                              onSelectionChanged(Set.from(multFields));
                            },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              );
            },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      'Saha Seç',
                      style: GoogleFonts.inter(color: Colors.black),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
              ), 
          ),
        ),
      ),
    );
  }
}
class showFields extends StatefulWidget {
  final Set<dynamic> multFields;
  const showFields({
    super.key,
    required this.multFields
  });

  @override
  State<showFields> createState() => _showFieldsState();
}

class _showFieldsState extends State<showFields> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: ListView.separated(
            separatorBuilder: (context,index) => SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: widget.multFields.length,
            itemBuilder: (BuildContext context, int index) {
              List fieldList = widget.multFields.toList();
              return Stack(
                children: [
                  Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        fieldList[index]
                      )
                    )
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.multFields.remove(fieldList[index]);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
                ],
              );
            },
            ),
          );
  }
}
class priceField extends StatelessWidget {
  final TextEditingController controller;
  const priceField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
                  controller: controller,
                  onTapOutside: (e) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  validator: (price) {
                    if (price == null || price.isEmpty) {
                      return  "Fiyat bilgisi girmelisiniz!";
                    } 
                    final value = int.tryParse(price);
                    if (value == null) {
                      return 'Fiyat bilgisi girmelisiniz';
                    }
                    if (value < 250) {
                      return "Fiyat 250 TL'den az olamaz!";
                    } 
                    else {
                      return null;
                    }
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: sellergrey,
                      filled: true,
                      suffixText: 'TL',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      )
                  ),
                );
  }
}
class priceFieldAfterMidnight extends StatelessWidget {
  final TextEditingController controller;
  const priceFieldAfterMidnight({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
                  controller: controller,
                  onTapOutside: (e) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  validator: (price) {
                    if (price == null || price.isEmpty) {
                      return  "Fiyat bilgisi girmelisiniz!";
                    } 
                    final value = int.tryParse(price);
                    if (value == null) {
                      return "Geçerli bir sayı giriniz!";
                    }
                    if (value < 250) {
                      return "Fiyat 250 TL'den az olamaz!";
                    }
                    else {
                      return null;
                    }
                  },
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: sellergrey,
                      filled: true,
                      suffixText: 'TL',
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      )
                  ),
                );
  }
}
class YourEarning extends StatelessWidget {
  final TextEditingController earnedPrice;
  final int sellerEarning;

  const YourEarning({
    super.key,
    required this.earnedPrice,
    required this.sellerEarning
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        GlobalStyles.textStyle(text: 'Senin Kazancın', context: context, size: 14, fontWeight: FontWeight.w300, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          '${calculateEarning()} ₺',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        )
      ],
    );
  }

  int calculateEarning() {
    int getValue = int.tryParse(earnedPrice.text) ?? 0;
    int fivePercent = (getValue * 10 ~/ 100);
    return getValue - fivePercent;
  }
}


